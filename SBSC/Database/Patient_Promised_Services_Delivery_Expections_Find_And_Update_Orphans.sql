USE spedmon
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Promised_Services_Delivery_Expections_Find_And_Update_Orphans') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Promised_Services_Delivery_Expections_Find_And_Update_Orphans
GO

/***************************************************************************    
 * Patient_Promised_Services_Delivery_Expections_Find_And_Update_Orphans */    
/**    
 * This routine updates as many orphaned records as it can
 * for a given @clientID or all clients
 ***************************************************************************/                         

CREATE PROCEDURE [dbo].[Patient_Promised_Services_Delivery_Expections_Find_And_Update_Orphans] (
    @clientID          bigint
  , @completedNormally bit = 0 output
)
AS

BEGIN

exec dbo.PRINT_STATUS_MESSAGE 'Patient Promised Service Delivery Exceptions - Find and Update Orphans - Starting'

/*###########################################################################*/
/*# Init and setup                                                         #*/
/*###########################################################################*/

set nocount on

set @completedNormally = 0

declare @tranOpen         as bit          = 0
declare @today            as datetime     = getdate()
declare @orphanCount      as int          = 0
declare @replacementCount as int          = 0
declare @msg              as varchar(256) = ''

declare @deliveryExceptionsOrphaned as table (
    id                 bigint
  , clientID           bigint
  , patID              bigint
  , spEdServiceCode    int
  , dosStart           datetime
  , dosEnd             datetime
  
  , planStartDateOld   date
  , planEndDateOld     date
  , spEdFreqCodeOld    int
  , minsPerFreqOld     int
  , numMinsMissingOld  int
  , notesOld           varchar(max)

  , updatesFound       bit default(0)
  , planStartDateNew   date
  , planEndDateNew     date
  , spEdFreqCodeNew    int
  , minsPerFreqNew     int
  , numMinsMissingNew  int
  , notesNew           varchar(max)
unique clustered (id)
) 


begin try

/*###########################################################################*/
/*#  Find records orphaned by changes                                       #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Patient Promised Service Delivery Exceptions - Find and Update Orphans - Find Orphans'

insert into @deliveryExceptionsOrphaned (
    id
  , clientID
  , patID 
  , spEdServiceCode
  , dosStart
  , dosEnd  

  , planStartDateOld
  , planEndDateOld
  , spEdFreqCodeOld
  , minsPerFreqOld
  , numMinsMissingOld
  , notesOld
)
select 
    t1.id
  , t1.clientID
  , t1.patID 
  , t1.spEdServiceCode
  , t1.dosStart
  , t1.dosEnd  
  , planStartDateOld   = t1.planStartDate
  , planEndDateOld     = t1.planEndDate
  , planFreqCodeOld    = t1.spEdFreqCode 
  , minsPerFreqOld     = t1.minsPerFreq
  , numMinsMissingOld  = t1.numMinsMissing
  , notesOld           = trim(isnull(t1.deliveryExceptionAddedNotes,''))

from dbo.PATIENTS_Promised_Services_Delivery_Exceptions as t1
outer apply (
  select 
    t2.ppsID 
  from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA (
      t1.clientID
    , t1.patID
    , t1.spEdServiceCode
    , t1.planStartDate  -- @startDate 
	, t1.planEndDate
    , t1.spEdFreqCode   -- @spEdFreqCode
    , t1.minsPerFreq    -- @minsPerFreq 
    , t1.dosStart
    , t1.dosEnd
    , null
    , null) as t2

) as t3
where (
      (1=1)
  and ((@clientID is null) or (t1.clientID = @clientID))
  and (t3.ppsID is null)
)
option (recompile)

select @orphanCount = count(t1.id) from @deliveryExceptionsOrphaned as t1 option (recompile)
set @msg = 'Orphan count : ' + convert(varchar(50),@orphanCount)
exec dbo.PRINT_STATUS_MESSAGE @msg

if (@orphanCount = 0)
begin
  set @completedNormally = 1
  exec dbo.PRINT_STATUS_MESSAGE 'No orphans found.  Exiting'
  exec dbo.PRINT_STATUS_MESSAGE 'Patient Promised Service Delivery Exceptions - Find and Update Orphans - Done'
  return(0)
end

/*###########################################################################*/
/*# Find replacements                                                       #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Patient Promised Service Delivery Exceptions - Find and Update Orphans - Find Replacement Plans'

update t1
set
    t1.updatesFound      = 1
  , t1.planStartDateNew  = t3.startDate
  , t1.planEndDateNew    = t3.endDate
  , t1.spEdFreqCodeNew   = t3.spEdFreqCode
  , t1.minsPerFreqNew    = t3.minsPerFreq
  , t1.numMinsMissingNew = iif((t1.numMinsMissingOld <= t3.minsPerFreq),t1.numMinsMissingOld,t3.minsPerFreq)
from @deliveryExceptionsOrphaned as t1
cross apply (
  select top 1 
    t2.* 
  from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA (
    t1.clientID
  , t1.patID
  , t1.spEdServiceCode
  , null
  , null
  , null
  , null
  , t1.dosStart
  , t1.dosEnd
  , null
  , null) as t2
) as t3
option (recompile)

select @replacementCount = count(t1.id) from @deliveryExceptionsOrphaned as t1 where (t1.updatesFound = 1) option (recompile)
set @msg = 'Replacement count : ' + convert(varchar(50),@replacementCount)
exec dbo.PRINT_STATUS_MESSAGE @msg

if (@replacementCount = 0)
begin
  set @completedNormally = 1
  exec dbo.PRINT_STATUS_MESSAGE 'No replacements found.  Exiting'
  exec dbo.PRINT_STATUS_MESSAGE 'Patient Promised Service Delivery Exceptions - Find and Update Orphans - Done'
  return(0)
end

/*###########################################################################*/
/*# Build replacement notes */
/*###########################################################################*/

update t1
set
    t1.notesNew  = t1.notesOld 
				 + char(10) + ' ---- This record was automatically modified by SpEdCare to reflect changes in plan data ----'
				 + char(10) + '* Modified On : '     + convert(varchar, @today, 0) 
				 + char(10) + '* Plan Start Date : ' + dbo.RPT_DATE_FMT(t1.planStartDateOld)     + ' replaced with ' + dbo.RPT_DATE_FMT(t1.planStartDateNew)
				 + char(10) + '* Plan End Date : '   + dbo.RPT_DATE_FMT(t1.planEndDateOld)       + ' replaced with ' + dbo.RPT_DATE_FMT(t1.planEndDateNew)
				 + char(10) + '* SpEd Freq Code : '  + convert(varchar(50),t1.spEdFreqCodeOld)   + ' replaced with ' + convert(varchar(50),t1.spEdFreqCodeNew) 
				 + char(10) + '* Mins Per Freq : '   + convert(varchar(50),t1.minsPerFreqOld)    + ' replaced with ' + convert(varchar(50),t1.minsPerFreqNew) 
				 + char(10) + '* Mins Missing  : '   + convert(varchar(50),t1.numMinsMissingOld) + ' replaced with ' + convert(varchar(50),t1.numMinsMissingNew)
                 + char(10) 
from @deliveryExceptionsOrphaned as t1
where 
  (t1.updatesFound = 1)

begin transaction
set @tranOpen = 1

/*###########################################################################*/
/*# Apply updates */
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Patient Promised Service Delivery Exceptions - Find and Update Orphans - Update Data'


update t2
set 
  t2.planStartDate  = t1.planStartDateNew
, t2.planEndDate    = t1.planEndDateNew
, t2.spEdFreqCode   = t1.spEdFreqCodeNew
, t2.minsPerFreq    = t1.minsPerFreqNew
, t2.numMinsMissing = t1.numMinsMissingNew
, t2.lastModified                = @today
, t2.lastModifiedBy              = 0
, t2.deliveryExceptionAddedNotes = t1.notesNew

from @deliveryExceptionsOrphaned                        as t1
join dbo.PATIENTS_Promised_Services_Delivery_Exceptions as t2 on t2.id = t1.id
where 
  (t1.updatesFound = 1)
option (recompile)

commit transaction
set @tranOpen = 0

exec dbo.PRINT_STATUS_MESSAGE 'Completed normally'
exec dbo.PRINT_STATUS_MESSAGE 'Patient Promised Service Delivery Exceptions - Find and Update Orphans - Done'

set @completedNormally = 1
return(0)

end try

/*###########################################################################*/
/*#  Exception handling                                                     #*/
/*###########################################################################*/

begin catch

  /*------------------------------------*/
  /* Rollback if neccessary             */
  /*------------------------------------*/

  if (@tranOpen = 1)
  begin
    ROLLBACK TRANSACTION
	set @tranOpen = 0
  end

  /*------------------------------------*/
  /* Let caller know we had problem     */
  /*------------------------------------*/
  
  set @completedNormally = 0
  
  print ERROR_MESSAGE()  
  exec dbo.PRINT_STATUS_MESSAGE 'Completed with errors'
  exec dbo.PRINT_STATUS_MESSAGE 'Updates not committed'
  exec dbo.PRINT_STATUS_MESSAGE 'Patient Promised Service Delivery Exceptions - Find and Update Orphans - Done'

  return(0)
  
end catch

/*------------------------------------*/
/* Should never get here but          */
/* if we do its not normal            */
/*------------------------------------*/

set @completedNormally = 0
return(0)

END
GO

GRANT EXECUTE ON  [dbo].Patient_Promised_Services_Delivery_Expections_Find_And_Update_Orphans TO [webuser]
GO

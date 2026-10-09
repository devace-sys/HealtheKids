USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (
  SELECT * FROM sys.objects
  WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_User_Provided_Delivery_Compliance_Stats_Data_Imports_Save')
        AND type in (N'P', N'PC')
)
DROP PROCEDURE dbo.Patients_Promised_Services_CDE_Audits_Current_User_Provided_Delivery_Compliance_Stats_Data_Imports_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patients_Promised_Services_CDE_Audits_Current_User_Provided_Delivery_Compliance_Stats_Data_Imports_Save] (

    @userID            BIGINT
  , @userGroup         INT
  , @userRank          INT
  , @clientID          bigint
  , @importDataJSON    varchar(max)
  , @editDelReason     varchar(7000)
  , @validateRec       bit
  , @saveType          int
  , @recID             bigint
  , @msgNoRec          varchar(1000)
  , @msgNoEdit         varchar(1000)
  , @msgDupRec         varchar(1000)
  , @msgDataError      varchar(1000)
  , @msgNotActive      varchar(1000)
  , @recordID          bigint        output
  , @spDetails         varchar(8000) output
  , @jsonData          varchar(max)  output
)

AS
BEGIN

SET NOCOUNT ON

DECLARE @ErrorMessage  AS NVARCHAR(4000) = ''
DECLARE @ErrorSeverity AS INT
DECLARE @ErrorState    AS INT
declare @tranOpen               as bit = 0
declare @today                  as datetime
declare @structuredDataImportID as bigint
declare @real100 as real = convert(real,100)


declare @ppsUserProvidedStatsImport as table (
      idx                               int identity(1,1)
    , ROW_NUM                           int
    , lastName                          varchar(256)
    , firstName                         varchar(256)  
    , ssid                              nvarchar(50)
	, spEdServiceCode                   varchar(256)
	, spEdServiceCodeVal                int default(-1)
    , planStartDate                     date
	, planEndDate                       date
	, spEdFreqCode                      varchar(256)
	, spEdFreqCodeVal                   int default(-1)
    , minsPerFreq                       int	
	, forImportMinutesExpected          int
	, forImportMinutesSatisfied         int
	, forImportPercentSatisfied         int
	, forImportNotes                    varchar(max)
    , patID                             bigint
	, patIDFound                        bit default(0)
    , currentAuditPatID                 bigint
	, currentAuditPatIDFound            bit default(0)
    , numPlansFound                     int default(0)
	, issueMessage                      varchar(1000) default('')
    , issueFound                        bit default(0)
	
    unique clustered    (idx)
  , unique nonclustered (issueFound,idx)
)

declare @clientCDEAuditID                                   as bigint = null
declare @clientCDEAuditStart                                as date
declare @clientCDEAuditEnd                                  as date
declare @curIdx                                             as int
declare @maxIdx                                             as int
declare @patientsPromisedServicesCDEAuditsCurrentPatientsID as bigint
declare @spEdServiceCode                                    as int  
declare @planStartDate                                      as date 
declare @spEdFreqCode                                       as int  
declare @minsPerFreq                                        as int    
declare @minsExpected                                       as int 
declare @minsSatisfied                                      as int 
declare @pctExpectedApplicable                              as real 
declare @notes                                              as varchar(max) 
declare @remove                                             as bit
declare @numPlansFound                                      as int  
declare @issueFound                                         as bit
declare @rowNum                                             as int           = 0
declare @lastName                                           as varchar(255)  = ''
declare @firstName                                          as varchar(255)  = ''
declare @issueMessage                                       as varchar(1000) = ''
declare @spDetailMsg                                        as varchar(1000) = ''
declare @spSaveDetails                                      as varchar(8000) = ''
declare @spSaveRecID                                        as bigint        = 0
declare @spSaveType                                         as int           = 0

/*############################################################################
 *# Init
 *############################################################################*/

set @spDetails  = ''
set @recordID   = 0
set @jsonData   = '{}'
set @tranOpen   = 0
set @today      = getdate()

BEGIN TRY

/*############################################################################
 *# Exit if key values are not passed
 *############################################################################*/

IF (@clientID IS NULL) RAISERROR ('clientID is required',   11, 1)

/*############################################################################
 *# Save structured data import data
 *############################################################################*/

if ( @validateRec = 0)
BEGIN

  BEGIN TRANSACTION

  set @tranOpen = 1

  exec dbo.Structured_Data_Imports_Save_Core
       @userID
    ,  @userGroup
    ,  @userRank
    ,  @clientID
    ,  @importDataJSON
    ,  1 /* @skipDupCheck*/
    ,  @editDelReason
    ,  @validateRec
    ,  @saveType
    ,  @recID
    ,  @msgNoRec
    ,  @msgNoEdit
    ,  @msgDupRec
    ,  @msgDataError
    ,  @msgNotActive
    ,  @spDetails			    OUTPUT
    ,  @structuredDataImportID  OUTPUT

  COMMIT TRANSACTION

  set @tranOpen = 0
  set @recordID = @structuredDataImportID

END

/*############################################################################
 *# Get current audit dates 
 *############################################################################*/

select top 1 
    @clientCDEAuditStart = t1.startDate
  , @clientCDEAuditEnd   = t1.endDate
  , @clientCDEAuditID    = t1.id
from dbo.Patients_Promised_Services_CDE_Audits_Current as t1
where (
     (t1.clientID = @clientID)
 and (t1.active = 1)
)
OPTION(recompile)

/*############################################################################
 *# If dates are not found get out
 *############################################################################*/

if (@clientCDEAuditID is null)
begin
  RAISERROR ('No audit dates were found.  Please save the audit dates and then try again,',  11, 1)
end

/*############################################################################
 *# Parse imported data
 *############################################################################*/

insert into @ppsUserProvidedStatsImport (
    ROW_NUM
  , lastName 
  , firstName
  , ssid 
  , spEdServiceCode
  , planStartDate
  , planEndDate
  , spEdFreqCode 
  , minsPerFreq  
  , forImportMinutesExpected
  , forImportMinutesSatisfied
  , forImportPercentSatisfied
  , forImportNotes
)

select
    t1.ROW_NUM
  , lastName                      = trim(isnull(t1.lastName,''))
  , firstName                     = trim(isnull(t1.firstName,''))
  , ssid                          = trim(isnull(t1.ssid,N''))
  , spEdServiceCode               = trim(isnull(t1.spEdServiceCode,''))
  , planStartDate                 = t1.planStartDate
  , planEndDate                   = t1.planEndDate
  , spEdFreqCode                  = trim(isnull(t1.spEdFreqCode, ''))
  , minsPerFreq                   = t1.minsPerFreq
  , forImportMinutesExpected      = isnull(t1.forImportMinutesExpected,  0)
  , forImportMinutesSatisfied     = isnull(t1.forImportMinutesSatisfied, 0)
  , forImportPercentSatisfied     = isnull(t1.forImportPercentSatisfied, 0)
  , forImportNotes                = trim(isnull(t1.forImportNotes,''))

FROM OPENJSON( @importDataJSON, '$.structuredDataRows' )
WITH (
	[ROW_NUM]                     int           '$."rowNumIn"'
  , [lastName]                    varchar(256)  '$."rowData"."lastName"'
  , [firstName]                   varchar(256)  '$."rowData"."firstName"'
  , [ssid]                        nvarchar(50)  '$."rowData"."ssid"'
  , [spEdServiceCode]             varchar(256)  '$."rowData"."spEdServiceCode"'
  , [planStartDate]               date          '$."rowData"."planStartDate"'
  , [planEndDate]                 date          '$."rowData"."planEndDate"'
  , [spEdFreqCode]                varchar(256)  '$."rowData"."spEdFreqCode"'
  , [minsPerFreq]                 int           '$."rowData"."minsPerFreq"'
  , [forImportMinutesExpected]    int           '$."rowData"."forImportMinutesExpected"'
  , [forImportMinutesSatisfied]   int           '$."rowData"."forImportMinutesSatisfied"'
  , [forImportPercentSatisfied]   int           '$."rowData"."forImportPercentSatisfied"'
  , [forImportNotes]              varchar(max)  '$."rowData"."forImportNotes"'
) as t1
where ( 
 /* Skip rows that do not contain update data that user failed to remove from import */
 not ((t1.forImportMinutesExpected != 0) and (t1.forImportMinutesSatisfied = 0) and (t1.forImportPercentSatisfied  = 0))
)
OPTION(recompile)

/*############################################################################
 *# First match patient records by SSID
 *############################################################################*/

update ppsImport
set 
     ppsImport.patID      = pap.PATIENT_ID
   , ppsImport.patIDFound = 1
from @ppsUserProvidedStatsImport    as ppsImport
join dbo.PATIENTS_Patient           as pap on ((pap.CSIS = ppsImport.ssid) and (pap.ACTIVE = N'Y'))
join dbo.PATIENTS_Client            as pac on ((pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = pap.PATIENT_ID))
where (
      (ppsImport.issueFound = 0)
  and (len(ppsImport.ssid) > 0)
)
OPTION(recompile)

/*############################################################################
 *# Mark any issues so we will not process these futher 
 *############################################################################*/

update @ppsUserProvidedStatsImport
set 
    issueMessage = 'Active patient record not found in SpEdCare' 
  , issueFound   = 1
where ( 
      (issueFound  = 0)
  and (patIDFound  = 0)
)
OPTION(recompile)

/*############################################################################
 *# Then locate patient audit ids
 *############################################################################*/

update ppsImport
set 
    ppsImport.currentAuditPatID      = ppscacp.id
  , ppsImport.currentAuditPatIDFound = 1
from @ppsUserProvidedStatsImport                                as ppsImport
join dbo.Patients_Promised_Services_CDE_Audits_Current_Patients as ppscacp on ppscacp.patID = ppsImport.patID
join dbo.Patients_Promised_Services_CDE_Audits_Current          as ppscac  on ppscacp.patientsPromisedServicesCDEAuditsCurrentID = ppscac.id
where (
      (ppsImport.issueFound  = 0)
  and (ppscac.clientID       = @clientID)
  and (ppscac.active         = 1)
)
OPTION(recompile)

/*############################################################################
 *# Mark any issues so we will not process these futher 
 *############################################################################*/

update @ppsUserProvidedStatsImport
set 
    issueMessage = 'Patient does not appear to be part of this audit' 
  , issueFound   = 1
where (
      (issueFound             = 0)
  and (currentAuditPatIDFound = 0)
)
OPTION(recompile)

/*############################################################################
 *# Then parse service and frequency codes
 *############################################################################*/

update ppsImport
set 
    ppsImport.spEdServiceCodeVal = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE ( ppsImport.spEdServiceCode, 1)
  , ppsImport.spEdFreqCodeVal    = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE ( ppsImport.spEdFreqCode,    2)
from @ppsUserProvidedStatsImport as ppsImport
where 
  (ppsImport.issueFound = 0)
OPTION(recompile)

/*############################################################################
 *# Mark any issues so we will not process these futher 
 *############################################################################*/

update @ppsUserProvidedStatsImport
set 
    issueMessage = 'Unknown service or frequency values' 
  , issueFound   = 1
where (
        (issueFound = 0)
  and  ((spEdServiceCodeVal = -1) or (spEdFreqCodeVal = -1))
)
OPTION(recompile)

/*############################################################################
 *# Then locate plan data
 *############################################################################*/

update ppsImport
set 
  ppsImport.numPlansFound = ppsld2.numPlansFound
from @ppsUserProvidedStatsImport as ppsImport
cross apply (
   select 
     numPlansFound = count (ppsld1.ppsID) 
   from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA (
        @clientID
      , ppsImport.patID
      , ppsImport.spEdServiceCodeVal
	  , null
	  , null
	  , ppsImport.spEdFreqCodeVal
	  , ppsImport.minsPerFreq
	  , ppsImport.planStartDate
      , ppsImport.planEndDate
      , null
      , null
  ) as ppsld1  
) as ppsld2
where 
  (ppsImport.issueFound = 0)
OPTION(recompile)

/*############################################################################
 *# Mark any issues so we will not process these futher 
 *############################################################################*/

update @ppsUserProvidedStatsImport
set 
    issueMessage = 'No plan data found' 
  , issueFound   = 1
where (
      (issueFound = 0)
  and (numPlansFound = 0)
)
OPTION(recompile)

update @ppsUserProvidedStatsImport
set 
    issueMessage = 'More than one plan was found that could possibly match.' 
  , issueFound   = 1
where (
       (issueFound = 0)
  and  (numPlansFound > 1)
)
OPTION(recompile)

/*############################################################################
 *# Provide minutes expected if its value is set to 0 and if pct satisfied is
 *# set to 0.
 *############################################################################*/

update t1
set   
  t1.forImportMinutesExpected = t3.totalMinutesExpected
from @ppsUserProvidedStatsImport as t1
cross apply (
  select top 1   
    t2.totalMinutesExpected
  from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE (
      @clientID
    , t1.patID
    , null
	, t1.spEdServiceCodeVal
    , t1.planStartDate
	, t1.planEndDate
	, t1.spEdFreqCodeVal
	, t1.minsPerFreq
	, null
	, @clientCDEAuditStart
    , @clientCDEAuditEnd
    , null   /*@patHasBIC*/
    , null   /*@patHasSSID*/
    , null   /*@billableSvcs*/
    , 1      /*@limitCalcToEndDate*/ 
    , 0 
    , 0      /*@calcPotLostReimbursement */
	, 1      /*@limitDosToStartEndDate*/
	, 1     /*@reqPatSvcCode*/
	, 0     /*@usePpsSvcTermsProvided*/
	, 0     /* Pat absent counts as mins satisfied */
	, 0     /* Exit without calc */
  ) as t2
) as t3
where ((t1.forImportMinutesExpected = 0) and (t1.forImportPercentSatisfied = 0) and (t1.forImportMinutesSatisfied != 0))
option (recompile)

/*############################################################################
 *# Update percentage from mins expected and satisfied
 *############################################################################*/

update @ppsUserProvidedStatsImport
set 
  forImportPercentSatisfied = convert(int,(dbo.CALC_PERCENTAGE(forImportMinutesSatisfied,forImportMinutesExpected,1,1,0)))
where (
          (issueFound                 = 0)
      and (forImportMinutesExpected   != 0)
	  and (forImportMinutesSatisfied  != 0)
	  and (forImportPercentSatisfied  = 0)
)
OPTION(recompile)

/*############################################################################
 *# Update mins satisfied from percent satisfied and mins expected 
 *############################################################################*/

update @ppsUserProvidedStatsImport
set 
  forImportMinutesSatisfied = ceiling((((convert(real,forImportPercentSatisfied)) / @real100) * (convert(real,forImportMinutesExpected))))
where (
        (issueFound                 = 0)
    and (forImportMinutesExpected   != 0)
	and (forImportPercentSatisfied  != 0)
	and (forImportMinutesSatisfied  = 0)
)
OPTION(recompile)

/*############################################################################
 *# Get data needed for loops
 *############################################################################*/

set @curIdx = 1
select @maxIdx = MAX(pps.idx) from @ppsUserProvidedStatsImport as pps

/*############################################################################
 *# For each
 *############################################################################*/
 
while (@curIdx <= @maxIdx)
begin
  
  select top 1
      @patientsPromisedServicesCDEAuditsCurrentPatientsID = pps.currentAuditPatID
    , @spEdServiceCode                                    = pps.spEdServiceCodeVal
    , @planStartDate                                      = pps.planStartDate
    , @spEdFreqCode                                       = pps.spEdFreqCodeVal
    , @minsPerFreq                                        = pps.minsPerFreq
    , @minsExpected                                       = pps.forImportMinutesExpected
    , @minsSatisfied                                      = pps.forImportMinutesSatisfied
    , @pctExpectedApplicable                              = pps.forImportPercentSatisfied
	, @notes                                              = trim(isnull(pps.forImportNotes,''))
    , @issueFound                                         = pps.issueFound
  from @ppsUserProvidedStatsImport as pps
  where 
    (pps.idx = @curIdx)
  
  BEGIN TRY

  if (@issueFound = 0)
  begin
    set @remove = 0
    if (len(@notes) = 0)
	begin
	  set @notes = 'Imported from data file'
	end

    exec dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats_Save_Or_Replace
        @userID    
      , @userGroup 
      , @userRank
      , @clientID
      , @patientsPromisedServicesCDEAuditsCurrentPatientsID
      , @spEdServiceCode                 
      , @planStartDate
      , @spEdFreqCode                                
      , @minsPerFreq
      , @minsExpected                                    
      , @minsSatisfied                            
      , @pctExpectedApplicable                          
      , @notes
      , @remove  
	  , @validateRec
      , @spSaveType                    OUTPUT
      , @spSaveDetails                 OUTPUT
      , @spSaveRecID                   OUTPUT
  end
  END TRY
  BEGIN CATCH
      set @issueFound = 1
      update @ppsUserProvidedStatsImport
	  set 
	      issueFound   = 1
	    , issueMessage = left(ERROR_MESSAGE(),900) /* Leave enough room for Row#*/
	  where (idx = @curIdx)
  END CATCH
 
  if (@issueFound = 1)
  begin
    select top 1 
	  @issueMessage = 'Row # '
	                + convert(varchar(50),pps.ROW_NUM)
	                + ' '
	            	+ pps.issueMessage 
	from @ppsUserProvidedStatsImport as pps 
	where 
	  (pps.idx = @curIdx)

    set @spDetails = dbo.UPDATE_DETAILS(@spDetails,@issueMessage,dbo.CONST_RET_WARN())

  end
  
  /*else
  begin
    select top 1 
	  @issueMessage = 'Row # '
	                + convert(varchar(50),pps.ROW_NUM)
	                + ' '
	            	+ ' ME' + convert(varchar(50),pps.forImportMinutesExpected)
					+ ' MS' + convert(varchar(50),pps.forImportMinutesSatisfied)
					+ ' PS' + convert(varchar(50),pps.forImportPercentSatisfied)
	from @ppsUserProvidedStatsImport as pps 
	where 
	  (pps.idx = @curIdx)
    
	set @spDetails = dbo.UPDATE_DETAILS(@spDetails,@issueMessage,dbo.CONST_RET_INFO())
  end
  */

  set @curIdx = @curIdx + 1

end 

/*############################################################################
 *# Generate JSON for reporting/feedback purposes and exit
 *############################################################################*/

set @jsonData = convert(varchar(max),(select * from @ppsUserProvidedStatsImport FOR JSON AUTO))

RETURN(0)

END TRY
BEGIN CATCH


  /*-------------------------------
   * If we end up here something
   * went wrong.  Cancel any pending
   * transactions and return any
   * error any error messages to
   * the caller
   *------------------------------*/

  if (@tranOpen = 1)
  begin
    ROLLBACK TRANSACTION
	set @tranOpen = 0
  end

  -- Error or raise error with severity 11 to 19 will be caught here

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()

   if (@ErrorSeverity > 11)
     SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)


END CATCH
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patients_Promised_Services_CDE_Audits_Current_User_Provided_Delivery_Compliance_Stats_Data_Imports_Save] TO [webuser]
GO

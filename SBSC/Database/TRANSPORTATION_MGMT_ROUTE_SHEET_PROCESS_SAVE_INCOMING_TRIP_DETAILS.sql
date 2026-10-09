USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESS_SAVE_INCOMING_TRIP_DETAILS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESS_SAVE_INCOMING_TRIP_DETAILS
GO

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'RouteSheetTripDetails')
DROP TYPE RouteSheetTripDetails
GO

/*-------------------------------
 * Object Definitions
 *------------------------------*/

CREATE TYPE RouteSheetTripDetails AS TABLE
(
    sheetMemberID int
  , patID         int          
  , patName       varchar(500)   /* Label */
  , miles         varchar(50)    /* Label*/
  , billMon       bit
  , billTue       bit
  , billWed       bit
  , billThu       bit
  , billFri       bit
)
GO

CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESS_SAVE_INCOMING_TRIP_DETAILS]     
 (@userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT,    
  @clientID        BIGINT,
  @transMgmtID     BIGINT,     
  @pracID          BIGINT,
  @reference       VARCHAR(500),           
  @sheetCode       VARCHAR(512),
  @tripdetails     RouteSheetTripDetails READONLY,
  @editDelReason   VARCHAR(7000),    
  @validateRec     BIT,    
  @saveType        INT,    
  @recID           BIGINT,    
  @MsgNoRec        VARCHAR(1000),
  @MsgNoEdit       VARCHAR(1000),
  @MsgDupRec       VARCHAR(1000),
  @MsgDataError    VARCHAR(1000),
  @MsgNotActive    VARCHAR(1000),
  
  @msgInvCombo     VARCHAR(1000),
  @MsgMinReq       VARCHAR(1000),    
  @MsgMinDef       VARCHAR(1000),    
  @MsgMilReq       VARCHAR(1000),    
  @MsgPatElg       VARCHAR(1000),
  @MsgPatDOBGteDOS VARCHAR(1000),
  @MsgPatAbsent    VARCHAR(1000),
  @MsgFutureDOS    VARCHAR(1000),
  
  @spDetails       VARCHAR(8000) OUTPUT,    
  @recordID        BIGINT        OUTPUT )    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESS_SAVE_INCOMING_TRIP_DETAILS */    
/**    
 *                         
 ***************************************************************************/         
     
SET NOCOUNT ON    
      
declare @tranOpen            as bit 
declare @today               as datetime
declare @routeID             as bigint
declare @sheetID             as bigint
declare @groupID             as bigint
declare @nameIdIEP           as bigint
declare @nameIdNoPlan        as bigint
declare @dosMon              as date
declare @dosTue              as date
declare @dosWed              as date
declare @dosThu              as date
declare @dosFri              as date
declare @memberCountProvided as int
declare @memberCountStored   as int
declare @numIncompleteTrips  as int
declare @sheetProcID         as bigint
declare @detailMsg           as varchar (1000)
declare @numSameRouteSheets  as int

declare @tripDetailsStored as table (
    id    bigint
  , patID bigint
  , iep    bit
  , miles  decimal(7,1)
)

declare @tripDetailsBillForDos as table (
   idx           bigint identity(1,1)
 , sheetMemberID bigint
 , dos           date
 , patAbsent     bit
)

declare @svcRecDetails as table (
    idx           bigint identity(1,1)
  , sheetMemberID bigint
  , patID         bigint 
  , dos           date
  , iep           bit
  , nameID        bigint
  , miles         decimal(7,1)
  , patAbsent     bit  
)

/*============================================================
 * Init
 *============================================================*/  

set @spDetails = ''
set @recordID  = 0
set @today     = GETDATE()

BEGIN TRY

/*============================================================
 * Count details provided
 * Get out if none
 *============================================================*/  
 
set @memberCountProvided = 0

select 
  @memberCountProvided = isnull(COUNT(sheetMemberID ),0)
from @tripdetails

if (@memberCountProvided = 0)
begin
  RAISERROR ('There were no trip details provided', 11, 1)
end


/*============================================================
 * Find sheet based on sheet code and also grab some data
 * we will need for later processing.  Get out if none
 *============================================================*/  

set @sheetID = null

select top 1 

    @routeID = t1.routeID
  , @sheetID = t1.sheetID
  , @dosMon  = t1.monDateVal
  , @dosTue  = t1.tueDateVal
  , @dosWed  = t1.wedDateVal
  , @dosThu  = t1.thuDateVal
  , @dosFri  = t1.friDateVal

from dbo.TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW_CORE (
   @userID
 , @userGroup
 , @userRank
 , @clientID
 , @transMgmtID
 , null
 , @sheetCode
 , null
 , 1
 , null) as t1

if (@sheetID is null)
begin
  RAISERROR ('Unknown sheet code or sheet code is no longer active', 11, 1)
end

/*============================================================
 * Check to see if we have a record of this sheet being
 * processed.  Get out if so.
 *============================================================*/  

set @recordID = null

select top 1 
  @recordID = ID  
from dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING
where (
      (CLIENT_ID = @clientID)
  and (SHEET_ID = @sheetID)
)

if (@recordID is not null)
begin
  RAISERROR ('Route sheet has already been processed', 11, 1)
end

/*============================================================
 * Check to see if we have any route sheets that have the
 * same routeID and dos days that have already been processed.
 * If so get out.
 *============================================================*/  

set @numSameRouteSheets = 0

select 
  @numSameRouteSheets = isnull(COUNT(ID),0)
from dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_DUP_ROUTE_DATA_VIEW_CORE ( @userID
                                                                              , @userGroup
                                                                              , @userRank
                                                                              , @clientID
                                                                              , @routeID
                                                                              , @dosMon
                                                                              , @dosTue
                                                                              , @dosWed
                                                                              , @dosThu
                                                                              , @dosFri)
where (PROCESSING_ID is not null)

if (@numSameRouteSheets != 0)
begin
  RAISERROR ('Another route sheet for this same route and dates of service has aleady been processed', 11, 1)
end


/*============================================================
 * Get sheet members we have stored
 *============================================================*/  

insert into @tripDetailsStored
select 
    id
  , patID
  , iep   = 1
  , miles = distanceMiles 
from dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW_CORE (  @userID
                                                            , @userGroup
                                                            , @userRank
                                                            , @clientID
                                                            , @transMgmtID
                                                            , null
                                                            , null
                                                            , @sheetCode
                                                            , @routeID
                                                            , @sheetID
                                                            , 1
                                                            , null)


/*============================================================
 * Count the sheet members we have stored
 * Get out if the count is 0.
 *============================================================*/  

set @memberCountStored = 0

select 
  @memberCountStored = isnull(COUNT(id),0)
from @tripDetailsStored

if (@memberCountStored = 0)
begin
  RAISERROR ('There are no patient trips stored with this sheet', 11, 1)
end

/*============================================================
 * If the # of details provided is not the same as the # of 
 * details stored, get out.
 *============================================================*/  

if (@memberCountProvided != @memberCountStored)
begin
  RAISERROR ('Provided vs stored details mismatch', 11, 1)
end

/*============================================================
 * If the details provided do not match the details stored
 * based on stored record id and patient id get out.
 *============================================================*/  

set @memberCountStored = 0

select 
  @memberCountStored = isnull(COUNT(t1.id),0)
from @tripDetailsStored as t1
join @tripdetails       as t2 on t2.sheetMemberID = t1.id
                              and t2.patID        = t1.patID

if (@memberCountProvided != @memberCountStored)
begin
  RAISERROR ('Provided vs stored details mismatch', 11, 1)
end

/*============================================================
 * Retrieve practitioner data.  If the practitioner is not
 * an active transportation prac with an active group with
 * an active client, get out.
 *============================================================*/  

set @groupID = null

select top 1
   @groupID = gg.GROUP_ID 
from dbo.PRACTITIONERS_DATA_CORE (  5
                                  , @clientID
                                  , null
                                  , null
								  , null) as pdc
join dbo.PRACTITIONER_GROUPS              as  prg on  prg.PRACTITIONER_ID = pdc.PRACTITIONER_ID                                          
join dbo.GROUP_Group                      as  gg  on  gg.GROUP_ID         = prg.GROUP_ID                                   
                                          and gg.GROUP_TYPE in (1,2)
where (pdc.PRACTITIONER_ID = @pracID)


if (@groupID is null)
begin
  RAISERROR ('Practitioner was not found or is not an active transportation practitioner', 11, 1)
end

/*============================================================
 * Retrieve IEP service name ID for transportation for this
 * pracs disciplimne group.  If none found, get out.
 *============================================================*/  

set @nameIdIEP = null

select distinct top 1
  @nameIdIEP = SERVICE_NAME_ID 
from dbo.SERVICES_VIEW_ALL_CORE(null,@groupID,null,dbo.CONST_SERVICES_TRANSPORT(),null,null,null,null,1)
where ((SERVICE_IS_IN_IFSP_IEP = 1) and (SERVICE_IS_IN_NO_PLAN = 0))

if (@nameIdIEP is null)
begin
  RAISERROR ('Service name ID for IEP transportation not found for this practitioners discipline group', 11, 1)
end

/*============================================================
 * Retrieve no plan service name ID for transportation for this
 * pracs discipline group.  If none found, get out.
 *============================================================*/  

set @nameIdNoPlan = null
  
select distinct top 1
  @nameIdNoPlan = SERVICE_NAME_ID 
from dbo.SERVICES_VIEW_ALL_CORE(null,@groupID,null,dbo.CONST_SERVICES_TRANSPORT(),null,null,null,null,1)
where ((SERVICE_IS_IN_NO_PLAN = 1) and (SERVICE_IS_IN_IFSP_IEP = 0))

if (@nameIdNoPlan is null)
begin
  RAISERROR ('Service name ID for no plan transportation not found for this practitioners discipline group', 11, 1)
end

/*============================================================
 * Expand details where day was marked as present 
 * to get specific dos values to create service records for.
 *============================================================*/  

insert into @tripDetailsBillForDos (sheetMemberID, dos, patAbsent) 
          select sheetMemberID, dos = @dosMon, patAbsent = 0 from @tripdetails where (billMon = 1)
union all select sheetMemberID, dos = @dosTue, patAbsent = 0 from @tripdetails where (billTue = 1)
union all select sheetMemberID, dos = @dosWed, patAbsent = 0 from @tripdetails where (billWed = 1)
union all select sheetMemberID, dos = @dosThu, patAbsent = 0 from @tripdetails where (billThu = 1)
union all select sheetMemberID, dos = @dosFri, patAbsent = 0 from @tripdetails where (billFri = 1)

/*============================================================
 * Clients Only
 *
 * Expand details where day was marked as absent to get
 * specific dos values to create service records for.
 *============================================================*/  

if (@userGroup = dbo.CONST_USER_GROUP_CLIENT())
begin
  insert into @tripDetailsBillForDos (sheetMemberID, dos, patAbsent) 
            select sheetMemberID, dos = @dosMon, patAbsent = 1 from @tripdetails where (billMon = 0)
  union all select sheetMemberID, dos = @dosTue, patAbsent = 1 from @tripdetails where (billTue = 0)
  union all select sheetMemberID, dos = @dosWed, patAbsent = 1 from @tripdetails where (billWed = 0)
  union all select sheetMemberID, dos = @dosThu, patAbsent = 1 from @tripdetails where (billThu = 0)
  union all select sheetMemberID, dos = @dosFri, patAbsent = 1 from @tripdetails where (billFri = 0)
end

insert into @svcRecDetails (sheetMemberID, patID, dos, iep, nameID, miles, patAbsent)
select 
     t1.sheetMemberID
   , t2.patID
   , t1.dos
   , t2.iep
   , nameID = case when (t2.iep = 1) then @nameIdIEP else @nameIdNoPlan end
   , t2.miles
   , t1.patAbsent
from @tripDetailsBillForDos as t1
join @tripDetailsStored     as t2 on t2.id = t1.sheetMemberID

/*============================================================
 * Validation
 *============================================================*/  

if (@validateRec = 1) 
begin

  /*============================================================
   * Check if there are incomplete trips where the patient
   * is not marked as absent.  Warn the user if so.
   *============================================================*/  

  set @numIncompleteTrips = 0
  select @numIncompleteTrips = isnull(count(idx),0) from @svcRecDetails where ((miles is null) and (patAbsent = 0))

  if (@numIncompleteTrips > 0)
  begin
    set @detailMsg = 'There are 1 or more trips with no miles.  We will be unable to claim mileage for these trips.'
    set @spDetails = dbo.UPDATE_DETAILS(@spDetails, @detailMsg, dbo.CONST_RET_WARN())  
  end

end


BEGIN TRANSACTION    
SET @TranOpen = 1

/*============================================================
 * If we are not validating save the submitted data
 *============================================================*/  

if (@validateRec = 0)
begin

  insert into dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING (
      CLIENT_ID
    , TRANS_MGMT_ID
    , PRACTITIONER_ID
    , REFERENCE
    , SHEET_CODE
    , SHEET_ID
    , CREATED_BY
    , CREATED_ON
  )
  values (
      @clientID
    , @transMgmtID
    , @pracID
    , @reference
    , @sheetCode
    , @sheetID
    , @userID
    , @today 
  )

  set @sheetProcID = SCOPE_IDENTITY()
  
  insert into dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_PROCESSING_TRIP_DETAILS (
      SHEET_PROC_ID
    , SHEET_ID
    , SHEET_MEMBER_ID
    , PATIENT_ID
    , BILL_MON
    , BILL_TUE
    , BILL_WED
    , BILL_THU
    , BILL_FRI
  )
  select 
      [SHEET_PROC_ID]   = @sheetProcID
    , [SHEET_ID]        = @sheetID
    , [SHEET_MEMBER_ID] = sheetMemberID
    , [PATIENT_ID]      = patID
    , [BILL_MON]        = billMon
    , [BILL_TUE]        = billTue
    , [BILL_WED]        = billWed
    , [BILL_THU]        = billThu
    , [BILL_FRI]        = billFri
  from @tripdetails

end

/*============================================================
 * Create service records 
 *============================================================*/  

declare @minIdx as bigint
declare @maxIdx as bigint
declare @curIdx as bigint

select @minIdx = MIN(idx) from @svcRecDetails
select @maxIdx = MAX(idx) from @svcRecDetails
select @curIdx = @minIdx

DECLARE @batchID       AS UNIQUEIDENTIFIER = NULL
DECLARE @batchIDRecID  AS BIGINT           = NULL

/*============================================================
 * Service record batch id
 *============================================================*/  

if (@validateRec = 0)
begin
  
  exec SERVICE_RECORD_BATCH_ID_Create
      @userID
    , @userGroup
    , @userRank
    , @saveType
    , @validateRec
    , @batchIDRecID OUTPUT
    , @batchID OUTPUT 

end

while (@curIdx <= @maxIdx)
begin
  
  declare @sheetMemberID as bigint  
  declare @dos       as date
  declare @patID     as bigint
  declare @iep       as bit
  declare @nameID    as bigint
  declare @patAbsent as bit
  declare @miles     as decimal(7,1)
  declare @slotFree  as int = 0
  
  declare @miles1    as decimal(7,1)
  declare @miles2    as decimal(7,1)
  declare @miles3    as decimal(7,1)
  declare @miles4    as decimal(7,1)
  
  declare @notes     as varchar(7000)
  declare @svcRecID  as bigint
  declare @spDetailsTemp as varchar(7000)  
  
  set @spDetailsTemp = ''
  set @notes = ''
  
  select top 1
      @sheetMemberID = sheetMemberID
    , @patID         = patID
    , @dos           = dos
    , @iep           = iep
    , @nameID        = nameID
    , @patAbsent     = patAbsent
    , @miles         = isnull(miles,0.1)
  from @svcRecDetails 
  where (idx = @curIdx)
    
  /*============================================================
   * See what trip slot is free 
   *============================================================*/  

  set @slotFree = 0
  
  select top 1
    @slotFree = case when q1.trip1Miles = 0 then 1
                     when q1.trip2Miles = 0 then 2
                     when q1.trip3Miles = 0 then 3
                     when q1.trip4Miles = 0 then 4
                    else 1
                 end
   from
   (
     select top 1
        
        trip1Miles = isnull(sum(dbo.CALC_TRIP_MILES(sr.trip1Start, sr.trip1End)),0)
      , trip2Miles = isnull(sum(dbo.CALC_TRIP_MILES(sr.trip2Start, sr.trip2End)),0)
      , trip3Miles = isnull(sum(dbo.CALC_TRIP_MILES(sr.trip3Start, sr.trip3End)),0)
      , trip4Miles = isnull(sum(dbo.CALC_TRIP_MILES(sr.trip4Start, sr.trip4End)),0)

    from dbo.SERVICE_RECORDS as sr

    where (
          (sr.clientID = @clientID)
      and (sr.patID    = @patID)
      and (sr.dos      = @dos)
      and (sr.svcType  = dbo.CONST_SERVICES_TRANSPORT())
    )
  ) as q1  
    
  /*============================================================
   * Based on what slot is free set trip data accordingly
   *============================================================*/  

  set @miles1 = 0
  set @miles2 = 0
  set @miles3 = 0
  set @miles4 = 0
  
  if (@slotFree = 1) set @miles1 = @miles
  if (@slotFree = 2) set @miles2 = @miles
  if (@slotFree = 3) set @miles3 = @miles
  if (@slotFree = 4) set @miles4 = @miles
  
  /*============================================================
   * Create service record
   *============================================================*/  

  EXEC dbo.SERVICE_RECORD_Save_Core
    @userID,
    @userGroup,    
    @userRank,
	1, /* Generate claims */
    20,    
    @reference,
    NULL,    
    NULL,    
    @dos,    
    @clientID,    
    @pracID,    
    @patID,    
    @iep,    
    @nameID,
    0, /* No ORP doc since this is transport*/
    null,
    null,
   
    0, /* has svc det flags*/
    NULL,
    NULL,
    NULL,
    NULL,    
    null, /*start time*/
    0,    /*num mins */
    0, /* trip 1 start*/    
    @miles1,    
    0,    
    @miles2,    
    0,    
    @miles3,    
    0,    
    @miles4,
    @patAbsent,
	0,
	0,
	null, /* @attendanceSelectionID*/
    @notes,  
	null,
	null,  
	null,
	0, /* Patient goal tracking */
	1, /* Billing program */
	0,    /* Has fillable pdf (TODO: Add these 3 parms) */
    '[]', /* Fillable pdf selections */
	'[]', /* Fillable pdf answers*/

    @editDelReason,    
    @validateRec,    
    @saveType,    
    @recID,    
    @msgDupRec,    
    @msgInvCombo,    
    @MsgNoRec,    
    @MsgNoEdit,    
    @MsgDataError,    
    @MsgMinReq,    
    @MsgMinDef,    
    @MsgMilReq,    
    @MsgPatElg,
    @MsgPatDOBGteDOS,
    @MsgNotActive,
    @MsgPatAbsent,
    @MsgFutureDOS,
    @spDetailsTemp OUTPUT,    
    @svcRecID      OUTPUT      
  
  if (@validateRec = 0)
  begin
  
    insert into dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_PROCESSING_SVC_RECS (
         SHEET_PROC_ID
       , SHEET_MEMBER_ID
       , SVC_REC_ID
    )
    values (
        @sheetProcID
      , @sheetMemberID
      , @svcRecID
    )   
  
    declare @batchIDAssRecID  AS BIGINT = NULL

    exec SERVICE_RECORD_BATCH_ID_Assign
        @userID
      , @userGroup
      , @userRank
      , @saveType
      , @validateRec
      , @batchID
      , @curIdx
      , @svcRecID
      , @batchIDAssRecID OUTPUT
   
      
  
  end
  
  set @curIdx = @curIdx + 1
  set @spDetails = @spDetails + ltrim(rtrim(@spDetailsTemp))

end

set @recordID = @maxIdx

COMMIT TRANSACTION
SET @TranOpen = 0    
RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  IF (@tranOpen = 1)
  BEGIN
    ROLLBACK TRANSACTION
    SET @tranOpen = 0
  END
  
  -- Error or raise error with severity 11 to 19 will be caught here    
    
  /*-------------------------------    
   * Cancel any pending    
   * transactions  
   *------------------------------*/    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  /*-------------------------------    
   * Identify error
   *------------------------------*/    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
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

GRANT EXECUTE ON TYPE::RouteSheetTripDetails TO [webuser]
GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESS_SAVE_INCOMING_TRIP_DETAILS] TO [webuser]
GO

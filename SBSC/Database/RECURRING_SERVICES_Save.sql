USE SPEDMON
GO

/*-------------------------------
 * Drop the recurring services
 * save procedure first
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RECURRING_SERVICES_Save
GO


/*-------------------------------
 * Drop the custom table types
 * next
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'RecurringServiceDetailsPracInfoAll')
DROP TYPE RecurringServiceDetailsPracInfoAll
GO

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'RecurringServiceDetailsSvcMinuteBased')
DROP TYPE RecurringServiceDetailsSvcMinuteBased
GO

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'RecurringServiceDetailsSvcScheduleOrMinuteBased')
DROP TYPE RecurringServiceDetailsSvcScheduleOrMinuteBased
GO

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'RecurringServiceDetailsSvcMileBased')
DROP TYPE RecurringServiceDetailsSvcMileBased
GO

/*-------------------------------
 * Create custom table types
 *------------------------------*/

CREATE TYPE RecurringServiceDetailsPracInfoAll AS TABLE
(
  pracID        bigint,
  pracName      nvarchar(max), /* Label */
  pracTitle     nvarchar(max), /* Label */
  pracDispGrpID bigint,       /* Filled in later */
  tmtBS         bit null,
  tmtDSInd      bit null,
  tmtDSGrp      bit null,
  tmtAS         bit null,
  transHmSs     bit null,
  transSsHm     bit null,
  transSsOs     bit null,
  transOsSs     bit null,
  realNames     varchar(8000) null
 )
GO

CREATE TYPE RecurringServiceDetailsSvcMinuteBased AS TABLE
(
  pracID     bigint,
  pracName   varchar(200),  /* Label */
  pracTitle  varchar(1000), /* Label */
  inIEP      bit,
  isMedNesc  bit,
  numMinsDaily int,
  numMinsMon   int,
  numMinsTue   int,
  numMinsWed   int,
  numMinsThu   int,
  numMinsFri   int
 )
GO


CREATE TYPE RecurringServiceDetailsSvcScheduleOrMinuteBased AS TABLE
(
  pracID         bigint,
  pracName       varchar(200),  /* Label */
  pracTitle      varchar(1000), /* Label */
  inIEP          bit,
  isMedNesc      bit,
  scheduleDaily  bit,
  numMinsDaily   int,
  scheduleMon    bit,
  numMinsMon     int,
  scheduleTue    bit,  
  numMinsTue     int,
  scheduleWed    bit,  
  numMinsWed     int,
  scheduleThu    bit,  
  numMinsThu     int,
  scheduleFri    bit,  
  numMinsFri     int  
 )
GO

CREATE TYPE RecurringServiceDetailsSvcMileBased AS TABLE
(
  pracID       bigint,
  pracName     varchar(200), /* Label */
  pracTitle    varchar(1000), /* Label */
  inIEP        bit,
  isMedNesc    bit,
  numMilesDaily int,
  numMilesMon   int,
  numMilesTue   int,
  numMilesWed   int,
  numMilesThu   int,
  numMilesFri   int
)
GO

/*-------------------------------
 * Create save procedure
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[RECURRING_SERVICES_Save]     
 (@userID            BIGINT,    
  @userGroup         INT,    
  @userRank          INT,    
  @clientID          BIGINT, 
  @patID             BIGINT, 
  @fiscalYearID      INT,
  @startDate         DATETIME,
  @endDate           DATETIME,
  @calendarID        BIGINT,
  @scheduleID        BIGINT,       
  @pracIDsStr        VARCHAR(8000),
  @detailsPracs      RecurringServiceDetailsPracInfoAll              READONLY,
  @detailsTmtBS      RecurringServiceDetailsSvcMinuteBased           READONLY,
  @detailsTmtDSInd   RecurringServiceDetailsSvcScheduleOrMinuteBased READONLY,
  @detailsTmtDSGrp   RecurringServiceDetailsSvcScheduleOrMinuteBased READONLY,  
  @detailsTmtAS      RecurringServiceDetailsSvcMinuteBased           READONLY,
  @detailsTransHmSs  RecurringServiceDetailsSvcMileBased             READONLY,
  @detailsTransSsHm  RecurringServiceDetailsSvcMileBased             READONLY,
  @detailsTransSsOs  RecurringServiceDetailsSvcMileBased             READONLY,
  @detailsTransOsSs  RecurringServiceDetailsSvcMileBased             READONLY,
  @notes             VARCHAR(1000),
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,    
  @saveType          INT,    
  @recID             BIGINT,    
  @MsgNoRec          VARCHAR(1000),    
  @MsgNoEdit         VARCHAR(1000), 
  @MsgDupRec         VARCHAR(1000),   
  @MsgNoClient       VARCHAR(1000),
  @MsgNoPat          VARCHAR(1000),
  @MsgNoPrac         VARCHAR(1000),
  @MsgDataError      VARCHAR(1000),
  @MsgNotActive      VARCHAR(1000),     
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * RECURRING_SERVICES_Save */    
/**    
 * Creates a new one on one aid assignment for a patient
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   pracID          Practitioner id
 * @param   patID           Patient id
 * @param   siteID          Site id
 * @param   startDate       Relationship start
 * @param   endDate         Relationship end
 * @param   fiscalYearID    Fiscal yesr ID
 * @param   calenderID      Calender ID
 * @param   scheduleID      Schedule ID
 * @param   editDelReason   Reason for record edit or delete    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @param   recID           Record id of existing patient record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found    
 * @param   MsgNoSite       Desired error message if a siteID is not found     
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    

DECLARE @today          AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen       AS BIT            -- Is a transaction open    
DECLARE @dupCount       AS INT            -- Duplicate counter used for validation    
DECLARE @updateState    AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @canEdit        AS BIT   
DECLARE @tempRecID      AS BIGINT         -- Used for determining if a rec exists    
DECLARE @tempName       AS VARCHAR(100)
DECLARE @auditRecID     AS BIGINT         
DECLARE @recCountCheck1 as INT
DECLARE @recCountCheck2 as INT
DECLARE @recCountCheck3 as int

DECLARE @fyStartDate    AS DATETIME 
DECLARE @fyEndDate      AS DATETIME 

DECLARE @pracIDs        as TABLE (id int, recid bigint)
DECLARE @pracIDsPrcDet  as TABLE (pracID bigint)
DECLARE @pracIDsSvcDet  as TABLE (pracID bigint)

BEGIN TRY

/*============================================================
 * Init output parameters
 *============================================================*/  
    
SET @recordID   = 0    
SET @spDetails  = ''    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
    
/*============================================================
 * Init worker variables
 *============================================================*/  

SET @today = GETDATE()    
  
/*============================================================
 * If this save operation is an edit verify that the record
 * being edited exists and it can be edited.
 *
 * Note: We do this first for efficiency purposes
 *============================================================*/   

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())     
BEGIN  
  
  /*-------------------------------    
   * Get out if the recid is not
   * provided
   *------------------------------*/   
   
  IF (@recID IS NULL) RAISERROR ('updateRecID is required', 11, 1)    

 /*-------------------------------    
  * Look for record that we want
  * to edit.  
  *------------------------------*/         
  
  SET @recordID = null    
  SET @canEdit  = 0   
  
  select 
    @recordID = id, 
    @canEdit  = active 
  from RECURRING_SERVICES 
    where (id = @recID)
      
  /*-------------------------------    
   * If it does not exist or can
   * not be edited, get out!
   *------------------------------*/ 
        
  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1)  
         
END -- Edit
   
/*============================================================
 * Required validation of parameters provided and lookup 
 * supporting data for new records and edited records
 *============================================================*/   

/*-------------------------------    
 * Verify fiscal year id exists  
 * We only allow the current 
 * fiscal year +- 1 fiscal year  
 *-------------------------------*/    

SET @tempRecID = null
SELECT 
  @tempRecID   = ID,
  @fyStartDate = startDate,
  @fyEndDate   = endDate
FROM CLIENT_ATTENDANCE_YEARS_VIEW(@userID,@userGroup,@userRank,null,null) 
WHERE id = @fiscalYearID
IF (@tempRecID is null) RAISERROR ('Invalid school year', 11, 1)            

/*-------------------------------    
 * Verify start and end dates
 * against fiscal year 
 *-------------------------------*/    

if (datediff(day, @fyStartDate, @startDate) < 0) RAISERROR ('Invalid start date', 11, 1)
if (datediff(day, @fyEndDate,   @EndDate)   > 0) RAISERROR ('Invalid end date',   11, 1)

/*-------------------------------    
 * Verify client id exists    
 *-------------------------------*/    

SET @tempRecID = NULL    
SELECT @tempRecID = CLIENT_ID 
FROM CLIENTS_CLIENT 
WHERE CLIENT_ID = @clientID    
IF (@tempRecID is null) RAISERROR (@MsgNoClient, 11, 1)            
    
/*-------------------------------    
 * Verify patient id exists
 * and this patient belongs to
 * this client
 *-------------------------------*/    

SET @tempRecID = NULL    
SELECT @tempRecID = p.PATIENT_ID 
FROM PATIENTS_CLIENT  as pc
JOIN PATIENTS_PATIENT as p on p.PATIENT_ID = pc.PATIENT_ID
WHERE ((pc.CLIENT_ID = @clientID) AND (pc.PATIENT_ID = @patID))
IF (@tempRecID is null) RAISERROR (@MsgNoPat, 11, 1)            

/*-------------------------------    
 * Verify calendar and bell
 * schedule ids if they have 
 * been provided
 *-------------------------------*/    

if (@calendarID is not null)
begin
  set @tempRecID = NULL
  
  select 
    @tempRecID = id 
  from CLIENT_ATTENDANCE_CALENDAR 
  where 
    fiscalYearID = @fiscalYearID
    and id       = @calendarID
    and active   = 1
  IF (@tempRecID is null) RAISERROR ('Invalid calendar', 11, 1)    
end

if (@scheduleID is not null)
begin
  
  set @tempRecID = NULL
  
  select @tempRecID = id 
  from 
    CLIENT_ATTENDANCE_SCHEDULE
  where 
    fiscalYearID     = @fiscalYearID
    and id           = @scheduleID
    and active       = 1
  
  IF (@tempRecID is null) RAISERROR ('Invalid schedule', 11, 1)    

end


/*-------------------------------    
 * Practitioner ids
 *
 * Parse incoming ids string
 *------------------------------*/   
       
insert into @pracIDs select * from dbo.MULTI_RECORD_ID_PARSE(@pracIDsStr,',')

/*-------------------------------    
 * Practitioner ids
 *
 * Check the count.
 * Should be more than 0.
 *------------------------------*/   

set    @recCountCheck1 = 0
select @recCountCheck1 = COUNT(id) from @pracIDs 

if (@recCountCheck1 = 0)
begin
  RAISERROR ('Practitioner ids are required', 11, 1) 
end

/*-------------------------------    
 * Practitioner ids
 *  
 * Look for duplicate ids.
 * Should be none.
 *------------------------------*/   

set          @dupCount = null
select top 1 @dupCount = recid from @pracIDs group by recid having COUNT(id) > 1

if (@dupCount is not null)
begin
   RAISERROR ('One or more practitioners are duplicate', 11, 1) 
end

/*-------------------------------    
 * Practitioner ids
 * 
 * Look for proper relationship
 * with client.
 *
 * Should be no mismatches.
 *------------------------------*/   

set    @recCountCheck2 = 0
select @recCountCheck2 = count(pid.id) 
from @pracIDs                        as pid
join CLIENTS_Client                  as clc on  clc.CLIENT_ID  = @clientID
join PRACTITIONER_Client             as prc on  prc.CLIENT_ID  = clc.CLIENT_ID
join PRACTITIONER_Practitioner       as prp on  prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
where (prp.PRACTITIONER_ID = pid.recid)

if (@recCountCheck1 != @recCountCheck2)
begin
  RAISERROR ('One or more practitioners are invalid', 11, 1) 
end

/*-------------------------------    
 * Treatment details
 *
 * Make sure no bus drivers are
 * in the detail records 
 *-------------------------------*/ 

set @recCountCheck2 = 0

select
  @recCountCheck2 = COUNT(pracID)
from
(
  select 
    pracID,
    isTransGrp = CASE WHEN gg.PARENT_GROUP_ID = dbo.CONST_PRAC_GROUP_TRANS_ID() THEN 1 ELSE 0 END
  from
  (
    select pracID from @detailsTmtBS    union
    select pracID from @detailsTmtDSInd union
    select pracID from @detailsTmtDSGrp union
    select pracID from @detailsTmtAS         
  ) as dt1
  join dbo.PRACTITIONER_GROUPS_VIEW_DISP() as gd on gd.PRACTITIONER_ID = dt1.pracID
  join GROUP_Group                         as gg on gg.GROUP_ID        = gd.GROUP_ID
) as dt2
where (dt2.isTransGrp = 1)

if (@recCountCheck2 > 0)
begin
  RAISERROR ('One or more practitioners listed as providing treatment are incorrectly assigned', 11, 1) 
end

/*-------------------------------    
 * Transportation details
 *
 * Make sure just bus drivers
 * are listed
 *-------------------------------*/ 

set @recCountCheck2 = 0

select
  @recCountCheck2 = COUNT(pracID)
from
(
  select 
    pracID,
    isTransGrp = CASE WHEN gg.PARENT_GROUP_ID = dbo.CONST_PRAC_GROUP_TRANS_ID() THEN 1 ELSE 0 END
  from
  (
    select pracID from @detailsTransHmSs union
    select pracID from @detailsTransSsHm union
    select pracID from @detailsTransSsOs union
    select pracID from @detailsTransOsSs      
  ) as dt1
  join dbo.PRACTITIONER_GROUPS_VIEW_DISP() as gd on gd.PRACTITIONER_ID = dt1.pracID
  join GROUP_Group                         as gg on gg.GROUP_ID        = gd.GROUP_ID
) as dt2
where (dt2.isTransGrp = 0)

if (@recCountCheck2 > 0)
begin
  RAISERROR ('One or more practitioners listed as providing transportation are incorrectly assigned', 11, 1) 
end


IF (@saveType = dbo.CONST_SAVE_TYPE_COPY())     
BEGIN  
  SET @recID = null
END


/*============================================================
 * Overlap check
 *===========================================================*/   

/*-------------------------------    
 * Look for overlapping records
 * excluding the record specified
 * by recid    
 *------------------------------*/    

SET @dupCount = 0   
    
select 
  @dupCount = COUNT(id) 
from 
  dbo.RECURRING_SERVICES_CHECK_DUPS (@userID, @userGroup,@userRank, @clientID, @patID, @fiscalYearID, @startDate, @endDate, @recID)
   
if (@dupCount > 0) RAISERROR (@MsgDupRec, 11, 1) 

/*============================================================
 * Advisement validation
 *
 * The purpose of this validation is to warn the user if
 * values are valid, but may not produce the desired results
 *
 * This is performed before the user confirms a record save.
 *
 * However we do not show these warnings during the record
 * save nor do we prevent the save.
 *============================================================*/ 

/*-------------------------------    
 * Validation    
 *------------------------------*/    
        
IF (@validateRec = 1) 
BEGIN
  SET @recordID = 0
  RETURN(0)    
END        

/*============================================================
 * Create or modify assignment records
 *============================================================*/     
    
BEGIN TRANSACTION    
    
SET @TranOpen = 1    

/*-------------------------------    
 * Reactivate patient or 
 * practitioner if neccessary
 *------------------------------*/    

if (@userGroup = dbo.CONST_USER_GROUP_SBS())
begin

  exec dbo.RECURRING_SERVICES_SAVE_REACTIVATE_PRAC_OR_PAT_CORE 
        @userID
      , @userGroup
      , @userRank
      , @validateRec
      , @clientID    
      , @pracIDsStr
      , @patID

end 

/*-------------------------------    
 * New record
 *------------------------------*/ 

IF ((@saveType = dbo.CONST_SAVE_TYPE_NEW()) OR (@saveType = dbo.CONST_SAVE_TYPE_COPY()))    
BEGIN    
    
  SET @updateState = dbo.CONST_REC_STATE_NEW()    

  /*-------------------------------    
   * Base record
   *------------------------------*/         
 
  INSERT INTO RECURRING_SERVICES
  
    (clientID,
     patID,
     fiscalYearID,
     calendarID,
     scheduleID,
     startDate,
     endDate,   
     notes,
     created,
     createdBy,
     active)    
       
  VALUES     
    
    (@clientID, 
     @patID,
     @fiscalYearID,
     @calendarID,
     @scheduleID,
     @startDate,
     @endDate,
     @notes,
     @today,
     @userID,
     1)      
    
   SET @recordID = SCOPE_IDENTITY()
               
END  


/*-------------------------------    
 * Edit record
 *------------------------------*/     
  
ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN               
      
  SET @updateState = dbo.CONST_REC_STATE_MOD()
  
  /*-------------------------------    
   * Base record
   *------------------------------*/         
 
  UPDATE RECURRING_SERVICES  
  SET
    clientID      = @clientID,
    patID         = @patID,
    fiscalYearID  = @fiscalYearID,
    calendarID    = @calendarID,  
    scheduleID    = @scheduleID,
    startDate     = @startDate,
    endDate       = @endDate,   
    notes         = @notes
  WHERE ID = @recordID 
                                            
END 

/*-------------------------------    
 * Invalid save type
 *------------------------------*/  
    
ELSE     
BEGIN    
  RAISERROR ('Unknown save type', 11, 1)    
END            


/*-------------------------------    
 * Detail Records for both
 * new and edit
 *------------------------------*/ 
 
IF (@saveType != dbo.CONST_SAVE_TYPE_DELETE())
BEGIN

  /*-------------------------------    
   * Remove old detail records for
   * new and edit
   *------------------------------*/ 
  
  DELETE RECURRING_SERVICES_DETAILS_PRAC                         WHERE rcrSvcID = @recordID 
  DELETE RECURRING_SERVICES_DETAILS_SVC_MINUTE_BASED             WHERE rcrSvcID = @recordID
  DELETE RECURRING_SERVICES_DETAILS_SVC_SCHEDULE_OR_MINUTE_BASED WHERE rcrSvcID = @recordID
  DELETE RECURRING_SERVICES_DETAILS_SVC_MILE_BASED               WHERE rcrSvcID = @recordID

  /*-------------------------------    
   * Details - Practitioners
   *------------------------------*/         

  INSERT INTO RECURRING_SERVICES_DETAILS_PRAC
    (rcrSvcID,     pracID,     pracDispGrpID,     tmtBS,     tmtDSInd,     tmtDSGrp,     tmtAS,     transHmSs,     transSsHm,     transSsOs,     transOsSs,     realNames)    SELECT 
     @recordID,
     pracID, 
     gd.GROUP_ID as pracDispGrpID,
     tmtBS,
     tmtDSInd,
     tmtDSGrp,
     tmtAS,
     transHmSs,
     transSsHm,
     transSsOs,
     transOsSs,
     realNames 
   FROM @detailsPracs                       as dp
   JOIN dbo.PRACTITIONER_GROUPS_VIEW_DISP() as gd on gd.PRACTITIONER_ID = dp.pracID

   
   /*-------------------------------    
    * Details - Treatment
    * Before School - Ind
    *------------------------------*/         
   
   INSERT INTO RECURRING_SERVICES_DETAILS_SVC_MINUTE_BASED
     (rcrSvcID,
      pracID,
      tmtWhen, 
      tmtHow, 
      inIEP, 
      isMedNesc, 
      numMinsDaily, 
      numMinsMon,
      numMinsTue,
      numMinsWed,
      numMinsThu,
      numMinsFri)
   SELECT 
     @recordID,     
     pracID,
     dbo.CONST_SERVICES_TMT_WHEN_BS(),
     dbo.CONST_SERVICES_TMT_HOW_IND(),
     inIEP,
     isMedNesc,
     numMinsDaily,
     numMinsMon,
     numMinsTue,
     numMinsWed,
     numMinsThu,
     numMinsFri     
   FROM @detailsTmtBS 

   /*-------------------------------    
    * Details - Treatment
    * After School - Ind
    *------------------------------*/         
     
   INSERT INTO RECURRING_SERVICES_DETAILS_SVC_MINUTE_BASED
     (rcrSvcID,
      pracID,
      tmtWhen, 
      tmtHow, 
      inIEP, 
      isMedNesc, 
      numMinsDaily, 
      numMinsMon,
      numMinsTue,
      numMinsWed,
      numMinsThu,
      numMinsFri)
   SELECT 
     @recordID,     
     pracID,
     dbo.CONST_SERVICES_TMT_WHEN_AS(),
     dbo.CONST_SERVICES_TMT_HOW_IND(),
     inIEP,
     isMedNesc,
     numMinsDaily,
     numMinsMon,
     numMinsTue,
     numMinsWed,
     numMinsThu,
     numMinsFri     
   FROM @detailsTmtAS 

   /*-------------------------------    
    * Details - Treatment
    * During School - Ind
    *------------------------------*/         
   
   INSERT INTO RECURRING_SERVICES_DETAILS_SVC_SCHEDULE_OR_MINUTE_BASED
     (rcrSvcID,
      pracID,
      tmtWhen, 
      tmtHow, 
      inIEP, 
      isMedNesc, 
      scheduleDaily, 
      scheduleMon,
      scheduleTue,
      scheduleWed,
      scheduleThu,
      scheduleFri,
      numMinsDaily, 
      numMinsMon,
      numMinsTue,
      numMinsWed,
      numMinsThu,
      numMinsFri)
   SELECT 
     @recordID,     
     pracID,
     dbo.CONST_SERVICES_TMT_WHEN_DS(),
     dbo.CONST_SERVICES_TMT_HOW_IND(),
     inIEP,
     isMedNesc,
     scheduleDaily, 
     scheduleMon,
     scheduleTue,
     scheduleWed,
     scheduleThu,
     scheduleFri,
     numMinsDaily,
     numMinsMon,
     numMinsTue,
     numMinsWed,
     numMinsThu,
     numMinsFri     
   FROM @detailsTmtDSInd 

   /*-------------------------------    
    * Details - Treatment
    * During School - Grp
    *------------------------------*/         
   
   INSERT INTO RECURRING_SERVICES_DETAILS_SVC_SCHEDULE_OR_MINUTE_BASED
     (rcrSvcID,
      pracID,
      tmtWhen, 
      tmtHow, 
      inIEP, 
      isMedNesc, 
      scheduleDaily, 
      scheduleMon,
      scheduleTue,
      scheduleWed,
      scheduleThu,
      scheduleFri,
      numMinsDaily, 
      numMinsMon,
      numMinsTue,
      numMinsWed,
      numMinsThu,
      numMinsFri)
   SELECT 
     @recordID,     
     pracID,
     dbo.CONST_SERVICES_TMT_WHEN_DS(),
     dbo.CONST_SERVICES_TMT_HOW_GRP(),
     inIEP,
     isMedNesc,
     scheduleDaily, 
     scheduleMon,
     scheduleTue,
     scheduleWed,
     scheduleThu,
     scheduleFri,
     numMinsDaily,
     numMinsMon,
     numMinsTue,
     numMinsWed,
     numMinsThu,
     numMinsFri     
   FROM @detailsTmtDSGrp


   /*-------------------------------    
    * Details - Transportation
    * Home to School
    *------------------------------*/               
   
   INSERT INTO RECURRING_SERVICES_DETAILS_SVC_MILE_BASED
     (rcrSvcID,
      pracID,
      transFrom, 
      transTo, 
      inIEP, 
      isMedNesc, 
      numMilesDaily, 
      numMilesMon,
      numMilesTue,
      numMilesWed,
      numMilesThu,
      numMilesFri)
   SELECT 
     @recordID,     
     pracID,
     dbo.CONST_SERVICES_TRANS_LOCATION_HOME(),
     dbo.CONST_SERVICES_TRANS_LOCATION_SCHOOL(),
     inIEP,
     isMedNesc,
     numMilesDaily, 
     numMilesMon,
     numMilesTue,
     numMilesWed,
     numMilesThu,
     numMilesFri     
   FROM @detailsTransHmSs

           
   /*-------------------------------    
    * Details - Transportation
    * School to Home
    *------------------------------*/         
   
   INSERT INTO RECURRING_SERVICES_DETAILS_SVC_MILE_BASED
     (rcrSvcID,
      pracID,
      transFrom, 
      transTo, 
      inIEP, 
      isMedNesc, 
      numMilesDaily, 
      numMilesMon,
      numMilesTue,
      numMilesWed,
      numMilesThu,
      numMilesFri)
   SELECT 
     @recordID,     
     pracID,
     dbo.CONST_SERVICES_TRANS_LOCATION_SCHOOL(),
     dbo.CONST_SERVICES_TRANS_LOCATION_HOME(),
     inIEP,
     isMedNesc,
     numMilesDaily, 
     numMilesMon,
     numMilesTue,
     numMilesWed,
     numMilesThu,
     numMilesFri     
   FROM @detailsTransSsHm


  /*-------------------------------    
    * Details - Transportation
    * School to Offsite Service
    *------------------------------*/         
   
   INSERT INTO RECURRING_SERVICES_DETAILS_SVC_MILE_BASED
     (rcrSvcID,
      pracID,
      transFrom, 
      transTo, 
      inIEP, 
      isMedNesc, 
      numMilesDaily, 
      numMilesMon,
      numMilesTue,
      numMilesWed,
      numMilesThu,
      numMilesFri)
   SELECT 
     @recordID,     
     pracID,
     dbo.CONST_SERVICES_TRANS_LOCATION_SCHOOL(),
     dbo.CONST_SERVICES_TRANS_LOCATION_OFFSITE(),
     inIEP,
     isMedNesc,
     numMilesDaily, 
     numMilesMon,
     numMilesTue,
     numMilesWed,
     numMilesThu,
     numMilesFri     
   FROM @detailsTransSsOs

  /*-------------------------------    
    * Details - Transportation
    * Offsite Service to School
    *------------------------------*/         
   
   INSERT INTO RECURRING_SERVICES_DETAILS_SVC_MILE_BASED
     (rcrSvcID,
      pracID,
      transFrom, 
      transTo, 
      inIEP, 
      isMedNesc, 
      numMilesDaily, 
      numMilesMon,
      numMilesTue,
      numMilesWed,
      numMilesThu,
      numMilesFri)
   SELECT 
     @recordID,     
     pracID,
     dbo.CONST_SERVICES_TRANS_LOCATION_OFFSITE(),
     dbo.CONST_SERVICES_TRANS_LOCATION_SCHOOL(),
     inIEP,
     isMedNesc,
     numMilesDaily, 
     numMilesMon,
     numMilesTue,
     numMilesWed,
     numMilesThu,
     numMilesFri     
   FROM @detailsTransOsSs

END


/*============================================================
 * Create audit record
 *============================================================*/  

EXEC RECURRING_SERVICES_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
       
/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

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

GRANT EXECUTE ON TYPE::RecurringServiceDetailsPracInfoAll              TO [webuser]
GO
GRANT EXECUTE ON TYPE::RecurringServiceDetailsSvcMinuteBased           TO [webuser]
GO
GRANT EXECUTE ON TYPE::RecurringServiceDetailsSvcScheduleOrMinuteBased TO [webuser]
GO
GRANT EXECUTE ON TYPE::RecurringServiceDetailsSvcMileBased             TO [webuser]
GO
GRANT EXECUTE ON  [dbo].[RECURRING_SERVICES_Save] TO [webuser]
GO

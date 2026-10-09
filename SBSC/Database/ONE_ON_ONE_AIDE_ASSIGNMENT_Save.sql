USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[ONE_ON_ONE_AIDE_ASSIGNMENT_Save]     
 (@userID            BIGINT,    
  @userGroup         INT,    
  @userRank          INT,    
  @clientID          BIGINT, 
  @patID             BIGINT, 
  @siteID            BIGINT,
  @pracID            BIGINT,
  @aideLastName      VARCHAR(1000),
  @aideFirstName     VARCHAR(1000), 
  @oneOnOneAideType  VARCHAR(10),
  @aideSvcsAuthInIEP BIT,
  @svcsAreMedNec     BIT,
  @busMinsAM         INT,
  @siteMins          INT,
  @busMinsPM         INT,  
  @startDate         DATETIME,
  @endDate           DATETIME,
  @fiscalYearID      INT,
  @calendarID        BIGINT,
  @scheduleID        BIGINT,                     
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
  @MsgNoSite         VARCHAR(1000),
  @MsgNoPrac         VARCHAR(1000),
  @MsgInvAidType     VARCHAR(1000),
  @MsgDataError      VARCHAR(1000),
  @MsgNotActive      VARCHAR(1000),     
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * ONE_ON_ONE_AIDE_ASSIGNMENT_Save */    
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

DECLARE @today         AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen      AS BIT            -- Is a transaction open    
DECLARE @dupCount      AS INT            -- Duplicate counter used for validation    
DECLARE @updateState   AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @canEdit       AS BIT   
DECLARE @tempRecID     AS BIGINT         -- Used for determining if a rec exists    
DECLARE @tempName      AS VARCHAR(100)
DECLARE @auditRecID    AS BIGINT         
DECLARE @msg           AS VARCHAR(8000)
DECLARE @msgParts      AS VARCHAR(8000)

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
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
    
/*============================================================
 * Init worker variables
 *============================================================*/  

SET @today  = GETDATE()    

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
  
  SELECT 
    @recordID = ID, 
    @canEdit  = Active 
  from 
    ONE_ON_ONE_AIDE_ASSIGNMENT
  where 
    ID = @recID

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
 * Verify client id exists    
 *-------------------------------*/    

SET @tempRecID = NULL    
SELECT @tempRecID = CLIENT_ID 
FROM CLIENTS_CLIENT 
WHERE CLIENT_ID = @clientID    
IF (@tempRecID is null) RAISERROR (@MsgNoClient, 11, 1)            
    
/*-------------------------------    
 * Verify patient id exists
 *-------------------------------*/    

SET @tempRecID = NULL    
SELECT @tempRecID = p.PATIENT_ID 
FROM PATIENTS_CLIENT  as pc
JOIN PATIENTS_PATIENT as p on p.PATIENT_ID = pc.PATIENT_ID
WHERE ((pc.CLIENT_ID = @clientID) AND (pc.PATIENT_ID = @patID))
IF (@tempRecID is null) RAISERROR (@MsgNoPat, 11, 1)            

/*-------------------------------    
 * Verify one on one aid type
 *-------------------------------*/    

SET @tempRecID = NULL    
SELECT @tempRecID = count([Value]) 
from dbo.ONE_ON_ONE_AIDE_TYPES_VIEW() 
where [Value] = @oneOnOneAideType
IF (@tempRecID <> 1) RAISERROR (@MsgInvAidType, 11, 1)       

/*-------------------------------    
 * Verify practitioner data if
 * it has been provided
 *-------------------------------*/    

IF (@pracID is not null)
BEGIN

 /*-------------------------------    
  * Practitioner 
  *-------------------------------*/    

  SET @tempRecID = NULL    
  SELECT @tempRecID = p.PRACTITIONER_ID       
  FROM PRACTITIONER_Client       as pc
  JOIN PRACTITIONER_Practitioner as p on p.PRACTITIONER_ID = pc.PRACTITIONER_ID
  WHERE((pc.CLIENT_ID = @clientID) AND (pc.PRACTITIONER_ID = @pracID))
  IF (@tempRecID is null) RAISERROR (@MsgNoPrac, 11, 1)       

  /*-------------------------------    
   * Is the practitioners discipline
   * compatible with the 1:1 type
   * selected?
   *-------------------------------*/    
 
  SET @tempRecID = NULL   
  select distinct @tempRecID = pg.PRACTITIONER_ID
  from PRACTITIONER_GROUPS_VIEW_CORE(12) as pg
  join SERVICES_VIEW_ALL()               as sv on sv.prac_group_id = pg.group_id
  where ((pg.PRACTITIONER_ID = @pracID) and (sv.one_on_one_aide_proc_for = @oneOnOneAideType))
  IF (@tempRecID is null) RAISERROR ('The aide type selected is not compatible with the selected practitioners discipline', 11, 1)        

END
    
SET @dupCount = 0   
   
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
  
IF (@validateRec = 1) 
BEGIN

/*-------------------------------    
 * Look for duplicate records 
 * excluding the record specified
 * by recid    
 *------------------------------*/    

  SET @dupCount = 0   
    
  select 
    @dupCount = COUNT(id) 
  from 
    ONE_ON_ONE_AIDE_ASSIGNMENT
  where
  ((@recID IS NULL) OR (ID != @recID)) 
  and (pracID           = @pracID)
  and (patID            = @patID)
  and ((@startDate between startDate and endDate) or (@endDate between startDate and endDate))
  and (Active = 1) 

  IF (@dupCount > 0)
  BEGIN
    SET @msgParts =  dbo.RPT_DATE_FMT(@startDate) + '|' + dbo.RPT_DATE_FMT(@endDate) + '|' + CONVERT(VARCHAR(10),@dupCount)
    SET @msg = dbo.STRING_CREATE(@msgDupRec, @msgParts, NULL, NULL)    
    SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,@msg,dbo.CONST_RET_DUP_RECORD())    
  END
  
  SET @recordID = 0
  RETURN(0)    
END        

/*============================================================
 * Create or modify assignment records
 *============================================================*/     
    
BEGIN TRANSACTION    
    
SET @TranOpen = 1    

/*-------------------------------    
 * New record
 *------------------------------*/ 

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN    
    
  SET @updateState = dbo.CONST_REC_STATE_NEW()    
        
  INSERT INTO ONE_ON_ONE_AIDE_ASSIGNMENT
    (clientID,
     patID,
     siteID,
     pracID,
     aideLastName,
     aideFirstName,
     oneOnOneAideType,
     aideSvcsAuthInIEP,
     svcsAreMedNes,
     busMinsAM,
     siteMins,
     busMinsPM,
     startDate,
     endDate,
     fiscalYearID,
     calendarID,
     scheduleID,
     notes,
     created,
     createdBy,
     active)    
       
  VALUES     
    
    (@clientID, 
     @patID,
     @siteID,
     @pracID,
     @aideLastName,
     @aideFirstName,
     @oneOnOneAideType,
     @aideSvcsAuthInIEP,
     @svcsAreMedNec,
     @busMinsAM,
     @siteMins,
     @busMinsPM,
     @startDate,
     @endDate,
     @fiscalYearID,
     @calendarID,
     @scheduleID,
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
                      
  UPDATE ONE_ON_ONE_AIDE_ASSIGNMENT
  SET
    clientID          = @clientID, 
    patID             = @patID,
    siteID            = @siteID,
    pracID            = @pracID,
    aideLastName      = @aideLastName,
    aideFirstName     = @aideFirstName,
    oneOnOneAideType  = @oneOnOneAideType,
    aideSvcsAuthInIEP = @aideSvcsAuthInIEP,
    svcsAreMedNes     = @svcsAreMedNec,
    busMinsAM         = @busMinsAM,
    siteMins          = @siteMins,
    busMinsPM         = @busMinsPM,
    startDate         = @startDate,
    endDate           = @endDate,
    fiscalYearID      = @fiscalYearID,
    calendarID        = @calendarID,
    scheduleID        = @scheduleID,
    notes             = @notes,
    lastUpdated       = @today,
    lastUpdatedBy     = @userID
     
  WHERE 
    ID = @recordID
                
END 

/*-------------------------------    
 * Invalid save type
 *------------------------------*/  
    
ELSE     
BEGIN    
  RAISERROR ('Unknown save type', 11, 1)    
END            

/*============================================================
 * Create audit record
 *============================================================*/  

EXEC ONE_ON_ONE_AIDE_ASSIGNMENT_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
       
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

GRANT EXECUTE ON  [dbo].[ONE_ON_ONE_AIDE_ASSIGNMENT_Save] TO [webuser]
GO

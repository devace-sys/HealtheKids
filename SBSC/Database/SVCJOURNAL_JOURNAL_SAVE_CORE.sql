USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_SAVE_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_SAVE_CORE
GO

/*-------------------------------
 * Create
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_SAVE_CORE] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT    
  , @clientID          BIGINT
  , @pracID            BIGINT
  , @patID             BIGINT
  , @reference         VARCHAR(500)
  , @dos               DATETIME
  , @patAbsent         bit
  , @editDelReason     VARCHAR(7000)
  , @validateRec       BIT
  , @saveType          INT    
  , @recID             BIGINT
  , @MsgNoRec            VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgDupRec           VARCHAR(1000)  
  , @MsgDataError        VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)
  , @msgInvCombo         VARCHAR(1000)    
  , @MsgMinReq           VARCHAR(1000)
  , @MsgMinDef           VARCHAR(1000)    
  , @MsgMilReq           VARCHAR(1000)    
  , @MsgPatElg           VARCHAR(1000)
  , @MsgPatDOBGteDOS     VARCHAR(1000)
  , @MsgPatAbsent        VARCHAR(1000)
  , @MsgFutureDOS        VARCHAR(1000)
  , @spDetails           VARCHAR(8000) OUTPUT
  , @recordID            BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_SAVE_CORE */    
/**    
 * Creates or edits new service journal for the day
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   patID           Patient id
 * @param   dos             Service date
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
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/  

DECLARE @today          AS DATETIME       -- Current date/time stamp    
declare @dob            AS date   = NULL

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
   
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
   
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*============================================================
 * See if the clientID and patID combo is valid
 * also retrieve some data we will need if the patient is
 * absent.
 *============================================================*/  

SET @dob = NULL

select top 1

    @dob = pap.DATE_OF_BIRTH

from dbo.CLIENTS_Client   AS cc
join dbo.PATIENTS_Client  AS pac ON pac.CLIENT_ID  = cc.CLIENT_ID
join dbo.PATIENTS_Patient AS pap ON pap.PATIENT_ID = pac.PATIENT_ID

where (
      (cc.CLIENT_ID   = @clientID)
  and (pap.PATIENT_ID = @patID)
)

if (@dob IS NULL)
begin
  RAISERROR ('Invalid client or patient id', 11, 1)
end

/*============================================================
 * Check to see if there is already an active journal for 
 * this client patient and dos combination
 *===========================================================*/  

declare @existingJournalID        as bigint = null
declare @existingJournalCompleted as bit    = null

select top 1

    @existingJournalID         = sj.id
  , @existingJournalCompleted  = sj.completed
    
from dbo.SvcJournals as sj
where (     
      (sj.clientID = @clientID) 
  and (sj.patID    = @patID) 
  and (sj.dos      = @dos)
  and (sj.active   = 1) 
)

if (@existingJournalCompleted = 1)
begin
  RAISERROR ('This journal/procedure log has been closed', 11, 1)
end


/*============================================================
 * Validation
 *============================================================*/  

if (@validateRec = 1)
begin
 
  if(@patAbsent = 1)
    set @spDetails = dbo.UPDATE_DETAILS(@spDetails, 'The patient was marked as absent', dbo.CONST_RET_WARN())
 
  set @recordID = 0
  RETURN(0)    
end      

/*============================================================
 * New records 
 *
 * 1. If the patient is marked as ABSENT
 *
 *   1.1. Create a new service record and NO journal
 *
 * 2. If the patient is marked as present
 *
 *   2.1. Create a new journal if one does not exist 
 *   2.2. OR return the record id of the existing journal
 *===========================================================*/  

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())

begin

  /*-------------------------------
   * This is a new record and the
   * patient is marked as absent
   * Create a service record
   * and get out.  We don't create
   * a journal at all.
   *------------------------------*/

  IF (@patAbsent = 1)
  begin
 
    declare @planType       AS int           = NULL
    declare @groupID        AS bigint        = NULL
    declare @nameID         AS bigint        = NULL
    declare @orpDocReq      AS bit           = null
    declare @numMins        AS int           = 0
    declare @iep            AS bit           = 1
    declare @notes          AS varchar(7000) = ''
    declare @svcRecID       AS bigint        = NULL
   
    /*-------------------------------
     * Determine plan type
     *------------------------------*/

    SET @planType = dbo.DOS_DOB_IEP_TO_PLAN_TYPE(@dos,@dob,@iep)

    /*-------------------------------
     * Get prac disp group
     *------------------------------*/
 
    select top 1
   
      @groupID = prg.GROUP_ID
   
    from dbo.PRACTITIONER_GROUPS AS prg
    where (
          (prg.PRACTITIONER_ID = @pracID)
      and (prg.GROUP_TYPE IN (1,2))
    )
 
    /*-------------------------------
     * Get default service for
     * prac group from journal
     * event data and service
     * data
     *------------------------------*/
   
    select top 1
   
        @nameID    = sva.SERVICE_NAME_ID
      , @orpDocReq = sva.SERVICE_ENTRY_ORP_DOCUMENT_REQUIRED
    from dbo.SvcJournal_Event_Types_PracClass_Groups_ServiceNames   AS gp
    join dbo.SvcJournal_Event_Types                                 AS et ON et.id = gp.eventType
   
    outer apply (
   
      select top 1
        *
      from dbo.SERVICES_VIEW_ALL_CORE ( null
                                       , @groupID
                                       , @planType
                                       , dbo.CONST_SERVICES_TREATMENT()
                                       , NULL
                                       , 1
                                       , 1
                                       , @dos
                                       , 1 )
      where (SERVICE_NAME_ID = gp.nameID)
    ) as sva
   
    where (
          (gp.groupID   = @groupID)
     and  (gp.planType  = @planType)
     and  (et.isDefault = 1)
    )
 
    /*-------------------------------
     * Create service record
     *------------------------------*/
   
    EXEC dbo.SERVICE_RECORD_Save_Core
      @userID  
    , @userGroup
    , @userRank
	, 1 /* Gen claims */
    , 11
    , @reference
    , ''    
    , ''    
    , @dos
    , @clientID
    , @pracID
    , @patID
    , @iep
    , @nameID
    , @orpDocReq 
    , null        /* No ORP doc since this is an absent */
    , null    
    , 0
    , 0
    , 0
    , 0
    , 0
    , null
    , @numMins
    , 0    
    , 0    
    , 0    
    , 0    
    , 0
    , 0    
    , 0
    , 0
    , @patAbsent
	, 0
	, 0
	, null /* @attendanceSelectionID*/  
    , @notes
	, null
	, null
	, null
	, 0 /* goal tracking*/
	, 1 /* Billing program */
	, 0    /* Has fillable pdf (TODO: Add these 3 parms) */
    , '[]' /* Fillable pdf selections */
	, '[]' /* Fillable pdf answers*/
    , @editDelReason
    , @validateRec
    , @saveType
    , @recID
    , @msgDupRec
    , @msgInvCombo
    , @MsgNoRec  
    , @MsgNoEdit    
    , @MsgDataError
    , @MsgMinReq    
    , @MsgMinDef    
    , @MsgMilReq    
    , @MsgPatElg
    , @MsgPatDOBGteDOS
    , @MsgNotActive
    , @MsgPatAbsent
    , @MsgFutureDOS
    , @spDetails     OUTPUT
    , @svcRecID      OUTPUT  
 
  end
 
  /*-------------------------------
   * The patient is marked as 
   * present.  Go ahead and ...
   *------------------------------*/

  else
  begin
   
    /*-------------------------------
     * Create a journal if one does
     * already exist
     *------------------------------*/
    
    if (@existingJournalID is null)
    begin  
    
      INSERT INTO dbo.SvcJournals (
          clientID
        , patID
        , dos
        , patAbsent
        , openingPracID
        , created
        , createdBy )
     
      VALUES (
          @clientID
        , @patID
        , @dos
        , @patAbsent
        , @pracID
        , @today
        , @userID  
      )
       
      SET @recordID = SCOPE_IDENTITY()
    
    end
    
    /*-------------------------------
     * Return the ID of the open
     * journal that exists
     *------------------------------*/

    else
    
    begin
      SET @recordID = @existingJournalID
    end
    
  end

end

/*============================================================
 * Edit existing.  
 *
 * Note:
 *
 * If patient is marked as absent as part of the edit
 * we preserve the journal records that exist.  There will
 * be no journals for those who went to create new journals
 * initially and marked the patient as absent
 *===========================================================*/  

else IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  -- make sure we don't change the data to a journal that already exists
  if (isnull(@existingJournalID, 0) = 0)
  begin
	  update dbo.SvcJournals
	  set  
		  patID          = @patID
		, dos            = @dos
		, patAbsent      = @patAbsent  
		, lastModified   = @today
		, lastModifiedBy = @userID
	  where ((clientID = @clientID) AND (id = @recID) AND (completed = 0) AND (active = 1))
 
	  set @recordID = @recID
  end
  else 
  begin
	set @recordID = @existingJournalID
  end

end

/*============================================================
 * All done
 *============================================================*/  
   
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
          
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
    
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
   
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_SAVE_CORE] TO [webuser]
GO
USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_CLOSE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_CLOSE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_CLOSE]     
 (@userID              BIGINT,    
  @userGroup           INT,    
  @userRank            INT,    
  @clientID            BIGINT, 
  @pracID              BIGINT,
  @patID               BIGINT,
  @reference           VARCHAR(500),           
  @editDelReason       VARCHAR(7000),    
  @validateRec         BIT,    
  @saveType            INT,    
  @recID               BIGINT,
  @MsgNoRec            VARCHAR(1000),    
  @MsgNoEdit           VARCHAR(1000), 
  @MsgDupRec           VARCHAR(1000),   
  @MsgDataError        VARCHAR(1000),
  @MsgNotActive        VARCHAR(1000),  
  @msgInvCombo         VARCHAR(1000),    
  @MsgMinReq           VARCHAR(1000),    
  @MsgMinDef           VARCHAR(1000),     
  @MsgMilReq           VARCHAR(1000),    
  @MsgPatElg           VARCHAR(1000),
  @MsgPatDOBGteDOS     VARCHAR(1000),
  @MsgPatAbsent        VARCHAR(1000), 
  @MsgFutureDOS        VARCHAR(1000),
  @spDetails           VARCHAR(8000) OUTPUT,    
  @recordID            BIGINT        OUTPUT)
AS    
BEGIN     
    
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_CLOSE */    
/**    
 * Creates or edits new service journal for the day
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   pracID          Practitioner id
 * @param   patID           Patient id
 * @param   dos             Service date
 * @parm    svcType         Type of service (1,2,3,4)
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

DECLARE @today           AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen        AS BIT            -- Is a transaction open    
DECLARE @completed       AS BIT = 0
DECLARE @patAbsent       AS BIT = 0

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
 * Search for journal
 *============================================================*/  

select 

   @recordID   = id 
  ,@completed  = completed 

from dbo.SvcJournals as sj 

where (
      (sj.clientID = @clientID) 
  and (sj.id       = @recID) 
  and (sj.active   = 1)
)

/*============================================================
 * If journal is not found or is no longer active get out
 *============================================================*/  

if (@recordID is null)
  RAISERROR ('Journal not found or journal has been deleted.', 11, 1)   

/*============================================================
 * If journal has already been closed let user know
 *============================================================*/  

if (@completed = 1) 
  RAISERROR ('Journal has already been closed', 11, 1)   

/*============================================================
 * Validation
 *============================================================*/  

declare @journalProblems as table (
   journalID bigint
  ,pracID    bigint
  ,pracName  varchar(1000)
  ,retState  int
  ,retStatus varchar(500)
  ,problem   varchar(1000)
)

declare @numWarn as int = 0
declare @numErr  as int = 0

insert into @journalProblems
select * from dbo.SvcJournal_Journal_Validate(@userID,@userGroup,@userRank,@clientID,@recID)

select @numWarn = COUNT(journalID) from @journalProblems where (retState = dbo.CONST_RET_WARN())
select @numErr  = COUNT(journalID) from @journalProblems where (retState = dbo.CONST_RET_ERR())

if (@numWarn > 0) 
begin
  set @spDetails = dbo.UPDATE_DETAILS(@spDetails,'Please consider the warnings shown above before closing the journal.',dbo.CONST_RET_WARN())
end

if (@numErr  > 0) 
begin
  RAISERROR ('Please correct the problems with the journal shown above.  The journal cannot be closed until problems are corrected.',11, 1)
end

/*============================================================
 * Check to see if we can still edit or delete this journal
 * This will only be of concern during a reclose
 *===========================================================*/   

declare @canStillEditOrDelJournal as bit = null
  
set @canStillEditOrDelJournal = dbo.SvcJournal_Can_Edit (@userID,@userGroup,@userRank,@clientID,@recID)

if ((@canStillEditOrDelJournal = 0) or (@canStillEditOrDelJournal is null)) 
begin
  RAISERROR ('This journal cannot be closed.', 11, 1)       
end

/*============================================================
 * If we are validating get out
 *===========================================================*/   

IF (@validateRec = 1) 
BEGIN  
  RETURN(0)    
END        

BEGIN TRANSACTION
SET @TranOpen = 1

/*============================================================
 * Update service journals
 *============================================================*/  

update dbo.SvcJournals
set    
    lastmodified        = @today
  , lastModifiedBy      = @userID
  , completed           = 1
  , closingPracID       = @pracID
where ((clientID = @clientID) and (id = @recID) and (active = 1) and (completed = 0))

set @saveType = dbo.CONST_SAVE_TYPE_NEW()

/*============================================================
 * Manage Service Records -- Create New or Edit
 *============================================================*/  

exec dbo.SVCJOURNAL_MANAGE_SERVICE_RECORDS
      @userID
    , @userGroup    
    , @userRank
    , @clientID
    , @recID
    , @reference
    , @editDelReason
    , @validateRec
    , @saveType
    , @recID
    , @MsgNoRec
    , @MsgNoEdit
    , @MsgDupRec
    , @MsgDataError
    , @MsgNotActive
    , @msgInvCombo
    , @MsgMinReq
    , @MsgMinDef
    , @MsgMilReq
    , @MsgPatElg
    , @MsgPatDOBGteDOS
    , @MsgPatAbsent
    , @MsgFutureDOS
    , @spDetails OUTPUT
    , @recordID  OUTPUT
  
  
/*============================================================
 * If not all practitioners have made service record approval
 * related changes, reopen the journal
 *
 * TODO: This is a hack.  Figure out a way to determine
 * who still needs to make changes before we close the journal
 * and prevent the journal close instead of reopening.
 *============================================================*/  

/* Count service records that have been reveiwed and held for approval */

declare @numRemainingHeld as int = 0

select 
  @numRemainingHeld = count(sra.id)
from dbo.SvcJournal_Service_Records as sjsr
join dbo.SERVICE_RECORDS_APPROVAL   as sra on sra.svcRecID = sjsr.svcRecID
where (
      (sjsr.journalID = @recID)
  and (sra.reviewed   = 1)
  and (sra.approved   = 0)
)

/* If there are 1 or more then the manage service records routine preserved the prior service records 
   because there were no changes and there are still people who need to make changes, so reopen */
   
if (@numRemainingHeld > 0)
begin

  update dbo.SvcJournals
  set    
      lastmodified        = @today
    , lastModifiedBy      = @userID
    , completed           = 0
  where ((clientID = @clientID) and (id = @recID) and (active = 1))

end

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


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_CLOSE] TO [webuser]
GO

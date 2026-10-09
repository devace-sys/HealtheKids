USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_REOPEN_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_REOPEN_CORE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_REOPEN_CORE]     
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
 * SVCJOURNAL_JOURNAL_REOPEN_CORE */    
/**    
 * Reopens journal
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

DECLARE @today          AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen       AS BIT            -- Is a transaction open    
DECLARE @completed      AS BIT = 0
DECLARE @revisionID     AS BIGINT = null
DECLARE @numSentSvcs    as INT = 0

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
 * Find record
 *============================================================*/  

select top 1
  @recordID = id 
from dbo.SvcJournals as sj 
where 
      sj.clientID  = @clientID 
  and sj.id        = @recID 
  and sj.active    = 1 
  and sj.completed = 1

/*============================================================
 * If not found exit silently.
 *
 * We exit silently because this is called by the service
 * record supervision system and we want to exit from that
 * without any complaints from the journal if the supervising
 * prac is requesting holds for more than one service record
 * related to the journal.  The reopen only needs to occur once. 
 * This will also take care of cases where someone is trying to
 * reopen a journal thats already been reopened.
 *============================================================*/  

if (@recordID is null) 
  RETURN(0)

/*============================================================
 * Now check to see if the service records associated with
 * the journal have been sent.  If so we cannot reopen
 * and we want to exit with an error.
 *============================================================*/  

declare @canStillEditOrDelJournal as bit = null

set @canStillEditOrDelJournal = dbo.SvcJournal_Can_Edit(@userID,@userGroup,@userRank,@clientID,@recID)

if ((@canStillEditOrDelJournal = 0) or (@canStillEditOrDelJournal is null)) 
begin
  RAISERROR ('This journal cannot be reopened.', 11, 1)       
end

/*============================================================
 * If we are validating get out
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  RETURN(0)    
END        

/*============================================================
 * Create revision record for journal header record
 *============================================================*/  

insert into dbo.SvcJournals_Revisions
select top 1 * from dbo.SvcJournals as sj where sj.id = @recID 
  
set @revisionID = SCOPE_IDENTITY()

/*============================================================
 * Create revision records for journal entry records
 *============================================================*/  

insert into dbo.SvcJournal_Event_Entries_Revisions  
select @revisionID as revisionID,sjee.* from dbo.SvcJournal_Event_Entries as sjee where journalID = @recID

/*============================================================
 * Create revision records for journal entry service record 
 * records
 *============================================================*/  

insert into dbo.SvcJournal_Service_Records_Revisions
select @revisionID as revisionID, sjsr.* from dbo.SvcJournal_Service_Records as sjsr where journalID = @recID

/*============================================================
 * Create revision records for journal entry service record
 * time block records
 *============================================================*/  

insert into dbo.SvcJournal_Service_Records_Time_Blocks_Revisions 
select @revisionID as revisionID, sjsrtb.* from dbo.SvcJournal_Service_Records_Time_Blocks as sjsrtb where journalID = @recID

/*============================================================
 * Create revision records for journal entry form data
 * (for service selection)
 *============================================================*/  

insert into dbo.SvcJournal_Event_Entries_Form_Builder_Data_Revisions  
select @revisionID as revisionID,sjeefbd.*
from dbo.SvcJournal_Event_Entries as sjee
join dbo.SvcJournal_Event_Entries_Form_Builder_Data as sjeefbd on sjeefbd.entryID = sjee.id
where sjee.journalID = @recID

/*============================================================
 * Create revision records for journal entry form data
 * (for note criteria)
 *============================================================*/  

insert into dbo.SvcJournal_Event_Entries_Note_Criteria_Questions_Answers_Revisions  
select @revisionID as revisionID,sjeencqa.*
from dbo.SvcJournal_Event_Entries as sjee
join dbo.SvcJournal_Event_Entries_Note_Criteria_Questions_Answers as sjeencqa on sjeencqa.entryID = sjee.id
where sjee.journalID = @recID

/*============================================================
 * Update service journals to indicate it is open again
 *============================================================*/  

update dbo.SvcJournals
set    
    lastmodified        = @today
  , lastModifiedBy      = @userID
  , completed           = 0
  , currentRevision     = @revisionID
where (id = @recordID)


/*============================================================
 * All done, commit changes and get out
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


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_REOPEN_CORE] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_SVC_REC_APPROVAL_ID') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_SVC_REC_APPROVAL_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_SVC_REC_APPROVAL_ID
( @userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @clientID      BIGINT,
  @recIDMulti    varchar(max), 
  @approved      BIT,
  @sendReviewNotesToRenderingPrac BIT,
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)   

AS
BEGIN


/***************************************************************************    
 * SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_SVC_REC_APPROVAL_ID */ 
/**    
 * Marks a group of services as accepted or rejected 
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   svcRecID        Service record to associate with this note
 * @returns recordID        New record id of the note
 ***************************************************************************/     

SET NOCOUNT ON    
   
DECLARE @TranOpen        AS BIT    
DECLARE @today           AS DATETIME          -- Current date/time stamp    
DECLARE @numRecIDs       as INT
DECLARE @numDupRecIDs    as INT
DECLARE @currentID       AS INT
DECLARE @recIDVal        AS BIGINT
DECLARE @recIDVals       as TABLE([id] int identity(1,1), [recid] bigint) 

BEGIN TRY    

/*============================================================
 * Init
 *============================================================*/     
   
SET @recordID    = 0    
SET @spDetails   = ''    
SET @today       = GETDATE()    
SET @TranOpen    = 0

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userID          IS NULL) RAISERROR ('userID is required',         11, 1)
IF (@userGroup       IS NULL) RAISERROR ('userGroup is required',      11, 1)    
IF (@userRank        IS NULL) RAISERROR ('userRank is required',       11, 1)    
IF (@validateRec     IS NULL) RAISERROR ('Validate flag required',     11, 1)    
--IF (@recIDMulti      IS NULL) RAISERROR ('Record ids are required',    11, 1)    

/*============================================================
 * Parse multirec value into individual record ids
 *============================================================*/  
 
INSERT INTO @recIDVals (
  recid
)
  --select [id],[recid] from dbo.MULTI_RECORD_ID_PARSE(@recIDMulti,',')

select 
  [recid] = convert(int,t1.[value]) 
from string_split(@recIDMulti, ',' ) as t1

/*============================================================
 * Get number of record ids.  Exit if none.
 *============================================================*/  

SET    @numRecIDs = 0
SELECT @numRecIDs = COUNT(id) FROM @recIDVals

IF (@numRecIDs = 0)
BEGIN
  RETURN(0) 
END

/*============================================================
 * Set defaults
 *============================================================*/  

set @sendReviewNotesToRenderingPrac = isnull(@sendReviewNotesToRenderingPrac,0)
if (@approved = 0)  set @sendReviewNotesToRenderingPrac = 0
if (@numRecIDs > 1) set @sendReviewNotesToRenderingPrac = 0

/*============================================================
 * Check for duplicate record ids.  Exit with error if there are
 * dups.
 *============================================================*/  

SET    @numDupRecIDs = 0
SELECT @numDupRecIDs = COUNT([id]) FROM @recIDVals GROUP BY [recid] HAVING COUNT([id]) > 1

IF (@numDupRecIDs > 0) 
  RAISERROR ('Duplicate record ids are not allowed', 11, 1) 
  
/*============================================================
 * Begin a transaction
 *============================================================*/  

if @validateRec = 0
begin
  BEGIN TRANSACTION    
  SET @TranOpen  = 1 
end

/*============================================================
 * Update all records
 *============================================================*/  

set @currentID = 1
set @recIDVal  = 0

while (@currentID <= @numRecIDs)                        
begin

  declare @svcRecID  as bigint = null
  declare @journalID as bigint = null
  
  select top 1
    @currentID  = id, 
    @recIDVal   = recid          
  from @recIDVals 
  where 
    id = @currentID
  
  exec dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_CORE 
    @userID
  , @userGroup
  , @userRank
  , @editDelReason
  , @validateRec
  , @clientID
  , @recIDVal
  , @approved
  , @today
  , @MsgNoRec
  , @MsgNoEdit
  , @svcRecID  OUTPUT
  , @journalID OUTPUT
  , @spDetails OUTPUT
  , @recordID  OUTPUT 


  set @currentID = @currentID + 1
        
end -- While

/*-------------------------------    
 * Return the number of records
 * updated as the recordID
 *------------------------------*/  

SET @recordID = @numRecIDs

/*-------------------------------    
 * If this was an actual save
 * or edit commit the transaction
 *------------------------------*/  

if @validateRec = 0
begin
  IF (@TranOpen  = 1) 
    COMMIT TRANSACTION    
end

/*-------------------------------    
 * Reset our transaction flag
 *------------------------------*/  

SET @TranOpen = 0    

if (@sendReviewNotesToRenderingPrac = 1)
begin

  /*============================================================
   * Look for service record approval record
   *============================================================*/  

  declare @spDetailsSaveMsg       as varchar(8000) = ''
  declare @msgID                  as bigint        = 0
  declare @reviewNotes            as varchar(max)  = ''
  declare @renderingPracUserIDStr as varchar(256)  = ''
 
  select top 1
      @renderingPracUserIDStr = convert(varchar(50),sra.svcRecCreatedByUserID)
    , @reviewNotes            = sra.reviewNotes
  from dbo.SERVICE_RECORDS_APPROVAL as sra
  where ( 
        (sra.clientID = @clientID )
    and (sra.id       = @recIDVal)
  )
  
  /*============================================================
   * Send message
   *============================================================*/  

  exec users.dbo.USERS_MESSAGES_SAVE_SIMPLE 
      @userID       
    , @userGroup  
    , @userRank   
    , 'spedcare'
    , @renderingPracUserIDStr
    , 'Service Record Review Notes'
    , @reviewNotes
    , 1 /*@allowReply               bit = 0*/
    , 0 /*@sendEmail                bit = 0*/
    , @spDetailsSaveMsg output
    , @msgID            output
 
  
  end


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
   
  -- Error or raise error with severity 11 to 19 will be caught here    
   
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
   
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  --SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_SVC_REC_APPROVAL_ID] TO [webuser]
GO


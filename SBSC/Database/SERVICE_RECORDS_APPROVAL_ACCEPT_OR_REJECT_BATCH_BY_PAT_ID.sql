USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_PAT_ID') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_PAT_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_PAT_ID ( 
    @userID          BIGINT
  , @userGroup       INT  
  , @userRank        INT    
  , @editDelReason   VARCHAR(7000)
  , @validateRec     BIT
  , @clientID        BIGINT  
  , @siteID          bigint
  , @startEntryDate  datetime
  , @endEntryDate    datetime
  , @approvingPracID BIGINT 
  , @recID           BIGINT 
  , @approved        BIT
  , @MsgNoRec       VARCHAR(1000)
  , @MsgNoEdit      VARCHAR(1000)    
  , @spDetails      VARCHAR(8000) OUTPUT
  , @recordID       BIGINT        OUTPUT)   

AS
BEGIN

/***************************************************************************    
 * SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_PAT_ID */ 
/**    
 * Marks a group of services as accepted or rejected 
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   recID           Practitioner id 
 * @returns recordID        New record id of the note
 ***************************************************************************/     

SET NOCOUNT ON    
   
declare @recIDMulti as varchar(max)

BEGIN TRY    

/*============================================================
 * Init
 *============================================================*/     
   
SET @recordID    = 0    
SET @spDetails   = ''    

/*============================================================
 * Get approval ids for given practitioner
 *============================================================*/  

set @recIDMulti  = null
 
select   
   @recIDMulti = COALESCE(@recIDMulti + ',', '') + CAST(t1.id AS varchar(256))
from dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, @siteID ,@approvingPracID ,null, @recID, @startEntryDate, @endEntryDate ,0, null, null) as t1

/*============================================================
 * Call multi accept/reject by svc rec approval id sproc
 *============================================================*/  

exec SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_SVC_REC_APPROVAL_ID
   @userID
  ,@userGroup
  ,@userRank    
  ,@editDelReason
  ,@validateRec
  ,@clientID
  ,@recIDMulti
  ,@approved
  ,null
  ,@MsgNoRec
  ,@MsgNoEdit
  ,@spDetails OUTPUT    
  ,@recordID  OUTPUT

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

GRANT EXECUTE ON  [dbo].[SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_PAT_ID] TO [webuser]
GO


USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT
( @userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @clientID      BIGINT,
  @recID         BIGINT, 
  @approved      BIT,
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)   

AS
BEGIN

/***************************************************************************    
 * SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT */ 
/**    
 * Marks a single service as accepted or rejected
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 ***************************************************************************/     

SET NOCOUNT ON    

DECLARE @today           AS DATETIME -- Current date/time stamp    
DECLARE @TranOpen        AS BIT = 0

BEGIN TRY    

/*============================================================
 * Init
 *============================================================*/     
   
SET @today       = GETDATE()    
SET @recordID    = 0    
SET @spDetails   = ''    
SET @TranOpen    = 0

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userID          IS NULL) RAISERROR ('userID is required',         11, 1)
IF (@userGroup       IS NULL) RAISERROR ('userGroup is required',      11, 1)    
IF (@userRank        IS NULL) RAISERROR ('userRank is required',       11, 1)    
IF (@validateRec     IS NULL) RAISERROR ('Validate flag required',     11, 1)    

/*============================================================
 * Begin a transaction
 *============================================================*/  

if (@validateRec = 0)
begin
  BEGIN TRANSACTION    
  SET @TranOpen  = 1 
end

declare @svcRecID  as bigint = null
declare @journalID as bigint = null
 
/*============================================================
 * Call core sproc
 *============================================================*/     

exec SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_CORE 
    @userID
  , @userGroup
  , @userRank
  , @editDelReason
  , @validateRec
  , @clientID
  , @recID
  , @approved
  , @today
  , @MsgNoRec
  , @MsgNoEdit
  , @svcRecID  OUTPUT
  , @journalID OUTPUT
  , @spDetails OUTPUT
  , @recordID  OUTPUT 

/*============================================================
 * End transaction
 *============================================================*/     

if (@validateRec = 0)
begin
  IF (@TranOpen  = 1) 
    COMMIT TRANSACTION    
end

SET @TranOpen = 0    

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
 
  IF @tranOpen = 1 ROLLBACK TRANSACTION    

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

GRANT EXECUTE ON  [dbo].[SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT] TO [webuser]
GO


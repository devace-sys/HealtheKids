USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_MESSAGES_RECORD_OP_FLAG_AS_EMAILED') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.USERS_MESSAGES_RECORD_OP_FLAG_AS_EMAILED
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[USERS_MESSAGES_RECORD_OP_FLAG_AS_EMAILED] (
    @userID                   BIGINT
  , @userGroup                INT
  , @userRank                 INT 
  , @appName                  VARCHAR(50)
  , @editDelReason            VARCHAR(7000)    
  , @validateRec              BIT    
  , @recID                    BIGINT    
  , @MsgNoRec                 VARCHAR(1000)    
  , @MsgNoEdit                VARCHAR(1000) 
  , @spDetails                VARCHAR(8000) OUTPUT    
  , @recordID                 BIGINT        OUTPUT
)    
AS    
BEGIN     
 
/***************************************************************************    
 * USERS_MESSAGES_RECORD_OP_FLAG_AS_EMAILED */    
/**    
 ***************************************************************************/         
 
SET NOCOUNT ON    

set @recordID  = 0
set @spDetails = ''
 
declare @tranOpen as bit  
set @tranOpen = 0

BEGIN TRY    

if (@validateRec = 1) return
set @recordID = isnull(@recID,0)

begin transaction
set @tranOpen = 1

update dbo.USERS_MESSAGES
  set 
      emailSent      = 1
    , lastModified   = getdate()
	, lastModifiedBy = @userID
where ((id = @recID) and (sendEmail = 1))

commit transaction
set @tranOpen = 0
 
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
 
GRANT EXECUTE ON  [dbo].[USERS_MESSAGES_RECORD_OP_FLAG_AS_EMAILED] TO [webuser]
GO
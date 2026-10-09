USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STORED_FILE_FLAG_AS_NON_CONFIDENTIAL') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.STORED_FILE_FLAG_AS_NON_CONFIDENTIAL
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.STORED_FILE_FLAG_AS_NON_CONFIDENTIAL (   
    @userID                     bigint
  , @userGroup                  int
  , @userRank                   int     
  , @editDelReason              VARCHAR(7000)    
  , @validateRec                BIT
  , @recID                      INT    
  , @MsgNoRec                 VARCHAR(1000)    
  , @MsgNoEdit                VARCHAR(1000) 
  
  , @spDetails                VARCHAR(8000) OUTPUT    
  , @recordID                 BIGINT  OUTPUT
)
AS
BEGIN

/***************************************************************************    
 * STORED_FILE_FLAG_AS_NON_CONFIDENTIAL */    
/**    
 * 
 *
 ***************************************************************************/     

SET NOCOUNT ON  

BEGIN TRY   

declare @today                      as datetime
declare @TranOpen                   as bit  
declare @fileUploadedFromSource     as bigint

/*###########################################################################
  # Init
  ###########################################################################*/  

SET @spDetails  = ''    
SET @recordID   = 0
SET @today      = GETDATE()
SET @TranOpen   = 0

/*###########################################################################
  # Find file
  # Only author of file can change the flag value and only if its the opposite
  ###########################################################################*/  

set @recordID = 0

select top 1 
  @recordID = isnull(fu.id,0)
from dbo.FILE_UPLOADS as fu 
where (
      (fu.id     = @recID)
  and (fu.userID = @userID)
  and (fu.active = 1)
  and (fu.isConfidentialPracticeFile = 1)
)
option (recompile)

if(@recordID = 0)
begin
  RAISERROR ('This file is already unlocked (not marked as confidential) or user cannot unlock this file. Only the files author can unlock this file.', 11, 1)  
  return(0)
end

/*###########################################################################
  # Validation
  ###########################################################################*/  

IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        

/*###########################################################################
  # Save
  ###########################################################################*/  
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1     


/*###########################################################################
  # Set status -- Flag as non confidential
  # (This takes care of updating file upload table)
  ###########################################################################*/  

declare @statusCode as bigint = 3010
declare @statusID   as bigint

exec dbo.FILE_UPLOAD_SET_STATUS 
    @recordID
  , @today
  , @userID
  , @statusCode
  , null
  , null
  , null
  , @statusID output
  
/*###########################################################################
  # Done
  ###########################################################################*/       
    
COMMIT TRANSACTION    
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
                         
GRANT EXECUTE ON  [dbo].[STORED_FILE_FLAG_AS_NON_CONFIDENTIAL] TO [webuser]

GO
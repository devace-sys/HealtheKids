USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_APPEND_FILE_SHARE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_APPEND_FILE_SHARE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TELECOMM_SESSION_APPEND_FILE_SHARE] (
    @userID        BIGINT    
  , @userGroup     BIGINT    
  , @userRank      INT 
  , @uploadID      BIGINT
  , @editDelReason             VARCHAR(7000)    
  , @validateRec               BIT    
  , @saveType                  INT    
  , @recID                     BIGINT    
  , @MsgNoRec                  VARCHAR(1000)    
  , @MsgNoEdit                 VARCHAR(1000) 
  , @MsgDupRec                 VARCHAR(1000)     
  , @MsgDataError              VARCHAR(1000)
  , @MsgNotActive              VARCHAR(1000)     
  , @recordID                  BIGINT        OUTPUT  
  , @spDetails                 VARCHAR(8000) OUTPUT
)    
AS    
BEGIN     
    
/***************************************************************************    
 * TELECOMM_SESSION_APPEND_FILE_SHARE */    
/**    
 *     
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
declare @tranOpen     AS BIT    
declare @today        AS DATETIME       -- Current date/time stamp    

declare @sessionID                    as bigint = null
declare @filesToShareUploadIDsCurrent as varchar(8000) = ''
declare @filesToShareUploadIDsNew     as varchar(8000) = ''

BEGIN TRY    
    

/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
set @saveType   = dbo.CONST_SAVE_TYPE_EDIT()    
set @recordID   = 0    
set @spDetails  = ''    
set @today      = GETDATE()    
    
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
    
IF (@userID      is null) RAISERROR ('User ID is required',  11, 1)    
IF (@validateRec is null) RAISERROR ('Validate flag required', 11, 1)    
IF (@recID       is null) RAISERROR ('Record id is required',  11, 1)    
IF (@uploadID    is null) RAISERROR ('Upload id is required',  11, 1)    

/*-------------------------------    
 * Get session
 *------------------------------*/    

select top 1
    @sessionID                    = t1.id
  , @filesToShareUploadIDsCurrent = t1.filesToShareUploadIds
from dbo.TELECOMM_SESSIONS as t1
where (t1.id = @recID)

/*-------------------------------    
 * If there is nothing to update
 * get out
 *------------------------------*/    

IF (@sessionID IS NULL)
begin
  return(0)
end

/*-------------------------------    
 * If we are just validating     
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    

/*-------------------------------    
 * Generate new file upload     
 * string
 *------------------------------*/    

select @filesToShareUploadIDsNew = substring (
 (select ',' + convert(varchar,s.[value]) 
     from (
     select [value] = t2.value from string_split(isnull(@filesToShareUploadIDsCurrent,''),',') as t2 where (t2.value != 0)
     union 
     select [value] = @uploadID
    ) as s 
    for xml path('')
) ,2,200000) 

/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    

BEGIN TRANSACTION    
    
set @TranOpen = 1    

/*-------------------------------    
 * Update shared files
 *------------------------------*/    

exec dbo.TELECOMM_SESSION_MANAGE_SHARED_FILES_CORE @userID, @today, @sessionID, @filesToShareUploadIDsNew   

/*-------------------------------    
 * Get new shared file id
 *------------------------------*/    

select top 1 
  @recordID = t3.id
from dbo.TELECOMM_SESSIONS_FILES_TO_SHARE as t3
where (
      (t3.telecommSessionID = @sessionID) 
  and (t3.uploadID = @uploadID)
)
                 
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
     
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
    
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
    
  -- Reraise the error so it returns back to the server    
    
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_APPEND_FILE_SHARE] TO [webuser]
GO

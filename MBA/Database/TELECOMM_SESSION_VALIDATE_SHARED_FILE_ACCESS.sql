USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_VALIDATE_SHARED_FILE_ACCESS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_VALIDATE_SHARED_FILE_ACCESS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_VALIDATE_SHARED_FILE_ACCESS] (
    @roomID                   varchar(256)
  , @email                    varchar(256)
  , @pin                      varchar(50)  
  , @userIP                   varchar(500)
  , @userAgent                varchar(8000)
  , @storedFileID             bigint
  , @accessGranted            bit     output
  , @participantClientID      bigint  output
)    

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_SESSION_VALIDATE_SHARED_FILE_ACCESS */    
/**    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    

declare @tranOpen               as  bit  = 0
declare @today                  as  datetime
declare @sessionOK              as  bit    
declare @sessionID              as  bigint 
declare @participantID          as  bigint 
declare @isSessionFacilitator   as  bit 
declare @uploadIdOnFile         as bigint = null

set @today               = GETDATE()
set @accessGranted       = 0
set @participantClientID = -1
set @tranOpen            = 0

BEGIN TRY    

BEGIN TRANSACTION
set @tranOpen = 1

/*============================================================
 * Validate caller
 *============================================================*/  

exec dbo.TELECOMM_SESSION_VALIDATE_CORE 
    @roomID 
  , @email 
  , @pin     
  , @today

  , 0 --@skipMeetingHasNotStartedCheck

  , @sessionOK                output
  , @sessionID                output
  , @participantClientID      output 
  , @participantID            output
  , @isSessionFacilitator     output

/*============================================================
 * If we reach this point session is OK.  Check if participant
 * can access the file based on the file being included in the
 * file share list for this particular session
 *============================================================*/  

set @uploadIdOnFile = null

select top 1 
  @uploadIDOnFile = tsfs.uploadID 
from dbo.TELECOMM_SESSIONS_FILES_TO_SHARE as tsfs 
where ( 
      (tsfs.telecommSessionID = @sessionID)
  and (tsfs.uploadID          = @storedFileID) 
)

if (@uploadIdOnFile is not null) 
begin
  if (@uploadIdOnFile = @storedFileID)
  begin
    set @accessGranted = 1  
  end
  else
  begin
    set @accessGranted = 0
  end
end
else
begin
  set @accessGranted = 0  
end

/*============================================================
 * Log it
 *============================================================*/  

declare @logID    as bigint = null
declare @jsonData as varchar(max) = ''
 
set @jsonData  = '{'
	           + '"storedFileID":"'  + convert(varchar,isnull(@storedFileID,-1))   + '"'
               + ',"accessGranted":"' + convert(varchar,isnull(@accessGranted,0))  + '"'
			   + '}'

exec dbo.TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE
      @sessionID
	, @today
	, @participantID
	, 'Get File Share' 
	, @userIP
	, @userAgent
	, @jsonData
	, @logID output

/*============================================================
 * Done
 *============================================================*/  

COMMIT TRANSACTION
set @tranOpen = 0
RETURN(0)    


END TRY    
BEGIN CATCH    

  if (@tranOpen = 1) ROLLBACK TRANSACTION

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
               
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_VALIDATE_SHARED_FILE_ACCESS] TO [webuser]
GO

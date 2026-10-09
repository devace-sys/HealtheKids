USE [users]
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_MANAGE_SHARED_FILES_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_MANAGE_SHARED_FILES_CORE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_MANAGE_SHARED_FILES_CORE] (
    @userID                        bigint
  , @today                         datetime
  , @sessionID                     bigint
  , @filesToShareUploadIDs         varchar(8000)
)    

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_SESSION_MANAGE_SHARED_FILES_CORE */    
/**    
 * Manages file shares for telecomm session
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    

declare @filesToShareUploadNames as varchar(max) = ''
   
BEGIN TRY

/*============================================================
 * Get file share names
 *============================================================*/  
 
select @filesToShareUploadNames = substring (
  (select '|' + s.originalName 
     from (
       select 
         fu.originalName 
       from string_split(@filesToShareUploadIDs,',') as t1
       join SPEDMON.dbo.FILE_UPLOADS                 as fu on fu.id = t1.value
    ) as s 
    for xml path('')
) ,2,200000) 


/*============================================================
 * Update session data
 *============================================================*/  

  update dbo.TELECOMM_SESSIONS 
    set 
       filesToShareUploadIds          = @filesToShareUploadIDs
	 , filesToShareUploadNames        = @filesToShareUploadNames	
	 , lastModfied                    = @today 
     , lastModifedBy                  = @userID    
   where (ID =  @sessionID) 

/*============================================================
 * Regenerate file share data
 *============================================================*/  

delete dbo.TELECOMM_SESSIONS_FILES_TO_SHARE 
where (telecommSessionID = @sessionID)

insert into dbo.TELECOMM_SESSIONS_FILES_TO_SHARE
select 
    telecommSessionID = @sessionID 
  , uploadID          = fu.id
  , originalName      = fu.originalName 
from string_split(@filesToShareUploadIDs,',') as t1
join SPEDMON.dbo.FILE_UPLOADS                 as fu on fu.id = t1.value


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
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_MANAGE_SHARED_FILES_CORE] TO [webuser]
GO

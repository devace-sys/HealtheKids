USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_COMPLETE_PROCESS_INCOMING_FILE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_UPLOAD_COMPLETE_PROCESS_INCOMING_FILE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FILE_UPLOAD_COMPLETE_PROCESS_INCOMING_FILE ( 
    @userID                   bigint
  , @userGroup                int
  , @userRank                 int
  , @environmentID            bigint  
  , @uploadID                 bigint
)
AS
BEGIN

declare @today                as datetime = getdate()
declare @statusID             as bigint 
declare @filedFileName        as varchar(1000)
declare @filedFileLocation    as varchar(1000)
declare @fileFileLocationName as varchar(8000)

/*###########################################################################
  # Get filed filename
  ###########################################################################*/       

select 

   @filedFileName        = fu.fileAsName
 , @filedFileLocation    = fu.storeFiledRootPath
 , @fileFileLocationName = fu.storeFiledRootPathFilename 

from dbo.FILE_UPLOAD_VIEW (@userID,@userGroup,@userRank,@environmentID,@uploadID,null,null,null) as fu

/*###########################################################################
  # Update file uploads with filed file name
  ###########################################################################*/       

update dbo.FILE_UPLOADS 
set lastUpdatedOn = @today, lastUpdatedBy = @userID, filedName = @filedFileName 
where id = @uploadID

/*###########################################################################
  # Indicate record has been updated and processing complete
  ###########################################################################*/       

exec dbo.FILE_UPLOAD_SET_STATUS @uploadID, @today, @userID, 840, null, null, null, @statusID output


return (0)  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[FILE_UPLOAD_COMPLETE_PROCESS_INCOMING_FILE] TO [webuser]

GO
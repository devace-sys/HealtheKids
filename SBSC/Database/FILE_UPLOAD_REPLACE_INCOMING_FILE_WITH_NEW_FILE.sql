USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_REPLACE_INCOMING_FILE_WITH_NEW_FILE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_UPLOAD_REPLACE_INCOMING_FILE_WITH_NEW_FILE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FILE_UPLOAD_REPLACE_INCOMING_FILE_WITH_NEW_FILE ( 
    @userID                   bigint
  , @userGroup                int
  , @userRank                 int
  , @environmentID            bigint  
  , @uploadID                 bigint
  , @fileNameNew              varchar(8000)
  , @fileSizeNew              bigint
  , @fileMimeTypeNew          varchar(8000)
  
)
AS
BEGIN

declare @fileSizeOld     as bigint
declare @fileMimeTypeOld as varchar(8000)
declare @fileNameOld     as varchar(8000)
declare @note            as varchar(8000)
declare @today      as datetime

set @today = GETDATE()

/*###########################################################################
  # Get old values and make a note of them
  ###########################################################################*/  

select 
    @fileSizeOld     = isnull(fileSize,0)
  , @fileMimeTypeOld = isnull(fileMimeType,'')
  , @fileNameOld     = isnull(savedName,'') 
from dbo.FILE_UPLOADS 
where id = @uploadID

set @note = convert(varchar(50),@fileSizeOld) + '|' + @fileMimeTypeOld

/*###########################################################################
  # Update record with new saved name AND clear filed name
  ###########################################################################*/  

update dbo.FILE_UPLOADS 
set 
    fileSize      = @fileSizeNew
  , fileMimeType  = @fileMimeTypeNew
  , savedName     = @fileNameNew
  , filedName     = null
  , lastUpdatedBy = @userID
  , lastUpdatedOn = @today
  , fileReplaced  = 1
where id = @uploadID

/*###########################################################################
  # Set status
  ###########################################################################*/  

declare @statusCode as bigint = 130
declare @statusID   as bigint

exec FILE_UPLOAD_SET_STATUS @uploadID, @today, @userID, @statusCode, @fileNameOld, @fileNameNew, @note, @statusID output 

return (0)  

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[FILE_UPLOAD_REPLACE_INCOMING_FILE_WITH_NEW_FILE] TO [webuser]
GO
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES_CORE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES_CORE ( 
    @requestID        bigint
  , @selectedFileList varchar(max)
  , @userID           bigint
  , @today            datetime
)
AS
BEGIN

/***************************************************************************    
 * SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES */    
/**    
 *
 ***************************************************************************/     

declare @filesToIncludeUploadIds   varchar(max)
declare @filesToIncludeUploadNames varchar(max)

/*============================================================
 * Exit if request ID is not provided
 *============================================================*/  

if (@requestID  is null) return(1)

/*============================================================
 * Get file to include upload ids (comma delim)
 *============================================================*/

set @filesToIncludeUploadIds = trim(isnull(@selectedFileList,''))

/*============================================================
 * Get files to include names (this is pipe delimited)
 *============================================================*/  

set @filesToIncludeUploadNames = ''
 
select @filesToIncludeUploadNames = substring (
    (select '|' + s.originalName 
       from (
         select 
           fu.originalName 
         from string_split(@filesToIncludeUploadIds,',') as t1
         join dbo.FILE_UPLOADS                           as fu on fu.id = t1.value
      ) as s 
      for xml path('')
) ,2,200000) 

/*============================================================
 * Update authorization request record with ids and names
 *============================================================*/  

update dbo.SERVICE_AUTHORIZATION_REQUESTS
set 
    filesToIncludeUploadIds = @filesToIncludeUploadIds
  , filesToIncludeUploadNames = @filesToIncludeUploadNames
  , lastModified              = @today
  , lastModifiedBy            = @userID
where (id = @requestID)

/*============================================================
 * Delete any existing xref and recreate
 *============================================================*/  

delete dbo.SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE where (requestID = @requestID)

insert into dbo.SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE
select 
    requestID         = @requestID
  , uploadID          = fu.id
  , originalName      = fu.originalName 
from string_split(@filesToIncludeUploadIds,',') as t1
join dbo.FILE_UPLOADS                           as fu on fu.id = t1.value
 
/*============================================================
 * Done
 *============================================================*/  

return (0)  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES_CORE] TO [webuser]
GO
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_VIEW_FILE_CLASS_FILE_STORAGE_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_VIEW_FILE_CLASS_FILE_STORAGE_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOAD_VIEW_FILE_CLASS_FILE_STORAGE_DATA]
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,
 @environmentID  BIGINT,
 @fileClassID    BIGINT
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FILE_UPLOAD_VIEW_FILE_CLASS_FILE_STORAGE_DATA */
/**
 * Returns file upload storage data
 *
 * @return Table
 ***************************************************************************/ 

select 
    fc.id
    
  , ro.root     as receiveOriginalRoot
  , ro.path     as receiveOriginalPath
  , ro.rootPath as receiveOriginalRootPath
  
  , sf.root     as storeFiledRoot
  , sf.path     as storeFiledPath
  , sf.rootPath as storeFiledRootPath
  
  , ao.root     as archiveOriginalRoot
  , ao.path     as archiveOriginalPath
  , ao.rootPath as archiveOriginalRootPath
  
  , dr.root     as deactivateOrReplaceRoot
  , dr.path     as deactivateOrReplacePath
  , dr.rootPath as deactivateOrReplaceRootPath

  , wr.root     as webReferenceRoot
  , wr.path     as webReferencePath
  , wr.rootPath as webReferenceRootPath

  , af.root     as archiveFiledRoot
  , af.path     as archiveFiledPath
  , af.rootPath as archiveFiledRootPath
  
  , rf.root     as reviewFiledRoot
  , rf.path     as reviewFiledPath
  , rf.rootPath as reviewFiledRootPath

from dbo.FILE_CLASSES as fc

left join dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA(@userID,@userGroup,@userRank,@environmentID) as ro on ro.id = fc.fileStoragePathNameAddressReceiveOriginalID
left join dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA(@userID,@userGroup,@userRank,@environmentID) as sf on sf.id = fc.fileStoragePathNameAddressStorageFiledID
left join dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA(@userID,@userGroup,@userRank,@environmentID) as af on af.id = fc.fileStoragePathNameAddressArchiveFiledID
left join dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA(@userID,@userGroup,@userRank,@environmentID) as ao on ao.id = fc.fileStoragePathNameAddressArchiveOriginalID
left join dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA(@userID,@userGroup,@userRank,@environmentID) as rf on rf.id = fc.fileStoragePathNameAddressStorageReviewID
left join dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA(@userID,@userGroup,@userRank,@environmentID) as wr on wr.id = fc.fileStoragePathNameAddressWebReferenceID
left join dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA(@userID,@userGroup,@userRank,@environmentID) as dr on dr.id = fc.fileStoragePathNameAddressDeactivateOrReplaceID

where ((1=1) and ((@fileClassID is null) or (fc.id = @fileClassID)))
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FILE_UPLOAD_VIEW_FILE_CLASS_FILE_STORAGE_DATA] TO [webuser]
GO
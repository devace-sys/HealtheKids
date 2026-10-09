USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOAD_VIEW_FILE_STORAGE_DATA]
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,
 @environmentID  BIGINT
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FILE_UPLOAD_VIEW_FILE_STORAGE_DATA */
/**
 * Returns file upload storage data
 *
 * @return Table
 ***************************************************************************/ 
with
cte_pass_1
as
(
select 
    spna.id
  , spna.name  
  , sra.address  as [root]
  , sra.networkStorageSymLinkAddress as [symLinkRoot]
  , spna.address as [path]
  
from dbo.FILE_UPLOAD_FILE_STORAGE_ROOT_ADDRESSES       as sra
join dbo.FILE_UPLOAD_FILE_STORAGE_ROOT_NAMES           as srn  on srn.id                 = sra.storageRootNameID
join dbo.FILE_UPLOAD_FILE_STORAGE_PATH_NAMES_ADDRESSES as spna on spna.storageRootNameID = sra.storageRootNameID
join dbo.DEPLOYMENT_ENVIRONMENTS                       as de   on de.id                  = sra.deploymentEnvironmentID
where 
  (de.id = @environmentID)
)
,
cte_pass_2
as
(
select 
    id
  , name
  , [root]
  , [symLinkRoot]
  , [path]
  , [rootPath] = isnull([root],'') + isnull([path],'') 
  , [symLinkRootPath] = isnull([symLinkRoot],'') + isnull([path],'') 

from cte_pass_1
  
)
select * from cte_pass_2
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FILE_UPLOAD_VIEW_FILE_STORAGE_DATA] TO [webuser]
GO
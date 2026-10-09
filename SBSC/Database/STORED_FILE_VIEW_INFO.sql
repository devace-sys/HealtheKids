USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STORED_FILE_VIEW_INFO') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STORED_FILE_VIEW_INFO
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION dbo.STORED_FILE_VIEW_INFO (
    @userID             bigint
  , @userGroup          int
  , @userRank           int
  , @environmentID      int
  , @clientID           bigint
  , @pracID             bigint
  , @patID              bigint
  , @referencedEntityID bigint
  , @fileClass          bigint
  , @fileNameSpace      varchar(500)
  , @fileSource         varchar(500)
)

RETURNS TABLE
AS
RETURN
(  
  select top (dbo.CONST_MAX_ROWS())    
	  [Name]           = t1.[name]
    , [File Contains]  = t1.fileClassName
	, [Description]    = t1.description
	, [Size]           = t1.fileSizeHuman
	, [File ID]        = t1.fileId    
  from dbo.STORED_FILE_VIEW (@userId,@userGroup,@userRank,@environmentID,@clientID,@pracID,@patID,@referencedEntityID, @fileClass,null,null,@fileNameSpace,@fileSource,null,0) as t1  
  order by 
    t1.[name]  
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[STORED_FILE_VIEW_INFO] TO [webuser]
GO
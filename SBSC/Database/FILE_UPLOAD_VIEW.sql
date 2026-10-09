USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOAD_VIEW] (
    @userID            BIGINT  
  , @userGroup         INT   
  , @userRank          INT
  , @environmentID     BIGINT
  , @uploadID          BIGINT
  , @processFile       BIT
  , @reviewFile        BIT
  , @active            BIT
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FILE_UPLOAD_VIEW */
/**
 * Returns file upload data
 *
 * @return Table
 ***************************************************************************/ 

select top (dbo.CONST_MAX_ROWS()) *
from dbo.FILE_UPLOAD_VIEW_CORE (@userID, @userGroup, @userRank, @environmentID, @uploadID,@processFile, @reviewFile,@active)
order by 
    clientName asc 
  , filedName desc
  
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FILE_UPLOAD_VIEW] TO [webuser]
GO
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_VIEW_STATUS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_VIEW_STATUS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOAD_VIEW_STATUS]
(@userID            BIGINT,    
 @userGroup         INT,    
 @userRank          INT,
 @uploadID          BIGINT 
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FILE_UPLOAD_VIEW_STATUS */
/**
 * Returns file upload record status data
 *
 * @return Table
 ***************************************************************************/ 

select top (dbo.CONST_MAX_ROWS())
    fusl.id
  , fusl.createdOn              as [createdOn]
  , fusl.statusCode             as [statusCode]
  , fusc.name                   as [statusName]
  , rs.id                       as [returnStatusCode]
  , rs.name                     as [returnStatusName]
  , isnull(fusl.source,'')      as [source]
  , isnull(fusl.destination,'') as [destination]
  , isnull(fusl.note,'')        as [note]
from dbo.FILE_UPLOAD_STATUS_LOG   as fusl
join dbo.FILE_UPLOAD_STATUS_CODES as fusc on fusc.id = fusl.statusCode
join dbo.RETURN_STATUS            as rs   on rs.id   = fusc.returnStatus
where fusl.uploadId = @uploadID
order by 
    fusl.createdOn
  , fusl.id

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FILE_UPLOAD_VIEW_STATUS] TO [webuser]
GO
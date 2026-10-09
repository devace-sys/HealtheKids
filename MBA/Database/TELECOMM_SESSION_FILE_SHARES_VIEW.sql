USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_FILE_SHARES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TELECOMM_SESSION_FILE_SHARES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[TELECOMM_SESSION_FILE_SHARES_VIEW] ( 
   @userID              BIGINT
 , @userGroup           INT    
 , @userRank            INT
 , @appName             varchar(50)
 , @sessionID           bigint
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * TELECOMM_SESSION_FILE_SHARES_VIEW */
/**
 * Displays data
 *
 * @return                 Table
 ***************************************************************************/ 

select 

    tsfs.id
  , [name]         = tsfs.originalName
  , [description]  = trim(isnull(fu.description,''))
  , [uploadID]     = tsfs.uploadID
from dbo.TELECOMM_SESSIONS                as ts
join dbo.TELECOMM_SESSIONS_FILES_TO_SHARE as tsfs on tsfs.telecommSessionID  = ts.id
join SPEDMON.dbo.FILE_UPLOADS             as fu   on fu.id                   = tsfs.uploadID  

where (
       (ts.id = @sessionID)
  and (fu.active = 1)
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[TELECOMM_SESSION_FILE_SHARES_VIEW] TO [webuser]
GO



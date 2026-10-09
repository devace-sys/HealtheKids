USE users
GO

-- dbo.WorkInProgressSavePoints_View (@userID, @userGroup, @userRank, @appName, @requestedResource, @savePointName, @recID)
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.WorkInProgressSavePoints_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.WorkInProgressSavePoints_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[WorkInProgressSavePoints_View] (
   @userID             BIGINT
 , @userGroup          INT
 , @userRank           INT
 , @appName            varchar(50)
 , @requestResource    varchar(256)
 , @savePointName      varchar(256) 
 , @recID              bigint
)
RETURNS TABLE
AS
RETURN
(

/***************************************************************************
 * WorkInProgressSavePoints_View */
/**
 * @return                 Table of save points
 ***************************************************************************/

 select 
   sp.* 
 from dbo.WorkInProgressSavePoints as sp
 where (
       (sp.userID          = @userID)
   and (sp.appName         = @appName)
   and (sp.requestResource = @requestResource)
   and (sp.savePointName   = @savePointName)
   and ((@recID is null) or (sp.id = @recID))
   and (sp.active = 1)
 )
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[WorkInProgressSavePoints_View] TO [webuser]
GO

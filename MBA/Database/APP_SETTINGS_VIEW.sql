USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_SETTINGS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_SETTINGS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION dbo.APP_SETTINGS_VIEW (
    @userID      BIGINT 
  , @userGroup   INT
  , @userRank    INT
  , @appName     VARCHAR(50)
  , @namespace   varchar(50)
  , @class       varchar(50)
  , @subClass1   varchar(50)
  , @subClass2   varchar(50)
  , @name        varchar(50)                      
)

RETURNS TABLE 
AS
RETURN 
(

select 
  aps.*
from dbo.APP_SETTINGS_VIEW_CORE (@appName, @namespace, @class, @subClass1, @subClass2, @name ) as aps

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[APP_SETTINGS_VIEW] TO [webuser]
GO
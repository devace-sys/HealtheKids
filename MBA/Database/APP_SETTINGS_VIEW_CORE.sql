USE users
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[APP_SETTINGS] TO [webuser]
GO

USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_SETTINGS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_SETTINGS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION dbo.APP_SETTINGS_VIEW_CORE (
    @appName     VARCHAR(50)
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
from dbo.APP_SETTINGS as aps
where (
      (aps.[appName] = @appName)
  and (aps.active = 1)
  and (@namespace is null) or (aps.[namespace] = @namespace)
  and (@class     is null) or (aps.[class]     = @class)
  and (@subClass1 is null) or (aps.[subClass1] = @subClass1)
  and (@subClass2 is null) or (aps.[subClass2] = @subClass2)
  and (@name      is null) or (aps.[name]      = @name)
)
 
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[APP_SETTINGS_VIEW_CORE] TO [webuser]
GO
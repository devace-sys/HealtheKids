USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_SETTING_GET_VALUE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_SETTING_GET_VALUE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION dbo.APP_SETTING_GET_VALUE (
    @appName     VARCHAR(50)
  , @namespace   varchar(50)
  , @class       varchar(50)
  , @subClass1   varchar(50)
  , @subClass2   varchar(50)
  , @name        varchar(50)                      
)

RETURNS varchar(max) 
AS
BEGIN

declare @valueOut as varchar(max) = null

select top 1 
  @valueOut = aps.[value]
from dbo.APP_SETTINGS_VIEW_CORE (@appName, @namespace, @class, @subClass1, @subClass2, @name ) as aps

return @valueOut

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].APP_SETTING_GET_VALUE TO [webuser]
GO
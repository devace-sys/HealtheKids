USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_SETTING_SET_VALUE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.APP_SETTING_SET_VALUE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE dbo.APP_SETTING_SET_VALUE (
    @userID      BIGINT    
  , @appName     VARCHAR(50)
  , @namespace   varchar(50)
  , @class       varchar(50)
  , @subClass1   varchar(50)
  , @subClass2   varchar(50)
  , @name        varchar(50)                      
  , @value       varchar(max)
  , @saveType    int    output
  , @recordID    bigint output
)

AS
BEGIN

declare @today as datetime = getdate()

set @recordID = null
set @saveType = null

select top 1
  @recordID = aps.id
from dbo.APP_SETTINGS_VIEW_CORE (@appName, @namespace, @class, @subClass1, @subClass2, @name ) as aps

if (@recordID is null)
begin
  set @saveType = dbo.CONST_SAVE_TYPE_NEW()
  insert into dbo.APP_SETTINGS (
        appName
      , [namespace]
      , class
      , subClass1
      , subClass2
      , [name]
      , [value]
      , created
      , createdBy
      , active
    )
    values (
        @appName
      , @namespace
      , @class
      , @subClass1
      , @subClass2
      , @name
      , @value
      , @today
      , @userID
      , 1
    )
	
	set @recordID = SCOPE_IDENTITY()

end
else
begin

  set @saveType = dbo.CONST_SAVE_TYPE_EDIT()

  update dbo.APP_SETTINGS
  set 
      [value]          = @value
	, [lastModified]   = @today
	, [lastModifiedBy] = @userID
  where (id = @recordID)

end

return(0)

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].APP_SETTING_SET_VALUE TO [webuser]
GO
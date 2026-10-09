USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.USERS_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[USERS_DATA_CORE] (
    @appName    varchar(50)
  , @username   nvarchar(256)
  , @token      varchar(100)
  , @uid        uniqueidentifier
  , @id         bigint
)

RETURNS TABLE 
AS
RETURN 
(
  with
  cte_p0
  as
  (
    select
      t1.* 
     from dbo.USERS_ALL as t1   
     where (
             (1=1)
        and ((@uid      is null) or (t1.uid          = @uid))
	    and ((@id       is null) or (t1.id           = @id))
	    and ((@userName is null) or (t1.userName     = @username))
	    and ((@token    is null) or (t1.sessionToken = @token))
	    and ((@appName  is null) or (t1.appName      = @appName))
     )
  )
  ,
  cte_p1
  as
  (
    select 
      p0.*
	, [active]                = dbo.USER_IS_ACTIVE(p0.roleUID)
	, [isLoggedIn]            = dbo.STRING_HAS_VALUE(p0.sessionToken)
	, [passwordLastChangedOn] = dbo.ALTERNATE_DATE_IF_MIN_OR_NULL (p0.passwordLastChanged, p0.accountCreatedOn)
    from cte_p0 as p0   
  )
  ,
  cte_p2
  as
  (
    select 
        p1.*
      , [passwordAgeInDays] = dbo.AGE_IN_DAYS(p1.passwordLastChangedOn, getdate())
	  , [userRank]          = dbo.INT_CONCAT( p1.userGroupRank, p1.roleRank)
	from cte_p1 as p1
  )    
  
  select p2.* from cte_p2 as p2
)


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[USERS_DATA_CORE] TO [webuser]
GO

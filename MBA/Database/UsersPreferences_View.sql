USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.UsersPreferences_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.UsersPreferences_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[UsersPreferences_View] (@userID      BIGINT, 
                                               @userGroup   INT,
                                               @userRank    INT,
                                               @appDomain   VARCHAR(1000),
                                               @appName     VARCHAR(50),
                                               @usrid       BIGINT
)

RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * UsersPreferences_View */
/**
 * Displays user preference data
 *
 * @param  appDomain       Application domain
 * @param  appName         Application name
 * @param  usrid           User id (int)
 * @return                 Table of user data
 ***************************************************************************/ 
 
   select 
     t1.* 
   from dbo.UsersPreferences as t1
   where (
         (1=1)
    and (@appDomain is null) or (t1.[appDomain] = @appDomain)
    and (@appName   is null) or (t1.appName     = @appName)
    and (@usrid     is null) or (t1.usrid       = @usrid)
  )
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[UsersPreferences_View] TO [webuser]
GO
USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ROLES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ROLES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[ROLES_VIEW] (
     @userID      bigint
   , @userGroup   int
   , @userRank    int
   , @appName     varchar(50)
   , @name        nvarchar(256)
   , @canEdit     bit
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * ROLES_VIEW */
/**
 * Displays role data that a given appName, userGroup, userRank should
 * be able to see or work with.
 *
 * The general rules are:
 *
 *   - users with the lowest rank in a given user group for appname cannot see anything
 *   - users with higher rank in a given user group for appname can see roles with lower
 *     ranks within their group and in groups with a lower group id (ranking)
 *
 * @param  appName         Application name
 * @param  userGroup       Calling users group
 * @param  userRank        Calling users rank
 * @return                 Table of role data
 ***************************************************************************/ 

  select top (dbo.CONST_MAX_ROWS()) 
    rv.*  
  from  dbo.ROLES_VIEW_CORE (@userID , @userGroup, @userRank, @appName, null, null) as rv  
  
  where (
        (rv.display = 1)    
	and ((@name IS NULL) OR (rv.name like ((@name + '%')))) 
	and ((@canEdit is null) or (rv.canEdit = @canEdit))
  )      
  
  order by 
    rv.compositeRank desc
  
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[ROLES_VIEW] TO [webuser]
GO

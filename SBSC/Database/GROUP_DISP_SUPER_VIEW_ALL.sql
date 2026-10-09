USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUP_DISP_SUPER_VIEW_ALL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUP_DISP_SUPER_VIEW_ALL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[GROUP_DISP_SUPER_VIEW_ALL] (@active as bit)     
RETURNS TABLE AS RETURN (      
 
  /*-------------------------------
   * Returns all groups that
   * are allied discipline "super
   * groups"
   *------------------------------*/

  select
    dbo.CONST_GROUP_TYPE_DISP_SUPER() as selectType,
    PARENT_GROUP_ID                   as parentid,
    GROUP_ID                          as groupid , 
    GROUP_NAME                        as groupname,
    GROUP_TYPE                        as groupType,
    TITLE                             as groupTypeTitle,
    DESCRIPTION                       as groupTypeDescription,
    CLIENT_ID                         as clientID,
    CLIENT_NAME                       as clientName,
    ACTIVE                            as active
  from dbo.GROUPS_VIEW_CORE_2(5)
  where ((1=1)
        and (GROUP_ID <> dbo.CONST_PRAC_GROUP_STATE_ADJUST_ID())
        and ((@active is null) or (ACTIVE = @active)))  
)  
GO

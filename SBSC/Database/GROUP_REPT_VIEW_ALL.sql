USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUP_REPT_VIEW_ALL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUP_REPT_VIEW_ALL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GROUP_REPT_VIEW_ALL](@clientID as int, @active as bit)     
RETURNS TABLE AS RETURN (
  
  /*-------------------------------
   * Returns all groups that
   * fall under the "old" group
   * type CONST_GROUP_TYPE_REPT
   *------------------------------*/
   
  select 
    dbo.CONST_GROUP_TYPE_REPT() as selectType,
    PARENT_GROUP_ID             as parentid,
    GROUP_ID                    as groupid , 
    GROUP_NAME                  as groupname,
    GROUP_TYPE                  as groupType,
    TITLE                       as groupTypeTitle,
    DESCRIPTION                 as groupTypeDescription,
    CLIENT_ID                   as clientID,
    CLIENT_NAME                 as clientName,
    ACTIVE                      as active
  from dbo.GROUPS_VIEW_CORE_2(35)
  where ((1=1)
        and (GROUP_ID <> dbo.CONST_PRAC_GROUP_STATE_ADJUST_ID())
        and ((@active   is null) or (ACTIVE    = @active))
        and ((@clientID is null) or ((CLIENT_ID is null) or (CLIENT_ID = @clientID))))   
     
  --select groupID, groupName, dbo.CONST_GROUP_TYPE_REPT() as groupType, clientID, clientName, active 
  --from GROUPS_VIEW_CORE(@clientID, @active) where groupType = dbo.CONST_PRAC_GROUP_REPT()
)  

GO

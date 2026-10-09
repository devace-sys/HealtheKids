USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUPS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUPS_VIEW_CORE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[GROUPS_VIEW_CORE](@clientID as int, @active as bit)     
RETURNS TABLE 

/***************************************************************************
 * GROUPS_VIEW_CORE */
/**
 * Returns a list of groups 
 *
 * @return                 Table
 ***************************************************************************/  

AS RETURN (         
  select
    g.GROUP_ID                     as groupID, 
    g.GROUP_NAME                   as groupName,
    g.GROUP_TYPE                   as groupType,
    g.ACTIVE                       as active,
    g.CLIENT_ID                    as clientID,
    isnull(c.CLIENT_NAME,'')       as clientName 
  from GROUP_Group as g
  left join CLIENTS_Client as c on c.CLIENT_ID = g.CLIENT_ID
  where ((1=1)
  and (g.GROUP_ID <> 152) /* Exclude state adjustement */
  and ((@active   is null) or (g.active = @active)) 
  and ((@clientID is null) or ((g.CLIENT_ID = @clientID) or (g.CLIENT_ID is null))))
  )  
GO

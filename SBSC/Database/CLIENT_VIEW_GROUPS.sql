USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_VIEW_GROUPS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_VIEW_GROUPS
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[CLIENT_VIEW_GROUPS]    
(@clientID   INT)     
RETURNS TABLE AS RETURN    
(     
select c.CLIENT_ID                   as "clientID",     
       ga.groupID                    as "id",     
       ga.groupName                  as "name",     
       dbo.CONST_GROUP_TYPE_DISP()   as "type",    
       COUNT(pg.PRACTITIONER_ID)     as "numMembers"     
from       CLIENTS_Client            as c    
inner join PRACTITIONER_Client             as pc on pc.CLIENT_ID       = c.CLIENT_ID    
inner join PRACTITIONER_GROUPS             as pg on pg.PRACTITIONER_ID = pc.PRACTITIONER_ID     
inner join GROUP_DISP_VIEW_ALL(null)       as ga on ga.groupID = pg.GROUP_ID    
where (1=1) and ((@clientID IS NULL) or (c.CLIENT_ID = @clientID))    
group by c.CLIENT_ID, ga.groupID , ga.groupName     
union     
select c.CLIENT_ID                   as "clientID",     
       ra.groupID                    as "id",     
       ra.groupName                  as "name",     
       dbo.CONST_GROUP_TYPE_REPT()   as "type",    
       COUNT(pg.PRACTITIONER_ID)     as "numMembers"     
from       CLIENTS_Client            as c    
inner join PRACTITIONER_Client             as pc on pc.CLIENT_ID       = c.CLIENT_ID    
inner join PRACTITIONER_GROUPS             as pg on pg.PRACTITIONER_ID = pc.PRACTITIONER_ID     
inner join GROUP_REPT_VIEW_ALL(null,null)  as ra on ra.groupID = pg.GROUP_ID    
where (1=1) and ((@clientID IS NULL) or (c.CLIENT_ID = @clientID))    
group by c.CLIENT_ID, ra.groupID , ra.groupName     
)    
    
GO

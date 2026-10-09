USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRAC_VIEW_GROUP_ASSIGNMENTS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRAC_VIEW_GROUP_ASSIGNMENTS
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[PRAC_VIEW_GROUP_ASSIGNMENTS]    
(@pracID   INT,    
 @groupType INT)    
      
RETURNS TABLE AS RETURN    
(     
select * from    
(    
select  p.PRACTITIONER_ID            as "pracID",     
       ga.groupID                    as "id",     
       ga.groupName                  as "name",     
       dbo.CONST_GROUP_TYPE_DISP()   as "type"    
from       PRACTITIONER_Practitioner as p     
inner join PRACTITIONER_GROUPS       as pg on pg.PRACTITIONER_ID = p.PRACTITIONER_ID     
inner join GROUP_DISP_VIEW_ALL(null) as ga on ga.groupID = pg.GROUP_ID    
where (1=1) and ((@pracID IS NULL) or (p.PRACTITIONER_ID = @pracID))    
union     
select p.PRACTITIONER_ID             as "pracID",     
       ra.groupID                    as "id",     
       ra.groupName                  as "name",     
       dbo.CONST_GROUP_TYPE_REPT()   as "type"     
from       PRACTITIONER_Practitioner as p     
inner join PRACTITIONER_GROUPS       as pg on pg.PRACTITIONER_ID = p.PRACTITIONER_ID     
inner join GROUP_REPT_VIEW_ALL(null,null) as ra on ra.groupID = pg.GROUP_ID    
where (1=1) and ((@pracID IS NULL) or (p.PRACTITIONER_ID = @pracID))    
) as q1    
where (1=1) and ((@groupType IS NULL) or (q1.type = @groupType))    
)    
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT SELECT ON  [dbo].[PRAC_VIEW_GROUP_ASSIGNMENTS] TO [webuser]
GO

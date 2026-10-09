USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRAC_VIEW_BY_CLIENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRAC_VIEW_BY_CLIENT
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[PRAC_VIEW_BY_CLIENT]    
(@clientID    INT,    
 @pracID      INT,    
 @lname       NVARCHAR(50),    
 @fname       NVARCHAR(50),    
 @groupID     INT,    
 @groupType   INT, /* 1 = discipline, 2= reporting group */    
 @active      BIT)    
 RETURNS TABLE AS RETURN(     
   with pracs_cte(rownum, rowtotal, id, name, lname, fname, groupname, grouptype, groupid, notes) as     
   (    
     select ROW_NUMBER() over (order by p.PRACTITIONER_ID) as rownum,    
            COUNT(*)OVER()                  as rowtotal,    
            p.PRACTITIONER_ID               as id,    
            isnull(p.LAST_NAME,'')  +    
            ', '                    +     
            isnull(p.FIRST_NAME,'')         as name,    
            p.LAST_NAME                     as lname,    
            p.FIRST_NAME                    as fname,    
            pga.name                        as groupname,    
            pga.type                        as grouptype,    
            pga.id                          as groupid,    
            pn.note                         as notes     
     from       PRACTITIONER_Practitioner   as p     
     inner join PRACTITIONER_CLIENT         as pc  on ((pc.PRACTITIONER_ID = p.PRACTITIONER_ID)     
                                                   and (pc.CLIENT_ID   = @clientID))    
     inner join PRAC_VIEW_GROUP_ASSIGNMENTS(null,@groupType)     
                                            as pga on (pga.pracID = p.PRACTITIONER_ID)    
     left join  INPUT_NOTES_PRAC(@clientID,@pracID)    
                                            as pn  on (pn.pracID  = p.PRACTITIONER_ID)     
     where (1=1)     
     and ((@pracID is null)    or (p.PRACTITIONER_ID = @pracID))     
     and ((@lname is null)     or (p.LAST_NAME  like (@lname + '%')))     
     and ((@fname is null)     or (p.FIRST_NAME like (@fname + '%')))     
     and ((@groupID is null)   or (pga.id = @groupID))    
     and ((@active is null)    or (isnull(p.ACTIVE,1) = @active))    
   ) select * from pracs_cte    
 )    
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT SELECT ON  [dbo].[PRAC_VIEW_BY_CLIENT] TO [webuser]
GO

USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ALLERGIES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ALLERGIES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[ALLERGIES_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT
  , @term				   VARCHAR(256)
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
)
    
returns table     
as
 
return 
(    
select 
    cr.id 
  , cr.[name] 
  , cr.created
  , cr.createdBy
  , cr.lastModified
  , cr.lastModifiedBy
  , cr.active
  
from dbo.ALLERGIES as cr
where (   
      (1=1)
  and ((@recID         is null) or (cr.id            = @recID))
  and ((@term          is null) or (cr.[name] like '%' + @term + '%'))
  and (cr.active = 1)
)
 
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ALLERGIES_VIEW] TO [webuser]
GO
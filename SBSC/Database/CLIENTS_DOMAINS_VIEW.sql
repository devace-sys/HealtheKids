USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENTS_DOMAINS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENTS_DOMAINS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENTS_DOMAINS_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT     
  , @clientID              bigint     
  , @term				   VARCHAR(50)
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
)
    
returns table     
as
 
return 
(    

select 
    id       = cd.ID 
  , clientID = cd.CLIENT_ID
  , [name]   = cd.DOMAIN
  , cd.created
  , cd.createdBy
  , cd.lastModified
  , cd.lastModifiedBy
  , active = cd.ACTIVE
  
from dbo.CLIENTS_DOMAINS as cd
where (   
      (1=1)
  and (cd.CLIENT_ID = @clientID)
  and ((@recID  is null) or (cd.ID = @recID))
  and ((@term   is null) or (cd.DOMAIN like '%' + @term + '%'))
  and ((@active is null) or (cd.ACTIVE = @active))
)
 
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENTS_DOMAINS_VIEW] TO [webuser]
GO
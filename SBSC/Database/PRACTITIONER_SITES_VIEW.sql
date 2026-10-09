USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_SITES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION PRACTITIONER_SITES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTITIONER_SITES_VIEW] (
    @userID         BIGINT    
  , @userGroup      BIGINT    
  , @userRank       INT
  , @clientID       bigint
  , @pracID         bigint
  , @active         bit   /* For future use */
  , @recID          bigint  
)    
RETURNS 
TABLE
AS
RETURN
(

select top (dbo.CONST_MAX_ROWS())

	ps.id
  , clientID   = clc.CLIENT_ID
  , clientName = clc.CLIENT_NAME
  , pracID     = prc.PRACTITIONER_ID
  , pracName   = prp.CONCAT_NAME
  , siteID     = ss.SITE_ID
  , siteName   = ss.SITE_NAME 
  , ps.active

from dbo.CLIENTS_CLIENT            as clc
join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID       = clc.CLIENT_ID
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.PRACTITIONER_SITES        as ps  on ps.pracID           = prp.PRACTITIONER_ID
join dbo.SITES_Site                as ss  on ss.SITE_ID          = ps.siteID
where (      
      (clc.CLIENT_ID  = @clientID)
  and ((prc.CLIENT_ID = @clientID) and (prc.PRACTITIONER_ID = @pracID))
  and (ps.active = 1)
  and ((@recID is null) or (ps.id = @recID))
)
)
GO

GRANT SELECT ON  [dbo].[PRACTITIONER_SITES_VIEW] TO [webuser]
GO

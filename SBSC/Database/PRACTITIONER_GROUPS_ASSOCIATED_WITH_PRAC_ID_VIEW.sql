USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_GROUPS_ASSOCIATED_WITH_PRAC_ID_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_GROUPS_ASSOCIATED_WITH_PRAC_ID_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
	 
CREATE FUNCTION [dbo].[PRACTITIONER_GROUPS_ASSOCIATED_WITH_PRAC_ID_VIEW] (
    @clientID bigint
  , @pracID   bigint
)
RETURNS TABLE 
AS 
RETURN (
 
/***************************************************************************    
 * PRACTITIONER_GROUPS_ASSOCIATED_WITH_PRAC_ID_VIEW */    
/**    
 * Returns practitioner groups that pracID is a member of
 *
 * @param clientID  Client ID
 * @param userID    User id
 * 
 ***************************************************************************/      

select    
   pg.*  
from      dbo.PRACTITIONER_Client        as pc 
join      dbo.PRACTITIONER_PRACTITIONER  as pp on pp.PRACTITIONER_ID = pc.PRACTITIONER_ID
join      dbo.PRACTITIONER_GROUPS        as pg on pg.PRACTITIONER_ID = pp.PRACTITIONER_ID
where ((pc.CLIENT_ID = @clientID) and (pp.PRACTITIONER_ID = @pracID))  
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_GROUPS_ASSOCIATED_WITH_PRAC_ID_VIEW] TO [webuser]
GO

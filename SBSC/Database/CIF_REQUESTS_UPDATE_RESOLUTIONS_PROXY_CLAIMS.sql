USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS]  
AS    

BEGIN     
    
/***************************************************************************    
 * CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS */    
/**    
 * 
 ***************************************************************************/         

SET NOCOUNT ON        

exec CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_1   /* Generates any missing CIF request records so every proxy claim has a related CIF request record */
exec CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_2   /* Resolves proxy claims */

RETURN(0)    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS] TO [webuser]
GO

USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_Service_Selections_View') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_Service_Selections_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_Service_Selections_View] (    
    @userID      BIGINT
  , @userGroup   INT   
  , @userRank    INT
  , @term		 varchar(256)
)
 
RETURNS TABLE      

/***************************************************************************    
 * CYBHI_Service_Selections_View */    
/**    
 * CYBHI service selections are the same id/name pairs regardless of group
 * This should not be used to take the place of the services.view
 * it should only be used for screens where we have to provide a distict
 * list of cybhi service selections (such as reporting dashboards)
 ***************************************************************************/            
    
AS RETURN (        
  select top (dbo.CONST_MAX_ROWS())      
	  [id]   = ccn.CYBHI_NAME_ID
    , [name] = ccn.NAME
  from dbo.CLAIM_CYBHI_Names as ccn
  where (
        (1=1)
	and ((@term is null) or (ccn.[name] like (('%' + @term + '%'))))
  )
  order by 
    ccn.[NAME]
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CYBHI_Service_Selections_View] TO [webuser]
GO   

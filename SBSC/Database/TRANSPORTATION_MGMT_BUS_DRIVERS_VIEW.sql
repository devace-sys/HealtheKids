USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_BUS_DRIVERS_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_BUS_DRIVERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_BUS_DRIVERS_VIEW] (    
    @userID      BIGINT
  , @userGroup   INT   
  , @userRank    INT
  , @clientID    BIGINT
  , @term		 varchar(256)
)
 
RETURNS TABLE      
    
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS())
       tmbd.*
	 , [name] = dbo.CREATE_CONCAT_NAME(tmbd.lastName, tmbd.firstName)
  from dbo.TRANSPORTATION_MGMT_BUS_DRIVERS as tmbd
  where (tmbd.active = 1
	and ((@term is null) or (tmbd.firstName like (('%' + @term + '%'))) or (tmbd.lastName like (('%' + @term + '%'))))
	and ((@clientID is null) or (tmbd.clientID = @clientID))
	)

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_BUS_DRIVERS_VIEW] TO [webuser]
GO   



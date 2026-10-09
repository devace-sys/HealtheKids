USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @transMgmtID            BIGINT
 , @active                 BIT
 , @recID                  BIGINT )

RETURNS TABLE
AS
RETURN
(
  select top (dbo.CONST_MAX_ROWS())
    *
  from TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_CORE (  @userID
                                                        , @userGroup
                                                        , @userRank               
                                                        , @clientID               
                                                        , @transMgmtID            
                                                        , @active                 
                                                        , @recID  )                
  order by  
    name

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW] TO [webuser]
GO
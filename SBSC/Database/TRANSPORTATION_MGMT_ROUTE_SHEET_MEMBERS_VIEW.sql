USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @transMgmtID            BIGINT
 , @patID                  BIGINT
 , @sheetBatchID           BIGINT
 , @sheetCode              VARCHAR(512)
 , @routeID                BIGINT
 , @sheetID                BIGINT
 , @active                 BIT
 , @recID                  BIGINT ) 

RETURNS TABLE
AS
RETURN
(
  
  
select top (dbo.CONST_MAX_ROWS()) * 
from dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW_CORE (
   @userID  
 , @userGroup
 , @userRank 
 , @clientID 
 , @transMgmtID
 , @patID     
 , @sheetBatchID
 , @sheetCode
 , @routeID  
 , @sheetID 
 , @active
 , @recID ) 

order by

   sheetBatchID
 , routeID
 , displayOrder
 , name

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW] TO [webuser]
GO
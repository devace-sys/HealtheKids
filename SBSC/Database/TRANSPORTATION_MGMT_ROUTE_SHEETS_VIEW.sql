USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @transMgmtID            BIGINT
 , @sheetBatchID           BIGINT
 , @sheetCode              VARCHAR(512)
 , @routeID                BIGINT
 , @active                 BIT
 , @recID                  BIGINT )

RETURNS TABLE
AS
RETURN
(

select top (dbo.CONST_MAX_ROWS())
  t1.* 
from dbo.TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW_CORE (
   @userID
 , @userGroup
 , @userRank
 , @clientID
 , @transMgmtID
 , @sheetBatchID
 , @sheetCode
 , @routeID  
 , @active
 , @recID ) as t1

order by   

   t1.sheetBatchID
 , t1.[name]

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW] TO [webuser]
GO
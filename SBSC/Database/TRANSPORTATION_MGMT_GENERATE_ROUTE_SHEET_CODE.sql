USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_GENERATE_ROUTE_SHEET_CODE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_GENERATE_ROUTE_SHEET_CODE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_GENERATE_ROUTE_SHEET_CODE]
(    
    @clientID      bigint
  , @transMgmtID   bigint
  , @routeID       bigint
  , @refDate       datetime
  , @sheetBatchID  bigint
  , @sheetID       bigint
) 
RETURNS varchar(512)
WITH SCHEMABINDING
AS     
BEGIN    

declare @sheetCode as varchar(255) = ''
declare @delim     as varchar(2)   = '-'
declare @client    as varchar(50)  = convert (varchar(50), @clientID)
declare @route     as varchar(50)  = convert (varchar(50), @routeID)
declare @sheet     as varchar(50)  = convert (varchar(50), @sheetID)
declare @batch     as varchar(50)  = convert (varchar(50), @sheetBatchID)

set @sheetCode =   @client
                 + @delim
                 + @sheet


return @sheetCode

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_GENERATE_ROUTE_SHEET_CODE] TO [webuser]
GO
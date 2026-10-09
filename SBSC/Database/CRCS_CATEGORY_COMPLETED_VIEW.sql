USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_CATEGORY_COMPLETED_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_CATEGORY_COMPLETED_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CRCS_CATEGORY_COMPLETED_VIEW] (
	@userID	          BIGINT
  , @userGroup        INT  
  , @userRank         INT 
  , @clientID         BigInt
  , @fiscalYearID     BigInt
  , @quarterNumber    Int
  , @crcsCategoryCode Int
)    

RETURNS TABLE

AS RETURN (
   
	select
		ccc.*
	from dbo.CRCS_CATEGORY_COMPLETED as ccc
	where (
		(ccc.clientID         = @clientID)
	and (ccc.fiscalYearID     = @fiscalYearID)
	and (ccc.quarterNumber    = @quarterNumber)
	and (ccc.crcsCategoryCode = @crcsCategoryCode)
	and (ccc.active           = 1)
	)
)
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_CATEGORY_COMPLETED_VIEW] TO [webuser]
GO  

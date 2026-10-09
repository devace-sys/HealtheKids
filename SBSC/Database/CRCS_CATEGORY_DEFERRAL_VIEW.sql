USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_CATEGORY_DEFERRAL_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_CATEGORY_DEFERRAL_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CRCS_CATEGORY_DEFERRAL_VIEW] (
    @clientID                  BigInt
  , @fiscalYearID              BigInt
  , @crcsCategoryCode          Int
)    

RETURNS TABLE

AS RETURN (

	 /***************************************************************************    
	  * CRCS_CATEGORY_DEFERRAL_VIEW */    
	 /**    
	  ***************************************************************************/   
	select
		  deferred		   = ccd.deferred
		, crcsCategoryCode = @crcsCategoryCode
		, fiscalYearID     = @fiscalYearID
		, clientID		   = @clientID
	from dbo.CRCS_CATEGORY_DEFERRAL as ccd
	where (
		(ccd.clientID = @clientID)
	and (ccd.crcsCategoryCode = @crcsCategoryCode)
	and (ccd.fiscalYearID = @fiscalYearID)
	and (ccd.active = 1)
	)
)
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_CATEGORY_DEFERRAL_VIEW] TO [webuser]
GO  

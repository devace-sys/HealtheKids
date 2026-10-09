USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_SALARIES_TOTALS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PRAC_SALARIES_TOTALS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_PRAC_SALARIES_TOTALS_VIEW] ( 
	     @userID            BigInt    
	   , @userGroup         Int    
	   , @userRank          Int 
	   , @clientID          BigInt 
	   , @fiscalYearID      Bigint
       , @quarterNumber	    Int
	   , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN (	
	select
		*
	from dbo.CRCS_PRAC_SALARIES_TOTALS_VIEW_CORE( @clientID, @fiscalYearID, @quarterNumber )
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_PRAC_SALARIES_TOTALS_VIEW] TO [webuser]
GO
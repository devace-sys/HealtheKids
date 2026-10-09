USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.COMPANY_FISCAL_QUARTERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.COMPANY_FISCAL_QUARTERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[COMPANY_FISCAL_QUARTERS_VIEW] ( 
	   @userID            BIGINT    
	 , @userGroup         INT    
	 , @userRank          INT   
	 , @year              DateTime
	 , @fiscalYearID      Bigint
	 , @quarterNumber     Int
	 , @recID             Bigint
)
     
RETURNS TABLE

/***************************************************************************    
 * COMPANY_FISCAL_QUARTERS_VIEW */    
/**    
 * Returns a a single quarter matching @recID or the quarters in @year / @fiscalYearID
 *     
 ***************************************************************************/     

AS RETURN(

select     
    *
from dbo.COMPANY_FISCAL_QUARTERS_VIEW_CORE (@year, @fiscalYearID, @quarterNumber, @recID)
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[COMPANY_FISCAL_QUARTERS_VIEW] TO [webuser]
GO
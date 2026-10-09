USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.COMPANY_FISCAL_YEARS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.COMPANY_FISCAL_YEARS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[COMPANY_FISCAL_YEARS_VIEW] ( 
	   @userID            BIGINT    
	 , @userGroup         INT    
	 , @userRank          INT     
     , @yearsBack         Int
	 , @yearsForward      Int
	 , @year              DateTime
	 , @term              Varchar(1000)
	 , @recID             Bigint
)
     
RETURNS TABLE

/***************************************************************************    
 * COMPANY_FISCAL_YEARS */    
/**    
 * Returns a range of years from either @year or @recID back @yearsBack years
 * and forward @yearsForward years
 *     
 ***************************************************************************/     

AS RETURN(

select
top ( dbo.CONST_MAX_ROWS() )     
      *
	, name = cfy.FY_DEFINITION
  from dbo.COMPANY_FISCAL_YEARS_VIEW_CORE (@yearsBack, @yearsForward, @year, @recID) as cfy   
  where (
         (1=1)
    and ((@term is null) or (cfy.FY_DEFINITION like CONCAT('%', @term, '%')))
  )

  ORDER BY id desc 

) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[COMPANY_FISCAL_YEARS_VIEW] TO [webuser]
GO
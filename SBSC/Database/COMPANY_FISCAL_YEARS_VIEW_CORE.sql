USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.COMPANY_FISCAL_YEARS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.COMPANY_FISCAL_YEARS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[COMPANY_FISCAL_YEARS_VIEW_CORE] (    
       @yearsBack         Int
	 , @yearsForward      Int
	 , @year              DateTime
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
with selectedYearCte as (
	  select     
		*
	  from dbo.COMPANY_FISCAL_YEARS as cfy 

	  where (
			(1=1)
		-- get years from @year - @yearBack to @year + @yearsForward
		and ((@year is null) or (Convert(Date, @year) between cfy.FY_START and cfy.FY_END))
	
		-- the following two take care of years from selected year minus @yearsBack to selected year plus @yearsForward
		and ((@recID is null)  or (cfy.ID  = @recID))
	  )
)

select distinct
	cfy.*
  from dbo.COMPANY_FISCAL_YEARS as cfy 
  cross apply selectedYearCte as sy
  where (
		(1=1)
	and (
		-- get years from @year - @yearBack
		(cfy.FY_START between DATEADD(YEAR, -@yearsBack, sy.FY_START) and sy.FY_START)

		-- get years up to @year + @yearsForward
		or (cfy.FY_START between sy.FY_START and DATEADD(YEAR, @yearsForward, sy.FY_START))
	)
  )
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[COMPANY_FISCAL_YEARS_VIEW_CORE] TO [webuser]
GO
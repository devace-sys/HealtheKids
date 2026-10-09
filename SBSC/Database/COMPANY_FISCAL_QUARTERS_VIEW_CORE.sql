USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.COMPANY_FISCAL_QUARTERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.COMPANY_FISCAL_QUARTERS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[COMPANY_FISCAL_QUARTERS_VIEW_CORE] (    
	   @year              DateTime
	 , @fiscalYearID      Bigint
	 , @quarterNumber     Int
	 , @recID             Bigint
)
     
RETURNS TABLE

/***************************************************************************    
 * COMPANY_FISCAL_QUARTERS_VIEW_CORE */    
/**    
 * Returns a a single quarter matching @recID or the quarters in @year
 *     
 ***************************************************************************/     

AS RETURN(

select     
    id                     = cfq.ID
  , [name]                 = cfq.QTR_DEFINITION 
  , fyID                   = cfq.FY_ID
  , quarterNumber          = cfq.QTR
  , quarterStartDate       = cfq.QTR_START
  , quarterStartDateStr    = dbo.RPT_DATE_FMT (cfq.QTR_START)
  , quarterStartDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(cfq.QTR_START)
  , quarterEndDate         = cfq.QTR_END
  , quarterEndDateStr      = dbo.RPT_DATE_FMT (cfq.QTR_END)
  , quarterEndDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD(cfq.QTR_END)
  from dbo.COMPANY_FISCAL_QUARTERS as cfq
  join dbo.COMPANY_FISCAL_YEARS as cfy on cfq.FY_ID = cfy.ID
  where (
		(1=1)
	and ((@year is null)         or (Convert(Date, @year) between cfy.FY_START and cfy.FY_END))
	and ((@fiscalYearID is null) or (cfy.ID = @fiscalYearID))
	and ((@quarterNumber is null) or (cfq.QTR = @quarterNumber))
	and ((@recID is null)        or (cfq.ID = @recID))
  )
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[COMPANY_FISCAL_QUARTERS_VIEW_CORE] TO [webuser]
GO
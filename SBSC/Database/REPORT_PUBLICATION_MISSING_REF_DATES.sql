USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_MISSING_REF_DATES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.REPORT_PUBLICATION_MISSING_REF_DATES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[REPORT_PUBLICATION_MISSING_REF_DATES]
(
@DateStart DATETIME, 
@DateEnd   DATETIME
)

RETURNS TABLE 

/***************************************************************************    
 * REPORT_PUBLICATION_MISSING_REF_DATES */    
/**    
 * Returns a list of missing reference dates.
 * These dates represent each reference date that the report distribution
 * application must be run manually to "make up" the date.
 *
 * @return table 
 ***************************************************************************/     

AS RETURN
(
  select PlannedRefDate as [MissingRefDate] 
  from REPORT_PUBLICATION_PLANNED_VS_ACTUAL_REF_DATES (@DateStart, @DateEnd) 
  where ActualRefDate is null
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[REPORT_PUBLICATION_MISSING_REF_DATES] TO [webuser]
GO   


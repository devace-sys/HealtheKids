USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_CURRENT_QUARTERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_CURRENT_QUARTERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_CURRENT_QUARTERS_VIEW] ()  
 
RETURNS TABLE
 
 /***************************************************************************    
  * RMTS_CURRENT_QUARTERS_VIEW */    
 /**    
  * Returns a table of possible quarters with respect to today
  *   
  * @return                 Table 
  ***************************************************************************/     
 
AS RETURN
( 
  select top (dbo.CONST_MAX_ROWS()) 
      id                 = t1.ID 
    , [name]             = t1.QTR_DEFINITION
    , [isCurrentQuarter] = t1.IS_CURRENT_QTR
    , [startDateStr]     = dbo.RPT_DATE_FMT(t1.QTR_START)
    , [endDateStr]       = dbo.RPT_DATE_FMT(t1.QTR_END)
    , [qtrNumber]        = t1.QTR
    , [startDate]        = t1.QTR_START
    , [endDate]          = t1.QTR_END
    , [fyID]             = t1.FY_ID
  from dbo.RMTS_CURRENT_QUARTERS_VIEW_CORE ((convert(date,getdate()))) as t1
  order by      
    t1.QTR_START desc
)

GO

GRANT SELECT ON  [dbo].[RMTS_CURRENT_QUARTERS_VIEW] TO [webuser]
GO

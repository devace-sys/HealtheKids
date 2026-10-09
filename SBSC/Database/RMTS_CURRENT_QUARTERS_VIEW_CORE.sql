USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_CURRENT_QUARTERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_CURRENT_QUARTERS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_CURRENT_QUARTERS_VIEW_CORE] (
  @today as date
)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * RMTS_CURRENT_QUARTERS_VIEW_CORE */    
 /**    
  * Returns a table of possible quarters with respect to today
  *
  * Note: Predicates work with the clustered index ordering 
  *   
  * @return                 Table 
  ***************************************************************************/     
 
AS RETURN
( 
  with curr_month as ( select num = DATEPART(month, @today) ),
  curr_quar as ( select num = CASE WHEN m_.num > 9 THEN 4 WHEN m_.num > 6 THEN 3 WHEN m_.num > 3 THEN 2 ELSE 1 END
                 FROM curr_month m_ )
  select 
      cfq.*
	, IS_CURRENT_QTR = convert(bit,(iif ((@today between cfq.QTR_START and cfq.QTR_END),1,0)))
  from  curr_quar q_
  OUTER APPLY dbo.COMPANY_FISCAL_QUARTERS as cfq  
  where (
         (cfq.ID >= 105) /* No earlier than 7/1/2020 ID = 105 */ 
     and (cfq.QTR_START <= @today) /* No later than today */
   --and ((cfq.QTR_END >= dateadd(MONTH, ( -24 - ( ( q_.num + 1 ) * 3) ), @today)) and (cfq.QTR_START <= @today)) /* Rolling window */
  )
)

GO

GRANT SELECT ON  [dbo].[RMTS_CURRENT_QUARTERS_VIEW_CORE] TO [webuser]
GO

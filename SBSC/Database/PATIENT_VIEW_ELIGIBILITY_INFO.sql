USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_ELIGIBILITY_INFO') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_ELIGIBILITY_INFO
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_ELIGIBILITY_INFO]    
(@clientID    as INT,
 @patID       as INT 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_VIEW_ELIGIBILITY_INFO */    
 /**    
  * Returns eligibility info for a given patient in a format suitable
  * for display in an informational table.
  *    
  * @param  clientID      Client id
  * @param  patID         Patient id
  * @return               Table 
  ***************************************************************************/                         
     
AS RETURN
(


/*-------------------------------
 * Return rows
 *------------------------------*/

select 
  dbo.RPT_DATE_FMT (monthDate) as [MonthDate], 
  eFlag                        as [Eligible]   
from 
  dbo.PATIENT_ELIGIBILITY (@clientID, @patID, 1, null)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_ELIGIBILITY_INFO] TO [webuser]
GO   

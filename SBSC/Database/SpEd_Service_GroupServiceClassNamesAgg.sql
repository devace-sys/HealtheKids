USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SpEd_Service_GroupServiceClassNamesAgg]'))
DROP VIEW [dbo].[SpEd_Service_GroupServiceClassNamesAgg]
GO

CREATE VIEW [dbo].[SpEd_Service_GroupServiceClassNamesAgg] 
AS 

/***************************************************************************    
 * SpEd_Service_GroupServiceClassNamesAgg */    
/**    
 * 
 * @return table
 ***************************************************************************/     

select 
   t1.spEdSvcCodeValue
 , groupSvcClassNames = STRING_AGG(t1.groupSvcClassName,' | ')
from dbo.SpEd_Service_GroupServiceClassNames as t1
group by 
  t1.spEdSvcCodeValue

GO



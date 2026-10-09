USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SpEd_Service_Avg_Rate_Data]'))
DROP VIEW [dbo].[SpEd_Service_Avg_Rate_Data]
GO

CREATE VIEW [dbo].[SpEd_Service_Avg_Rate_Data] 
AS 

/***************************************************************************    
 * SpEd_Service_Avg_Rate_Data */    
/**    
 * 
 * @return table
 ***************************************************************************/     

select
   q1.spEdSvcCodeValue
 , q1.avgRate
 , q1.avgUnitPerMinFactor
 , billableSvc = convert(bit,(iif((q1.avgRate != 0),1,0)))
from
(
  select 
      t1.spEdSvcCodeValue
    , avgRate             = avg(t1.rate) 
    , avgUnitPerMinFactor = avg(t1.unitPerMinFactor)
  from dbo.SpEd_Service_GroupID_PlanID_NameID_Data as t1
  group by 
    t1.spEdSvcCodeValue
) as q1

GO



USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_DUP_ROUTE_DATA_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_DUP_ROUTE_DATA_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_DUP_ROUTE_DATA_VIEW_CORE] (
   @userID                 bigint
 , @userGroup              int
 , @userRank               int
 , @clientID               bigint
 , @routeID                bigint
 , @monDate                date
 , @tueDate                date
 , @wedDate                date
 , @thuDate                date
 , @friDate                date
)
returns table as return
(

with 

/*============================================================
 * Route and days where multiple sheets have been printed for
 * the same route and days
 *============================================================*/  

cte_p1
as
(
select 
   CLIENT_ID
 , ROUTE_ID
 , MON_DATE
 , TUE_DATE
 , WED_DATE 
 , THU_DATE
 , FRI_DATE 
from dbo.TRANSPORTATION_MGMT_ROUTE_SHEET as t1
where (
      (1=1)
  and ((@clientID is null) or (CLIENT_ID = @clientID))
  and ((@routeID  is null) or (ROUTE_ID  = @routeID))
  and ((@monDate  is null) or (MON_DATE  = @monDate))
  and ((@tueDate  is null) or (TUE_DATE  = @tueDate))
  and ((@wedDate  is null) or (WED_DATE  = @wedDate))
  and ((@thuDate  is null) or (THU_DATE  = @thuDate))
  and ((@friDate  is null) or (FRI_DATE  = @friDate))
  and (ACTIVE = 1)
)
group by 
   CLIENT_ID
 , ROUTE_ID
 , MON_DATE
 , TUE_DATE
 , WED_DATE 
 , THU_DATE
 , FRI_DATE

having (COUNT(ID) > 1)
)
,

/*============================================================
 * Route sheets that have the same route and days
 *============================================================*/  

cte_p2
as
(

select 
  t1.* 
from dbo.TRANSPORTATION_MGMT_ROUTE_SHEET as t1
join cte_p1                              as t2 on  t2.CLIENT_ID = t1.CLIENT_ID
                                               and t2.ROUTE_ID = t1.ROUTE_ID
                                               and t2.MON_DATE = t1.MON_DATE
                                               and t2.TUE_DATE = t1.TUE_DATE
                                               and t2.WED_DATE = t1.WED_DATE
                                               and t2.THU_DATE = t1.THU_DATE
                                               and t2.FRI_DATE = t1.FRI_DATE
)
,

/*============================================================
 * Route sheets that have the same route and days and 
 * their processing status
 *============================================================*/  

cte_p3
as
(
select 
   t1.*
  ,PROCESSING_ID = t2.ID
  ,PROCESSING_DATE = t2.CREATED_ON
from cte_p2                                          as t1
left join TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING as t2 on t2.CLIENT_ID = t1.CLIENT_ID
                                                           and t2.SHEET_ID = t1.ID
)

select * from cte_p3

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_DUP_ROUTE_DATA_VIEW_CORE] TO [webuser]
GO
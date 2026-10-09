USE SPEDMON
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW_CORE] (
    @clientID       bigint
  , @taskID	        bigint
  , @isPending      bit
  , @isNotCompleted bit
  , @isCompleted    bit
  , @active         bit
  , @recID          bigint

  , @fyID     bigint
  
) 
   
 
RETURNS TABLE
  
AS RETURN
( 

with

cte_p1
  -- this could eventually be a table variable, not CTE

as
(
  select
	  ccci.id
	, ccci.clientID
	, clientName             = cc.CLIENT_NAME
	, clientComplianceItemID = cci.id
	, cci.taskID   
	, cci.taskName
 		
	, COALESCE(  ccci.clientSpecificTaskDueDate, cci.dueDate )                           dueDate	 

	, COALESCE(   ccci.clientSpecificTaskDashboardDate, cci.dateToShowOnDashboard )        dateToShowOnDashboard
	
	, ccci.notes
	, ccci.isComplete
	, isCompleted          = convert(bit,(isnull(ccci.isComplete,0)))	
	, ccci.dateCompleted
	, dateCompletedStr	   = dbo.RPT_DATE_FMT(ccci.dateCompleted)
	, dateCompletedStrYMD  = dbo.RPT_DATE_FMT_YYYY_MM_DD(ccci.dateCompleted) 


       -- , fyID
       -- , [FY_DEFINITION]

	, createdOrLastModifiedOn = coalesce(ccci.lastModified,  ccci.created)
	, createdOrLastModifiedBy = coalesce(ccci.lastModifiedBy,ccci.createdBy)

  from dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS  as ccci
  join dbo.CLIENTS_Client                  as cc on cc.CLIENT_ID = ccci.clientID

  cross apply dbo.CLIENT_COMPLIANCE_ITEMS_VIEW_CORE (@taskID, null, ccci.clientComplianceItemID ) as cci

  -- TODO: not sure why this simple restview is populated from a join of, like, at least 3 tables:
  --       CLIENT_COMPLIANCE_ITEMS, CLIENT_COMPLIANCE_TASKS, CLIENT_COMPLIANCE_CLIENT ITEMS

  --       seems like maybe there's some overhead that should have been caught and simplified
  --       much earlier on in the process of developing this,
  --       or at least the reasoning here could have been documented better.

  

  where (
		 (1=1)
	 and ((@clientID is null)   OR (ccci.clientID   = @clientID))

	 and (ccci.active     = ISNULL( @active, 1) )
                          -- was returning deleted records into restview; fixed

	 and ((@recID is null)      OR (ccci.id         = @recID))
  )
),

cte_p2 as (

  select
       p1.*
    ,  cfy.[ID]        fyID
    , [FY_DEFINITION]
  FROM
  cte_p1 p1

  LEFT JOIN [dbo].[COMPANY_FISCAL_YEARS]  cfy
    ON   p1.[dateToShowOnDashboard] >= [FY_START] AND p1.[dateToShowOnDashboard] <= [FY_END]

         -- using the COALESCED values for dashboard date or client specific dashboard date

),

cte2_taskCounts as (

  SELECT

   COUNT(*) taskCount,
   clientID, FY_DEFINITION, taskID

   FROM  cte_p2
   GROUP  BY

     clientID, FY_DEFINITION, taskID
)
,
cte_p3
as
(
select 
       p2.*

      ,  dateToShowOnDashboardStr      = dbo.RPT_DATE_FMT( dateToShowOnDashboard  )
      ,  dateToShowOnDashboardStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD( dateToShowOnDashboard  ) 

      ,  dueDateStr	               =   dbo.RPT_DATE_FMT( dueDate ) 
      ,  dueDateStrYMD                 =   dbo.RPT_DATE_FMT_YYYY_MM_DD( dueDate  ) 
 
    ,  lastModified          = p2.createdOrLastModifiedOn
    ,  lastModifiedStr       = dbo.RPT_DATE_FMT(p2.createdOrLastModifiedOn) 
    ,  lastModifiedByNameStr = m.FirstName + N' ' + m.LastName
    ,  isPending = convert(bit,(iif (( p2.isCompleted = 1 ), 0,( iif( (datediff(day, p2.dateToShowOnDashboard, getdate()) < 0), 1, 0)))))

    ,  t_C.taskCount
    ,  DENSE_RANK()  OVER   ( PARTITION BY t_C.clientID, t_C.FY_DEFINITION, t_C.taskID ORDER BY dueDate ASC )   as  rankedTaskNumber

from  cte2_taskCounts     t_C
     
JOIN  cte_p2               as p2
                           ON p2.clientID = t_C.clientID  AND  p2.FY_DEFINITION = t_C.FY_DEFINITION  AND  p2.taskID = t_C.taskID

join users.dbo.Users      as u on u.userrid = p2.createdOrLastModifiedBy
join users.dbo.Membership as m on m.UserId  = u.UserId
)
,
cte_p4
as
(
select 
    p3.*

  , '#' + CAST( rankedTaskNumber as varchar(15) ) + ' of ' + CAST( taskCount as varchar(15) )  as descriptiveRankingPerClientFyTask
  , isNotCompleted = convert(bit,(iif ((p3.isCompleted = 1), 0,( iif((p3.isPending=0),1,0)))))
from cte_p3 as p3
)
select 
    p4.* 
from cte_p4 as p4
where (
      (1=1)
  and  ((@isCompleted    is null) or (p4.isCompleted    = @isCompleted))
  and  ((@isPending      is null) or (p4.isPending      = @isPending))
  and  ((@isNotCompleted is null) or (p4.isNotCompleted = @isNotCompleted))
  and  (( @fyID  IS NULL)        OR ( @fyID = fyID  )  )
)
)

GO

GRANT SELECT ON  [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW_CORE] TO [webuser]
GO

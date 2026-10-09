USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_START_END_DATES_BY_WORK_WEEK') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_START_END_DATES_BY_WORK_WEEK
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GET_START_END_DATES_BY_WORK_WEEK] ( 
    @startDate                            datetime
  , @endDate                              datetime 
  , @adjustStartEndDateToStartEndWorkWeek bit = 0
)
returns table 
as return
(
with
cte_p0
as
(
  /* If requested, ajust start and end dates so they fall on the 
   * start of the work week (Mon)
   * and end of the work week (Fri) 
   * otherwise use values passed in
   */
 
  select top 1     
    sDate  = iif((@adjustStartEndDateToStartEndWorkWeek = 1)
	            , (dateadd(day,0,(dateadd(wk, datediff(wk,0,@startDate),0))))
			    , @startDate)

  , eDate  = iif((@adjustStartEndDateToStartEndWorkWeek = 1)
                , (dateadd(day,4,(dateadd(wk, datediff(wk,0,@endDate)  ,0))))
			    , @endDate)
)
,
cte_p1
as
(
  select 
    t2.yn
	,t2.wn
	,t2.n
	,t2.startDate
	,t2.endDate 
  from cte_p0 as p0
  cross apply (
    select  
        yn = t1.yn
      , wn = t1.wn
	  , t1.n
      , t1.startDate
      , t1.endDate
    from dbo.GET_START_END_DATES_BY_WORK_DAY ( p0.sDate, p0.eDate) as t1
  ) as t2
)
,
cte_p2
as
(
select 
    p1.yn
  , p1.wn
  , startDate = min(p1.startDate)
  , endDate   = max(p1.endDate)
  , numDays   = count(p1.n)
from cte_p1 as p1
group by 
    p1.yn
  , p1.wn
)
select  
    n = ROW_NUMBER() over(order by p2.yn,p2.wn asc)
  , p2.startDate
  , p2.endDate 
  , p2.numDays
from cte_p2 as p2
)
go

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_START_END_DATES_BY_WORK_MONTH') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_START_END_DATES_BY_WORK_MONTH
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_START_END_DATES_BY_WORK_MONTH] ( 
    @startDate datetime
  , @endDate   datetime 
)
returns table 
as return
(

/* It is recommended you call this with an option (maxrecursion 0) */

with
cte_p1
as
(
  select  
      yn = datepart(year,t1.startDate)
	, mn = datepart(month,t1.startDate)
    , t1.n
    , t1.startDate
    , t1.endDate
  from dbo.CALC_START_END_DATES_BY_WORK_DAY ( @startDate, @endDate) as t1
)
,
cte_p2
as
(
select 
    p1.yn
  , p1.mn
  , startDate = min(p1.startDate)
  , endDate   = max(p1.endDate)
  , numDays   = count(p1.n)
from cte_p1 as p1
group by 
    p1.yn
   ,p1.mn
)
select  
    n = ROW_NUMBER() over(order by p2.yn, p2.mn asc)
  , p2.startDate
  , p2.endDate 
  , p2.numDays
from cte_p2 as p2
)
go

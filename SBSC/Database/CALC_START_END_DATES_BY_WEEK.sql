USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_START_END_DATES_BY_WEEK') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_START_END_DATES_BY_WEEK
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_START_END_DATES_BY_WEEK] ( 
    @startDate  datetime
  , @endDate    datetime 
  , @weekStarts int = 7 /* 1 = monday , 7 = sunday */
  , @weekEnds   int = 6 /* 1 = monday = 7 sunday*/
)
returns table 
as return
(

/* It is recommended you call this with an option (maxrecursion 0) */

with dates (n,sDate, eDate)
as
(
  select 
    n=1
  , sDate  = dbo.DATE_GET_PREVIOUS_WEEKDAY ( (@startDate),                   @weekStarts)
  , eDate  = dbo.DATE_GET_PREVIOUS_WEEKDAY ( (dateadd(week, 1, @startDate)), @weekEnds)
  union all
  select 
    n=n+1
  , sDate  = dbo.DATE_GET_PREVIOUS_WEEKDAY ( (dateadd(week, 1, sDate)), @weekStarts)
  , eDate  = dbo.DATE_GET_PREVIOUS_WEEKDAY ( (dateadd(week, 1, eDate)), @weekEnds)
  from dates
  where (eDate < @endDate)
)

/* We replace first start date with @startDate and last end date with @endDate */

select 
   n
 , startDate =  iif( (n=1), @startDate, sDate)
 , endDate    = iif( (n= (LAST_VALUE(n) over(order by @endDate))),@endDate,eDate)
from dates as t1 
where (@startDate <= @endDate) /* Prevent results if startDate is greater than endDate */
)
go

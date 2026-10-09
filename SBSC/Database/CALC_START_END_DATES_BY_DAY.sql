USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_START_END_DATES_BY_DAY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_START_END_DATES_BY_DAY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_START_END_DATES_BY_DAY] ( 
    @startDate datetime
  , @endDate   datetime 
)
returns table 
as return
(

/* It is recommended you call this with an option (maxrecursion 0) */

with dates (n,sDate) 
as
(   select 
       n=1
      ,sDate = @startDate
	union all
    select 
	   n=n+1
	  ,sDate = dateadd(day,1,sDate) /* Advance by 1 day */
    from dates 
    where (sDate < @EndDate)
)

select 
    t1.n
  , startDate = t1.sDate 
  , endDate   = t1.sDate
from dates as t1
where (@startDate <= @endDate) /* Prevent results if startDate is greater than endDate */
)
go

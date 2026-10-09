USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_START_END_DATES_BY_MONTH') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_START_END_DATES_BY_MONTH
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_START_END_DATES_BY_MONTH] ( 
    @startDate datetime
  , @endDate   datetime 
)
returns table 
as return
(

/* It is recommended you call this with an option (maxrecursion 0) */

with 
dates (n,sDate,eDate)
as
(
  select 
	   n=1
    , sDate = DATEADD(DAY, 1, EOMONTH(@startDate, -1)) /* Get start of month for @startDate*/
    , eDate = eomonth(@startDate)                      /* Get end of month for @startDate*/
  union all
  select 
	  n=n+1 
    , sDate = DATEADD(month,1,sDate)                  /* Advance sDate by one month */
	, eDate = eomonth(DATEADD(month,1,eDate))         /* Advance eDate by one month and make sure its eomonth */
  from dates
  where (eDate < @endDate)
)
/* We replace first start date with @startDate and last end date with @endDate */
select 
    n
  , startDate =  iif( (n=1), @startDate, sDate)
  , endDate    = iif( (n= (LAST_VALUE(n) over(order by @endDate))),@endDate,eDate)
from dates 
where (@startDate <= @endDate)  /* Prevent results if startDate is greater than endDate */
)
go

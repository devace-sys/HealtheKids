USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_START_END_DATES_BY_YEAR') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_START_END_DATES_BY_YEAR
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_START_END_DATES_BY_YEAR] ( 
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
    , sDate = DATEFROMPARTS(DATEPART(year,@startDate),1,1)
    , eDate = DATEFROMPARTS(DATEPART(year,@startDate),12,31)
  union all
  select 
	  n=n+1 
    , sDate = DATEADD(year,1,sDate)
	, eDate = DATEADD(year,1,eDate)
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

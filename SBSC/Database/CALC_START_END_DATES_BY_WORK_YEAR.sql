USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_START_END_DATES_BY_WORK_YEAR') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_START_END_DATES_BY_WORK_YEAR
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_START_END_DATES_BY_WORK_YEAR] ( 
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
/* If start or end dates fall on a weekend, replace with appropriate weekday */
select 
    n
  , startDate =  dbo.CALC_CLOSEST_WEEKDAY(sDate,1)
  , endDate    = dbo.CALC_CLOSEST_WEEKDAY(eDate,-1)
from dates 
where (@startDate <= @endDate)  /* Prevent results if startDate is greater than endDate */
)
go

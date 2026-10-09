USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_START_END_DATES_BY_WORK_DAY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_START_END_DATES_BY_WORK_DAY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Note: Start and end date need to have a time component of 00:00:00 */

CREATE FUNCTION [dbo].[GET_START_END_DATES_BY_WORK_DAY] ( 
    @startDate datetime
  , @endDate   datetime 
)
returns table 
as return
(

select 
    n         = ROW_NUMBER() over(order by t1.ID asc)
  , startDate = t1.DAY_START_AS_DATETIME
  , endDate   = t1.DAY_END_AS_DATETIME
  , yn        = t1.YEAR_N
  , mn        = t1.MONTH_N
  , wn        = t1.WEEK_N
  
from dbo.COMPANY_FISCAL_WORK_DAYS as t1
where 
  (t1.DAY_START_AS_DATETIME between @startDate and @endDate)

)
go

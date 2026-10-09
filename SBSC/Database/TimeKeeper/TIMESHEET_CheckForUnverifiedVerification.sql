
use timekeeper
go


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TIMESHEET_CheckForUnverifiedVerification') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TIMESHEET_CheckForUnverifiedVerification
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TIMESHEET_CheckForUnverifiedVerification] ( @employeeId bigint, @minDaysAgo int, @maxDaysAgo int  )
   
 RETURNS TABLE
 AS 
 return
 (
 
 with
 cte_p1
 as
 (
   select 
     etv.*
   from dbo.EmployeeTimeVerification as etv
   join dbo.Employees                as e on e.id = etv.employeeID
   where ( 
         (e.noPayroll = 0)      /* Skip staff that are not on the payroll */
     and (e.employeeStatus = 0) /* Only active staff */
	 and (( @employeeId is null) or (etv.employeeID = @employeeId))
  )
 )
 ,
 cte_p2
 as
 (
  select 
	   p1.*
	 , lastDateTimeOfSchedule = convert(datetime,p1.lastDayOfSchedule)
	 , today                  = getdate()
	from
		cte_p1 as p1
	where (
	  (p1.isVerified = 0) /* Column cannot be null so we can test this */     
	)
 )
,
cte_p3
as
(
select 
    p2.* 
  , daysOverdue = datediff(day,p2.lastDateTimeOfSchedule, p2.today) 
from cte_p2 as p2
)
select top 100000
    p3.id
  , p3.employeeID
  , p3.lastDayOfSchedule
  , p3.dateVerified
  , p3.comments
  ,daysOverdue
  ,firstDayOfSchedule = CASE WHEN DATEPART(dw, p3.lastDayOfSchedule) = 1 THEN lastDayOfSchedule ELSE DATEADD(day,( 1 - DATEPART(dw, p3.lastDayOfSchedule) ), p3.lastDayOfSchedule) END
from cte_p3 as p3
where 
  (p3.daysOverdue >= @minDaysAgo)
  AND
  ((@maxDaysAgo IS NULL) OR (p3.daysOverdue < @maxDaysAgo))

order by 
  p3.lastDayOfSchedule
)

GO

GRANT SELECT ON [dbo].[TIMESHEET_CheckForUnverifiedVerification] to webuser
GO

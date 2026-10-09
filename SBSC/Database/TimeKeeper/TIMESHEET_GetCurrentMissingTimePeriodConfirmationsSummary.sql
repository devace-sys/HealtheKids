use timekeeper
go


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary] (  )
RETURNS TABLE
AS 
RETURN
(

select 
    q1.firstName
  , q1.lastName
  , q1.emailWork
  , q1.emailPersonal
  , confirmationsMissingJSON = '{listItems:[' + q1.tkps + ']}' 
from
(
  select 
     p.firstName
   , p.lastName
   , [emailWork]     = u.email
   , [emailPersonal] = e.EmailAddress
   , uv3.tkps
  from dbo.Employees as e 
  join dbo.People    as p on p.id = e.personID
                     AND e.noPayroll != 1

  cross apply (
    select top 1 
      uvc.email 
    from Users.dbo.USERS_VIEW_CORE (null,null,null,'spedcare',p.spedMonUserName,null,null,null) as uvc
    where 
      (uvc.pcalStaff = 1)
  ) as u

  cross apply (
    select 
      tkps = STRING_AGG(uv2.tkp, ',')
    from
    (
      select top 100000
            tkp =  
			    + '{'
				+ '"title":"' 
				+ convert(varchar, uv1.firstDayOfSchedule, 101)   
		        + ' to ' 
				+ convert(varchar, uv1.lastDayOfSchedule, 101)
		        + '"'
				+ ',"description":"CONFIRMATION ' + convert(varchar(50),uv1.daysOverdue) + ' DAYS OVERDUE - ' + schh.hoursSum + payrollSubtotals + '"'
				+ '}'
      from dbo.TIMESHEET_CheckForUnverifiedVerification ( e.id, 1, null) as uv1 
      
      OUTER APPLY (
      SELECT
        'Hours Scheduled: ' +
        ISNULL( 
          CAST(
            CAST( 
              SUM(numHoursInterval)
              AS numeric(6,2)
            )
            AS VARCHAR(10)
          )
          ,
         '0.0'
        ) + ' ' hoursSum
     FROM [dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF]
     (
	      uv1.firstDayOfSchedule
	     ,uv1.lastDayOfSchedule
	     ,e.id
     ) schh

    ) schh

      OUTER APPLY (
      SELECT
        'Hours Reported: ' +
        ISNULL(  CAST(Hours_reported AS VARCHAR(7)), '0.0') + ' Regular Hours: ' + ISNULL( CAST(Regular_Hours AS VARCHAR(7)), '0.0') +
        ' Pay Holiday Hours: ' + ISNULL(  CAST(PayHoliday_Hours AS VARCHAR(7)) , '0.0') + ' Pay Sick Hours: ' + ISNULL(  CAST(PaySick_Hours AS VARCHAR(7)) , '0.0') +
        ' Pay Vacation: ' + ISNULL(  CAST(PayVacation AS VARCHAR(7)) , '0.0') + ' Paid Break: ' + ISNULL(  CAST(Paid_break AS VARCHAR(7)) , '0.0') +
        ' Unpaid Time Off: ' + ISNULL(  CAST(UnPaid_TimeOff AS VARCHAR(7)), '0.0') payrollSubtotals
     FROM EMPLOYEE_PAYROLL_PORTED(uv1.firstDayOfSchedule, uv1.lastDayOfSchedule) epp WHERE epp.Employee_ID = e.id

    ) edp

      order by 
	    uv1.daysOverdue asc
    ) as uv2
  ) as uv3

  where ( 
        (e.WeeklyHoursVerfied = 1)
    and (uv3.tkps is not null)
  )
) as q1

)

GO

GRANT SELECT ON [dbo].[TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary] to webuser
GO

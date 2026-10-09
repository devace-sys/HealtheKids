USE [TimeKeeper]
GO

DROP FUNCTION if exists [dbo].[TIMESHEET_FindEmployeeVerificationsByDateRange]
GO

CREATE FUNCTION [dbo].[TIMESHEET_FindEmployeeVerificationsByDateRange](
@startDate date,
@endDate   date
)
returns table
as
return	              						 	
		select top 50000
			ETV.id
			,E.id AS 'employeeId'
			,P.lastName
			,P.firstName
			,ETV.lastDayOfSchedule
			,ETV.dateVerified
			,ETV.comments
		from
			People P
			inner join Employees E
				ON E.personID = P.id
			inner join EmployeeTimeVerification ETV
				ON ETV.employeeID = E.id
		where
			(@startDate IS NULL OR ETV.lastDayOfSchedule >= @startDate)
			AND (@endDate IS NULL OR ETV.lastDayOfSchedule <= @endDate)
		order by
			ETV.lastDayOfSchedule DESC, P.lastName
--end	
GO

GRANT SELECT ON [dbo].[TIMESHEET_FindEmployeeVerificationsByDateRange] TO webuser
GO
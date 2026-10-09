USE [Spedmon]
GO

DROP FUNCTION if exists [dbo].[TimeKeeper_TIMESHEET_FindEmployeeVerificationsByDateRange]
GO

CREATE FUNCTION [dbo].[TimeKeeper_TIMESHEET_FindEmployeeVerificationsByDateRange](
@startDate date,
@endDate   date
)
returns table
as
return	              						 	
		select *
		from [TimeKeeper].[dbo].[TIMESHEET_FindEmployeeVerificationsByDateRange] (
    @startDate,
    @endDate
    )		

GO

GRANT SELECT ON [dbo].[TimeKeeper_TIMESHEET_FindEmployeeVerificationsByDateRange] TO webuser
GO
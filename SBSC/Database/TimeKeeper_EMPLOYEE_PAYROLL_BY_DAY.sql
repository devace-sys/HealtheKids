USE [SPEDMON]
GO

DROP FUNCTION if exists [dbo].[TimeKeeper_EMPLOYEE_PAYROLL_BY_DAY]
GO


CREATE FUNCTION [dbo].[TimeKeeper_EMPLOYEE_PAYROLL_BY_DAY](
@EmpId bigint,
@startDate datetime,
@endDate   datetime
) returns table
as return
(	
SELECT * FROM [TimeKeeper].dbo.EMPLOYEE_PAYROLL_BY_DAY(
@empId,
@startDate,
@endDate
)
)  
GO

GRANT SELECT ON TimeKeeper_EMPLOYEE_PAYROLL_BY_DAY to webuser
GO
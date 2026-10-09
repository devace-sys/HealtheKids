USE [spedmon]
GO

DROP FUNCTION if exists [dbo].[TimeKeeper_EMPLOYEE_PAYROLL_PORTED]
GO

CREATE FUNCTION [dbo].[TimeKeeper_EMPLOYEE_PAYROLL_PORTED](
@startDate datetime,
@endDate   datetime
) returns table
as return
(	
SELECT * FROM [TimeKeeper].dbo.EMPLOYEE_PAYROLL_PORTED(
@startDate,
@endDate
)
)  
GO

GRANT SELECT ON [dbo].[TimeKeeper_EMPLOYEE_PAYROLL_PORTED] TO webuser

GO


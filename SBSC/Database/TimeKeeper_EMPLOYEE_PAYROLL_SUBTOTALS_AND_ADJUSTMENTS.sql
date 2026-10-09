
USE [spedmon]
GO

DROP FUNCTION if exists [dbo].[TimeKeeper_EMPLOYEE_PAYROLL_SUBTOTALS_AND_ADJUSTMENTS]
GO

CREATE FUNCTION [dbo].[TimeKeeper_EMPLOYEE_PAYROLL_SUBTOTALS_AND_ADJUSTMENTS](
@startDate datetime,
@endDate   datetime
) returns table
as return
(	
SELECT * FROM [TimeKeeper].dbo.EMPLOYEE_PAYROLL_SUBTOTALS_AND_ADJUSTMENTS(
@startDate,
@endDate
)
)  
GO

GRANT SELECT ON [dbo].[TimeKeeper_EMPLOYEE_PAYROLL_SUBTOTALS_AND_ADJUSTMENTS] TO webuser

GO

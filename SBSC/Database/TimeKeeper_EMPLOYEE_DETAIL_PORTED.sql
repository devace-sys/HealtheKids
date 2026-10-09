USE [SPEDMON]
GO

DROP FUNCTION if exists [dbo].[TimeKeeper_EMPLOYEE_DETAIL_PORTED]
GO


CREATE FUNCTION [dbo].[TimeKeeper_EMPLOYEE_DETAIL_PORTED](
@EmpId bigint,
@startDate datetime,
@endDate   datetime
) returns table
as return
(	
SELECT * FROM [TimeKeeper].dbo.EMPLOYEE_DETAIL_PORTED(
@empId,
@startDate,
@endDate
)
WHERE Hours_reported > 0
)  
GO

GRANT SELECT ON TimeKeeper_EMPLOYEE_DETAIL_PORTED to webuser
GO


--SELECT top 10 * FROM [TimeKeeper].dbo.EMPLOYEE_DETAIL_PORTED(
--null,'2020-11-11','2020-11-13')
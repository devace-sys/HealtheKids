USE [TimeKeeper]
GO

DROP FUNCTION if exists [dbo].[EMPLOYEE_PAYROLL_BY_DAY]
GO

CREATE FUNCTION [dbo].[EMPLOYEE_PAYROLL_BY_DAY](
@emp       bigint,
@startDate datetime,
@endDate   datetime
) RETURNS TABLE
          	             
/******************************************************************************    
 * EMPLOYEE_DETAIL_PORTED*/    
/**    
 * Displays the detail list of employee time entries in a given date range 
 *
 * @emp                Employee ID
 * @startDate          Start date of the pay period
 * @endDate            End date of the pay period   
 * @return             Table
 *******************************************************************************/   			              	
as return
(			              						 	
select te_d.dateForTimeEntry "Date", epp.* FROM
[dbo].[TimeEntry_Day] te_d
CROSS APPLY [dbo].[EMPLOYEE_PAYROLL_PORTED](te_d.dateForTimeEntry, te_d.dateForTimeEntry ) epp
WHERE te_d.dateForTimeEntry >= @startDate AND te_d.dateForTimeEntry <= @endDate AND epp.Employee_ID = te_d.employeeID
AND (@emp IS NULL OR @emp = te_d.employeeID)
)
GO

grant select on [dbo].[EMPLOYEE_PAYROLL_BY_DAY] to webuser
GO
--select * FROM [dbo].[EMPLOYEE_PAYROLL_BY_DAY] (null, '2020-10-11', '2020-10-24')
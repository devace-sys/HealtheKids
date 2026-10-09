USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID]
(
	@ID BIGINT
)
AS    
BEGIN    
SET NOCOUNT ON;
	  
    select
	    *
    from
	    TimeKeeper.dbo.Employees
    where
        PaidForHolidays = 1
		AND ID = @ID
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID]  TO [webuser]
GO



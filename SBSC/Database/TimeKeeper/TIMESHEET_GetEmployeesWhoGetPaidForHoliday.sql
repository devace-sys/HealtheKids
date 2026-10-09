USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHoliday]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHoliday]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHoliday]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHoliday]
AS    
BEGIN    
SET NOCOUNT ON;
	  
    select
	    *
    from
	    TimeKeeper.dbo.Employees
    where
        PaidForHolidays = 1
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHoliday]  TO [webuser]
GO



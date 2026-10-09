USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHoliday]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHoliday]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHoliday]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHoliday]
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHoliday] 

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHoliday]  TO [webuser]
GO



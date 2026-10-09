USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID]
(
	@ID BIGINT
)
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID] @ID

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID]  TO [webuser]
GO



USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetEmployeeList]    Script Date: 1/25/2020 9:05:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetEmployeeList]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetEmployeeList]    Script Date: 1/25/2020 9:05:15 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetEmployeeList]
AS    
BEGIN    
SET NOCOUNT ON;
	
    exec [TimeKeeper].[dbo].[TIMESHEET_GetEmployeeList]

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetEmployeeList] TO [webuser]
GO


USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetEmployeeInfo]    Script Date: 1/25/2020 9:36:49 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetEmployeeInfo]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetEmployeeInfo]    Script Date: 1/25/2020 9:36:49 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetEmployeeInfo]
AS    
BEGIN    
SET NOCOUNT ON;
	
	exec [TimeKeeper].[dbo].[TIMESHEET_GetEmployeeInfo]
				     
END



GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetEmployeeInfo]  TO [webuser]
GO



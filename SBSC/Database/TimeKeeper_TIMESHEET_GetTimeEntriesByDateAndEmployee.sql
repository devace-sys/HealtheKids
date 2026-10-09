USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetTimeEntriesByDateAndEmployee]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetTimeEntriesByDateAndEmployee]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetTimeEntriesByDateAndEmployee]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetTimeEntriesByDateAndEmployee]
		@StartDate DateTime
		,@EndDate DateTime
		,@EmployeeId BIGINT 
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetTimeEntriesByDateAndEmployee] @StartDate, @EndDate, @EmployeeId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetTimeEntriesByDateAndEmployee]    TO [webuser]
GO



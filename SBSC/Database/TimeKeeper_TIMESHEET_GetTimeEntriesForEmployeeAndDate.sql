USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetTimeEntriesForEmployeeAndDate]    Script Date: 1/25/2020 9:25:52 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetTimeEntriesForEmployeeAndDate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetTimeEntriesForEmployeeAndDate]    Script Date: 1/25/2020 9:25:52 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetTimeEntriesForEmployeeAndDate]
  @EmployeeId                BIGINT,
  @StartDate                 DATETIME
AS    
BEGIN    
SET NOCOUNT ON;
	
	exec [TimeKeeper].[dbo].[TIMESHEET_GetTimeEntriesForEmployeeAndDate] @EmployeeId, @StartDate	
				     
END



GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetTimeEntriesForEmployeeAndDate]  TO [webuser]
GO



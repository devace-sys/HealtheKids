USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetTimeEntryDayForEmployeeAndDate]    Script Date: 1/25/2020 9:28:46 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetTimeEntryDayForEmployeeAndDate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetTimeEntryDayForEmployeeAndDate]    Script Date: 1/25/2020 9:28:46 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetTimeEntryDayForEmployeeAndDate]
  @EmployeeId                BIGINT,
  @StartDate                 DATETIME
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetTimeEntryDayForEmployeeAndDate] @EmployeeId, @StartDate
				     
END



GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetTimeEntryDayForEmployeeAndDate] TO [webuser]
GO


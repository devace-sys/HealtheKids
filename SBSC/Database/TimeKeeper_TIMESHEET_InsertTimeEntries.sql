USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertTimeEntries]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_InsertTimeEntries]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertTimeEntries]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_InsertTimeEntries]
	@timeEntryDayID BIGINT
	,@timeOfTask DATETIME
	,@numberMinutes INT
	,@timeEntrytaskID BIGINT
	,@orgClientID BIGINT
	,@note VARCHAR(2000)
	,@dateEntryUpdated DATETIME
	,@HasMultipleClients BIT
	,@holidayTaskID BIGINT
	,@Id BIGINT OUTPUT

AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_InsertTimeEntries] 	@timeEntryDayID
	,@timeOfTask
	,@numberMinutes
	,@timeEntrytaskID
	,@orgClientID
	,@note
	,@dateEntryUpdated
	,@HasMultipleClients
	,@holidayTaskID
	,@Id OUTPUT

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_InsertTimeEntries]    TO [webuser]
GO



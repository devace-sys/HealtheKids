USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteTimeEntries]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_DeleteTimeEntries]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteTimeEntries]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_DeleteTimeEntries]
	@timeEntryDayID BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	
delete
from TimeEntries
where timeEntryDayID = @timeEntryDayID

delete
from TimeEntry_Day
where id = @timeEntryDayID
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_DeleteTimeEntries]  TO [webuser]
GO



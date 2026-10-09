USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteTimeEntryForMultipleClient]    Script Date: 1/25/2020 8:03:30 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_DeleteTimeEntryForMultipleClient]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteTimeEntryForMultipleClient]    Script Date: 1/25/2020 8:03:30 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_DeleteTimeEntryForMultipleClient]
(
	@TimeEntryDayID						 BIGINT
	,@TimeEntrytaskID                    BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	DELETE FROM [TimeKeeper].[dbo].[TimeEntries]
		WHERE timeEntryDayID = @TimeEntryDayID
		  AND timeEntrytaskID = @TimeEntrytaskID

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_DeleteTimeEntryForMultipleClient]  TO [webuser]
GO



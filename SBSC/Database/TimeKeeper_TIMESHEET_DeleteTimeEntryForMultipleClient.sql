USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_DeleteTimeEntryForMultipleClient]    Script Date: 1/25/2020 9:34:20 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_DeleteTimeEntryForMultipleClient]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_DeleteTimeEntryForMultipleClient]    Script Date: 1/25/2020 9:34:20 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_DeleteTimeEntryForMultipleClient]
(
	@TimeEntryDayID                         BIGINT
	,@TimeEntryTaskID						 BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_DeleteTimeEntryForMultipleClient] @TimeEntryDayID, @TimeEntryTaskID

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_DeleteTimeEntryForMultipleClient]  TO [webuser]
GO


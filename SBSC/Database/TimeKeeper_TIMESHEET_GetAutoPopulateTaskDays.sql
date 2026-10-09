USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetAutoPopulateTaskDays]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetAutoPopulateTaskDays]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetAutoPopulateTaskDays]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetAutoPopulateTaskDays]
	@autoPopulateTaskDetailsId BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetAutoPopulateTaskDays] @autoPopulateTaskDetailsId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetAutoPopulateTaskDays]    TO [webuser]
GO



USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDays]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDays]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDays]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDays]
	@dayid SMALLINT
	,@autoPopulateTaskDetailsId BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_DeleteAutoPopulateTaskDays] @dayid, @autoPopulateTaskDetailsId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDays]    TO [webuser]
GO



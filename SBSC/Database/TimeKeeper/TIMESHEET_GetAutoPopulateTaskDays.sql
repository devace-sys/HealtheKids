USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoPopulateTaskDays]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetAutoPopulateTaskDays]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoPopulateTaskDays]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetAutoPopulateTaskDays]
	@autoPopulateTaskDetailsId BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	
	SELECT
		id
		,dayid
		,autoPopulateTaskDetailsId
		,numberOfMinutes
	FROM
		AutoPopulateTaskDays
	WHERE
		autoPopulateTaskDetailsId = @autoPopulateTaskDetailsId
	ORDER BY
		dayid

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetAutoPopulateTaskDays]  TO [webuser]
GO



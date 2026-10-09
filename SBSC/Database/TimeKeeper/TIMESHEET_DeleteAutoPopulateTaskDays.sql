USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteAutoPopulateTaskDays]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_DeleteAutoPopulateTaskDays]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteAutoPopulateTaskDays]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_DeleteAutoPopulateTaskDays]
	@dayid SMALLINT
	,@autoPopulateTaskDetailsId BIGINT
AS

BEGIN    
SET NOCOUNT ON;

	DELETE
	FROM
		AutoPopulateTaskDaysStartStopTime
	WHERE
		autoPopulateTaskDaysId in
		(
			SELECT
				id
			FROM
				AutoPopulateTaskDays
			WHERE
				dayid = @dayid	   
				AND autoPopulateTaskDetailsId = @autoPopulateTaskDetailsId
		)

    DELETE	
	FROM
		AutoPopulateTaskDays
	WHERE
		dayid = @dayid
	    AND autoPopulateTaskDetailsId = @autoPopulateTaskDetailsId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_DeleteAutoPopulateTaskDays]  TO [webuser]
GO



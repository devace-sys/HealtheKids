USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteAutoPopulateTaskDetails]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_DeleteAutoPopulateTaskDetails]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteAutoPopulateTaskDetails]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_DeleteAutoPopulateTaskDetails]
	@autoPopulateTaskTemplateId BIGINT
	,@timeentrytaskid BIGINT
AS    
BEGIN    
SET NOCOUNT ON;

	-- The DELETE statement conflicted with the REFERENCE constraint "FK_AutoPopulateTaskDaysStartStopTime_AutoPopulateTaskDays". 
	-- The conflict occurred in database "TimeKeeper", table "dbo.AutoPopulateTaskDaysStartStopTime", column 'autoPopulateTaskDaysId'.

	
	delete from AutoPopulateTaskDaysStartStopTime where autoPopulateTaskDaysId in
	(
		select id from AutoPopulateTaskDays where autoPopulateTaskDetailsId in 
		(
			select id from AutoPopulateTaskDetails where autoPopulateTaskTemplateId = @autoPopulateTaskTemplateId and timeentrytaskid = @timeentrytaskid
		)
	)

	delete from AutoPopulateTaskDays where autoPopulateTaskDetailsId in 
	(
		select id from AutoPopulateTaskDetails where autoPopulateTaskTemplateId = @autoPopulateTaskTemplateId and timeentrytaskid = @timeentrytaskid
	)

    DELETE	
	FROM
		AutoPopulateTaskDetails
	WHERE
	    autoPopulateTaskTemplateId = @autoPopulateTaskTemplateId
		AND timeentrytaskid = @timeentrytaskid

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_DeleteAutoPopulateTaskDetails]  TO [webuser]
GO



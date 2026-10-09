USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoPopulateTaskDetails]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetAutoPopulateTaskDetails]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoPopulateTaskDetails]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetAutoPopulateTaskDetails]
	@autoPopulateTaskTemplateId BIGINT
	,@timeEntryTaskId BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	
	SELECT
		AptDetails.id
		,ISNULL(AptDetails.clientId, -1) as 'clientId'
	FROM
		AutoPopulateTaskDetails APTDetails

	WHERE
		APTDetails.autoPopulateTaskTemplateId = @autoPopulateTaskTemplateId
		AND APTDetails.timeentrytaskid = @timeEntryTaskId
	ORDER BY
		AptDetails.id, clientId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetAutoPopulateTaskDetails]  TO [webuser]
GO



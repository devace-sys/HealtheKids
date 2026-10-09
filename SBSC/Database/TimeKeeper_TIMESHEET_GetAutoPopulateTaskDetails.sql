USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetAutoPopulateTaskDetails]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetAutoPopulateTaskDetails]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetAutoPopulateTaskDetails]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetAutoPopulateTaskDetails]
(
	@autoPopulateTaskTemplateId BIGINT
	,@timeEntryTaskId BIGINT)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetAutoPopulateTaskDetails] @autoPopulateTaskTemplateId, @timeEntryTaskId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetAutoPopulateTaskDetails]    TO [webuser]
GO



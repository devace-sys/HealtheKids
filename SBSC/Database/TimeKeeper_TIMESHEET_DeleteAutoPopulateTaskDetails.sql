USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDetails]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDetails]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDetails]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDetails]
	@autoPopulateTaskTemplateId BIGINT
	,@timeentrytaskid BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_DeleteAutoPopulateTaskDetails] @autoPopulateTaskTemplateId, @timeentrytaskid

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDetails]    TO [webuser]
GO



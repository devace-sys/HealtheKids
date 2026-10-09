USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDetails]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDetails]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDetails]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDetails]
	@autoPopulateTaskTemplateId BIGINT
	,@timeentrytaskid BIGINT
	,@clientid BIGINT
	,@Id BIGINT OUTPUT
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_InsertAutoPopulateTaskDetails] @autoPopulateTaskTemplateId, @timeentrytaskid, @clientid, @Id OUTPUT


END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDetails]    TO [webuser]
GO



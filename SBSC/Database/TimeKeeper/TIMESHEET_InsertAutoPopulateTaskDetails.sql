USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertAutoPopulateTaskDetails]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_InsertAutoPopulateTaskDetails]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertAutoPopulateTaskDetails]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_InsertAutoPopulateTaskDetails]
	@autoPopulateTaskTemplateId BIGINT
	,@timeentrytaskid BIGINT
	,@clientid BIGINT
	,@Id BIGINT OUTPUT
AS    
BEGIN    
	
	INSERT INTO AutoPopulateTaskDetails
	(
		autoPopulateTaskTemplateId
		,timeentrytaskid
		,clientid
	)
	VALUES
	(
		@autoPopulateTaskTemplateId
		,@timeentrytaskid
		,@clientid
	)

	SET @Id = SCOPE_IDENTITY()

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_InsertAutoPopulateTaskDetails]  TO [webuser]
GO



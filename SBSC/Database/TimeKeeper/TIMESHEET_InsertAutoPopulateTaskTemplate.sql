USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertAutoPopulateTaskTemplate]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_InsertAutoPopulateTaskTemplate]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertAutoPopulateTaskTemplate]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_InsertAutoPopulateTaskTemplate]
	@Name VARCHAR(50)
	,@Description VARCHAR(MAX)
	,@Id BIGINT OUTPUT
AS    
BEGIN    
	
	INSERT INTO AutoPopulateTaskTemplate
	(
		name
		,description
	)
	VALUES
	(
		@Name
		,@Description
	)

	SET @Id = SCOPE_IDENTITY()

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_InsertAutoPopulateTaskTemplate]  TO [webuser]
GO



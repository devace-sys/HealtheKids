USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateAutoPopulateTaskTemplate]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_UpdateAutoPopulateTaskTemplate]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateAutoPopulateTaskTemplate]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_UpdateAutoPopulateTaskTemplate]
	@Id BIGINT
	,@Name VARCHAR(50)
	,@Description VARCHAR(MAX)
AS    
BEGIN    
	
	UPDATE AutoPopulateTaskTemplate
	SET
		name = @Name
		,description = @Description
    WHERE
		id = @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_UpdateAutoPopulateTaskTemplate]  TO [webuser]
GO



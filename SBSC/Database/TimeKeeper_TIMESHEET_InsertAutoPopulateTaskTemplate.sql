USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskTemplate]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskTemplate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskTemplate]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskTemplate]
(
	@Name VARCHAR(50)
	,@Description VARCHAR(MAX)
	,@Id BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_InsertAutoPopulateTaskTemplate] @Name, @Description, @Id OUTPUT 

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskTemplate]    TO [webuser]
GO



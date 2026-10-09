USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskTemplate]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskTemplate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskTemplate]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskTemplate]
(
	@Id BIGINT
	,@Name VARCHAR(50)
	,@Description VARCHAR(MAX)
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_UpdateAutoPopulateTaskTemplate] @Id, @Name, @Description

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskTemplate]    TO [webuser]
GO



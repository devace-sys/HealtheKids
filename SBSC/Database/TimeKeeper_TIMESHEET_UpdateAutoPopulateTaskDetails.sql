USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskDetails]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskDetails]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskDetails]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskDetails]
	@Id BIGINT
	,@clientid BIGINT
AS    
BEGIN    
SET NOCOUNT ON;

	exec TimeKeeper.dbo.TIMESHEET_UpdateAutoPopulateTaskDetails @Id, @clientid

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskDetails]  TO [webuser]
GO



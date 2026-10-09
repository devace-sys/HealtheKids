USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId]
(
	@autoPopulateTaskDaysId BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId]
		@autoPopulateTaskDaysId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId]    TO [webuser]
GO



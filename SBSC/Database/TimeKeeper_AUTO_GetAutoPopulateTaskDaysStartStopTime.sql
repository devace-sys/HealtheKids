USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTime]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTime]
(
	@autoPopulateTaskDetailsId					 BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTime] @autoPopulateTaskDetailsId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTime]    TO [webuser]
GO



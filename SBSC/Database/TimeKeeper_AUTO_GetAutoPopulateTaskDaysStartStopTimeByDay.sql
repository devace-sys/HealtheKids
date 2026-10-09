USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByDay]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByDay]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByDay]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByDay]
(
  @autoPopulateTaskDetailsId BIGINT
  ,@dayId SMALLINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTimeByDay] @autoPopulateTaskDetailsId, @dayId


END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByDay]    TO [webuser]
GO



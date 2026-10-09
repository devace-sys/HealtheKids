USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId]    Script Date: 1/25/2020 7:36:11 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId]
GO

/****** Object:  StoredProcedure [dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId]    Script Date: 1/25/2020 7:36:11 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId]
(
  @autoPopulateTaskDaysId BIGINT 
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	SELECT 
		*
	FROM 
		[TimeKeeper].[dbo].[AutoPopulateTaskDaysStartStopTime]
	WHERE
		autoPopulateTaskDaysId = @autoPopulateTaskDaysId
	ORDER BY
		starttime, stoptime

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId] TO [webuser]
GO



USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_GetStartAndStopTimesByScheduledDate]    Script Date: 1/25/2020 7:37:45 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULE_GetStartAndStopTimesByScheduledDate]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_GetStartAndStopTimesByScheduledDate]    Script Date: 1/25/2020 7:37:45 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SCHEDULE_GetStartAndStopTimesByScheduledDate]
(
  @ScheduleId                BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	SELECT 
		[id]
		,[scheduleid]
		,[starttime]
		,[stoptime]
	FROM 
		[TimeKeeper].[dbo].[ScheduleStartAndStopTime]
	WHERE
		[scheduleid] = @ScheduleId
	ORDER BY
		[starttime]		     

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULE_GetStartAndStopTimesByScheduledDate] TO [webuser]
GO



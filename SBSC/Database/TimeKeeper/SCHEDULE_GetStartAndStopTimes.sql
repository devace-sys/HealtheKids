USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_GetStartAndStopTimes]    Script Date: 1/25/2020 7:38:36 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULE_GetStartAndStopTimes]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_GetStartAndStopTimes]    Script Date: 1/25/2020 7:38:36 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SCHEDULE_GetStartAndStopTimes]
(
  @Scheduleid                BIGINT
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
		[scheduleid] = @scheduleid	
	ORDER BY
		[starttime]		     

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULE_GetStartAndStopTimes] TO [webuser]
GO



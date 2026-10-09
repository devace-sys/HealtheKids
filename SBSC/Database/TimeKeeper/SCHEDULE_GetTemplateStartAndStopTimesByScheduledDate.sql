USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate]    Script Date: 1/25/2020 7:07:03 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate]    Script Date: 1/25/2020 7:07:03 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate]
(
  @ScheduleDayId                BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	SELECT 
		[id]
		,[autoPopulateScheduleDaysId]
		,[starttime]
		,[stoptime]
	FROM 
		[TimeKeeper].[dbo].[AutoPopulateScheduleStartAndStopTime]
	WHERE
		[autoPopulateScheduleDaysId] = @ScheduleDayId
	ORDER BY
		[starttime]		     

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate] TO [webuser]
GO



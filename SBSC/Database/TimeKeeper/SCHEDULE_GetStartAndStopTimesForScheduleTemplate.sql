USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_GetStartAndStopTimesForScheduleTemplate]    Script Date: 1/25/2020 7:12:45 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULE_GetStartAndStopTimesForScheduleTemplate]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_GetStartAndStopTimesForScheduleTemplate]    Script Date: 1/25/2020 7:12:45 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SCHEDULE_GetStartAndStopTimesForScheduleTemplate]
(
  @TemplateScheduleDayid                BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	SELECT 
		APSS.[id]
		,APSS.[starttime]
		,APSS.[stoptime]
	FROM 
		[TimeKeeper].[dbo].[AutoPopulateScheduleStartAndStopTime] APSS
		INNER JOIN [TimeKeeper].[dbo].[AutoPopulateScheduleDays] APSD
			ON APSD.id = APSS.autoPopulateScheduleDaysId
	WHERE
		APSD.id = @TemplateScheduleDayid	
	ORDER BY
		APSS.[starttime]		     

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULE_GetStartAndStopTimesForScheduleTemplate] TO [webuser]
GO



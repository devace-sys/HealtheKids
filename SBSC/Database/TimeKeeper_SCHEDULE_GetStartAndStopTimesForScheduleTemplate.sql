USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimesForScheduleTemplate]    Script Date: 1/25/2020 9:08:18 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimesForScheduleTemplate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimesForScheduleTemplate]    Script Date: 1/25/2020 9:08:18 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimesForScheduleTemplate]
(
	@TemplateScheduleDayid                BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[SCHEDULE_GetStartAndStopTimesForScheduleTemplate] @TemplateScheduleDayid

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimesForScheduleTemplate]    TO [webuser]
GO



USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate]
(
	@ScheduleDayId                BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate] @ScheduleDayId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate]    TO [webuser]
GO



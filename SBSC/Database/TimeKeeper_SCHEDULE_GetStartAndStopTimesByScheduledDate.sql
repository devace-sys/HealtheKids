USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimesByScheduledDate]    Script Date: 1/25/2020 9:07:03 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimesByScheduledDate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimesByScheduledDate]    Script Date: 1/25/2020 9:07:03 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimesByScheduledDate]
(
  @ScheduleId                BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[SCHEDULE_GetStartAndStopTimesByScheduledDate] @ScheduleId		     

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimesByScheduledDate] TO [webuser]
GO



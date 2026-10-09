USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimes]    Script Date: 1/25/2020 9:05:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimes]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimes]    Script Date: 1/25/2020 9:05:15 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimes]
(
  @Scheduleid                BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	
    exec [TimeKeeper].[dbo].[SCHEDULE_GetStartAndStopTimes] @ScheduleId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULE_GetStartAndStopTimes] TO [webuser]
GO


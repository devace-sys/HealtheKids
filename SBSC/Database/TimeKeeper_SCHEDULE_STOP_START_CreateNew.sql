USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_STOP_START_CreateNew]    Script Date: 1/25/2020 9:10:30 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULE_STOP_START_CreateNew]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_STOP_START_CreateNew]    Script Date: 1/25/2020 9:10:30 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULE_STOP_START_CreateNew]
(
  @ScheduleId           BIGINT,
  @StartTime            DATETIME,
  @StopTime             DATETIME,
  @Id					BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[SCHEDULE_STOP_START_CreateNew] @ScheduleId,
		@StartTime,
		@StopTime,
		@Id OUTPUT

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULE_STOP_START_CreateNew]    TO [webuser]
GO



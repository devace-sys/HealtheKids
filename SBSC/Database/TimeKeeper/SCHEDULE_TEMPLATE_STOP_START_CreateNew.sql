USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_TEMPLATE_STOP_START_CreateNew]    Script Date: 1/25/2020 8:01:10 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULE_TEMPLATE_STOP_START_CreateNew]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_TEMPLATE_STOP_START_CreateNew]    Script Date: 1/25/2020 8:01:10 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SCHEDULE_TEMPLATE_STOP_START_CreateNew]
(
  @ScheduleDayId           BIGINT,
  @StartTime            DATETIME,
  @StopTime             DATETIME,
  @Id					BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	INSERT INTO [TimeKeeper].[dbo].[AutoPopulateScheduleStartAndStopTime]
	(
		autoPopulateScheduleDaysId,
		starttime,
		stoptime
	)
	VALUES
	(
		@ScheduleDayId,
		@StartTime,
		@StopTime
	)
	
	SET @Id = SCOPE_IDENTITY()

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULE_TEMPLATE_STOP_START_CreateNew]  TO [webuser]
GO



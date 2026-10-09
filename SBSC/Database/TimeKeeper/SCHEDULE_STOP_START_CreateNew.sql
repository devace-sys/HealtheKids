USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_STOP_START_CreateNew]    Script Date: 1/25/2020 8:08:10 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULE_STOP_START_CreateNew]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_STOP_START_CreateNew]    Script Date: 1/25/2020 8:08:10 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SCHEDULE_STOP_START_CreateNew]
(
  @ScheduleId           BIGINT,
  @StartTime            DATETIME,
  @StopTime             DATETIME,
  @Id					BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	
	DECLARE @count int
	
	SELECT
		@count = count(*)
	from
		[TimeKeeper].[dbo].[ScheduleStartAndStopTime]
	where
		scheduleid = @ScheduleId
		AND starttime = @StartTime
		AND stoptime = @StopTime
		  
	if (@count = 0)
	begin
		INSERT INTO [TimeKeeper].[dbo].[ScheduleStartAndStopTime]
		(
			scheduleid,
			starttime,
			stoptime
		)
		VALUES
		(
			@ScheduleId,
			@StartTime,
			@StopTime
		)
	
		SET @Id = SCOPE_IDENTITY()
	end
	else
	begin
		if (@count = 1)
		begin
			SELECT
				@Id = id
			from
				[TimeKeeper].[dbo].[ScheduleStartAndStopTime]
			where
				scheduleid = @ScheduleId
				AND starttime = @StartTime
				AND stoptime = @StopTime
		end
		else
		begin
			SET @Id = -1
		end
	end

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULE_STOP_START_CreateNew] TO [webuser]
GO



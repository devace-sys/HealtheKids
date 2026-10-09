USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime]
		@autoPopulateScheduleDaysId bigint,
		@starttime time,
		@stoptime time,	
		@Id BIGINT OUTPUT
AS    
BEGIN    
SET NOCOUNT ON;
	DECLARE @count BIGINT

	SELECT @COUNT=COUNT(*)
	FROM AutoPopulateScheduleStartAndStopTime
	WHERE 
		autoPopulateScheduleDaysId = @autoPopulateScheduleDaysId
		AND starttime = @starttime
		AND stoptime = @stoptime

	IF (@COUNT = 0)
	BEGIN
		INSERT INTO AutoPopulateScheduleStartAndStopTime
		(
			autoPopulateScheduleDaysId,
			starttime,
			stoptime
		)
		VALUES
		(
			@autoPopulateScheduleDaysId,
			@starttime,
			@stoptime
		)

		SET @Id = SCOPE_IDENTITY()
	END
	BEGIN
		SELECT TOP 1 @Id=Id
		FROM AutoPopulateScheduleStartAndStopTime
		WHERE 
			autoPopulateScheduleDaysId = @autoPopulateScheduleDaysId
			AND starttime = @starttime
			AND stoptime = @stoptime

		UPDATE AutoPopulateScheduleStartAndStopTime
		SET
			autoPopulateScheduleDaysId=@autoPopulateScheduleDaysId,
			starttime=@starttime,
			stoptime=@stoptime
		WHERE
			Id = @Id

	END



END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime]  TO [webuser]
GO



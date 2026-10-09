USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertTimeEntries]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_InsertTimeEntries]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertTimeEntries]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_InsertTimeEntries]
	@timeEntryDayID BIGINT
	,@timeOfTask DATETIME
	,@numberMinutes INT
	,@timeEntrytaskID BIGINT
	,@orgClientID BIGINT
	,@note VARCHAR(2000)
	,@dateEntryUpdated DATETIME
	,@HasMultipleClients BIT
	,@holidayTaskID BIGINT
	,@Id BIGINT OUTPUT
AS    
BEGIN    
SET NOCOUNT ON;
	    DECLARE @NumberRecs AS SMALLINT
	    SELECT 
			@NumberRecs=COUNT(*)
		FROM
			TimeEntries
		WHERE
			timeEntryDayID = @timeEntryDayID
			AND holidayTaskID = @holidayTaskID

	    if (@NumberRecs = 0)
		BEGIN
			INSERT INTO TimeEntries
			(
				timeEntryDayID
				,timeOfTask
				,numberMinutes
				,timeEntrytaskID
				,orgClientID
				,note
				,dateEntryUpdated
				,HasMultipleClients
				,holidayTaskID
			)
			VALUES
			(
				@timeEntryDayID
				,@timeOfTask
				,@numberMinutes
				,@timeEntrytaskID
				,@orgClientID
				,@note
				,@dateEntryUpdated
				,@HasMultipleClients
				,@holidayTaskID
			)

			SET @Id = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			SELECT TOP 1
				@Id=ID
			FROM
				TimeEntries
			WHERE
				timeEntryDayID = @timeEntryDayID
				AND holidayTaskID = @holidayTaskID
		END


END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_InsertTimeEntries]  TO [webuser]
GO



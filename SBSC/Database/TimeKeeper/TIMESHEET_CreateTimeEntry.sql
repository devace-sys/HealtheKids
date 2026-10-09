USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_CreateTimeEntry]    Script Date: 1/25/2020 8:04:13 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_CreateTimeEntry]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_CreateTimeEntry]    Script Date: 1/25/2020 8:04:13 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE PROCEDURE [dbo].[TIMESHEET_CreateTimeEntry]
(
     @timeEntryDayID    bigint
    ,@timeOfTask        datetime
    ,@numberMinutes     int
    ,@timeEntrytaskID   bigint
    ,@orgClientID       bigint
    ,@note              varchar(max)
    ,@dateEntryCreated  datetime
    ,@IsProjectManagement bit
    ,@IsHelpDesk        bit
    ,@ITPM_ID           varchar(50)
    ,@HD_ROW_ID         varchar(50)
    ,@Description       varchar(max)
    ,@FileNameReference varchar(max)
	,@FileComments varchar(max)
	,@FileComplete bit
	,@HasMultipleClients bit
	,@StartEntryDateTime datetime
	,@EndEntryDateTime datetime
        ,@e_id bigint
    ,@Id                         BIGINT OUTPUT
)
AS

BEGIN

SET NOCOUNT ON;

        declare @ted_eid bigint;

        select @ted_eid = employeeID
        FROM [TimeKeeper].[dbo].[TimeEntry_Day]
        WHERE id = @timeEntryDayID

        IF (@ted_eid IS NOT NULL AND @e_id IS NOT NULL AND @ted_eid != @e_id)
          RAISERROR ('You may not be allowed to submit a time entry for this employee.', 11, 1)

	DECLARE @NumberRecs AS SMALLINT
	SELECT
		@NumberRecs=COUNT(*)
	FROM
		TimeEntries
	WHERE
		timeEntryDayID = @timeEntryDayID
		AND StartEntryDateTime = @StartEntryDateTime
		AND EndEntryDateTime = @EndEntryDateTime

	if (@NumberRecs = 0)
	BEGIN
		INSERT INTO [TimeKeeper].[dbo].[TimeEntries]
		(
		    [timeEntryDayID]
		    ,[timeOfTask]
		    ,[numberMinutes]
		    ,[timeEntrytaskID]
		    ,[orgClientID]
		    ,[note]
		    ,[dateEntryCreated]
		    ,[IsProjectManagement]
		    ,[IsHelpDesk]
		    ,[ITPM_ID]
		    ,[HD_ROW_ID]
		    ,[Description]
		    ,[FileNameReference]
			,[FileComments]
			,[FileComplete]
			,[HasMultipleClients]
			,StartEntryDateTime
			,EndEntryDateTime
		)
		VALUES
		(
		     @timeEntryDayID
		    ,@timeOfTask
		    ,@numberMinutes
		    ,@timeEntrytaskID
		    ,@orgClientID
		    ,@note
		    ,@dateEntryCreated
		    ,@IsProjectManagement
		    ,@IsHelpDesk
		    ,@ITPM_ID
		    ,@HD_ROW_ID
		    ,@Description
		    ,@FileNameReference
			,@FileComments
			,@FileComplete
			,@HasMultipleClients
			,@StartEntryDateTime
			,@EndEntryDateTime
		)

		SET @Id = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		SELECT
			@Id=Id
		FROM
			TimeEntries
		WHERE
			timeEntryDayID = @timeEntryDayID
			AND StartEntryDateTime = @StartEntryDateTime
			AND EndEntryDateTime = @EndEntryDateTime
	END
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_CreateTimeEntry] TO [webuser]
GO

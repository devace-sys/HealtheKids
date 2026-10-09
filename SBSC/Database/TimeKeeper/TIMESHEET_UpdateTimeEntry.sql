USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateTimeEntry]    Script Date: 1/25/2020 8:05:08 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_UpdateTimeEntry]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateTimeEntry]    Script Date: 1/25/2020 8:05:08 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_UpdateTimeEntry]
(
	 @Id bigint
	,@timeEntryDayID bigint
	,@timeOfTask datetime
	,@numberMinutes int
	,@timeEntrytaskID bigint
	,@orgClientID bigint
	,@note varchar(max)
	,@dateEntryUpdated datetime
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

	UPDATE [TimeKeeper].[dbo].[TimeEntries]
	   SET [timeEntryDayID] =		@timeEntryDayID
		  ,[timeOfTask] =			@timeOfTask
		  ,[numberMinutes] =		@numberMinutes
		  ,[timeEntrytaskID] =		@timeEntrytaskID
		  ,[orgClientID] =			@orgClientID
		  ,[note] =					@note
		  ,[dateEntryUpdated] =		@dateEntryUpdated
		  ,[IsProjectManagement] = @IsProjectManagement
		  ,[IsHelpDesk] = @IsHelpDesk
		  ,[ITPM_ID] = @ITPM_ID
		  ,[HD_ROW_ID] = @HD_ROW_ID
		  ,[Description] = @Description
		  ,[FileNameReference] = @FileNameReference
		  ,[FileComments] = @FileComments
		  ,[FileComplete] = @FileComplete
		  ,[HasMultipleClients] = @HasMultipleClients
	      ,[StartEntryDateTime] = @StartEntryDateTime
	      ,[EndEntryDateTime] = @EndEntryDateTime

	 WHERE
		Id = @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_UpdateTimeEntry] TO [webuser]
GO

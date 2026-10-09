USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateScheduleTemplate]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_UpdateScheduleTemplate]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateScheduleTemplate]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_UpdateScheduleTemplate]
    @Id BIGINT
	,@autoPopulateTaskTemplateId BIGINT
	,@employeeId BIGINT
AS    
BEGIN    
	
	DECLARE @Count BIGINT
	SELECT
		@Count=Count(*)
	FROM
		AutoPopulateScheduleTemplate
	WHERE
		Id = @Id

    IF (@Count > 0)
	BEGIN
		UPDATE AutoPopulateScheduleTemplate
		SET
			autoPopulateTaskTemplateId = @autoPopulateTaskTemplateId
		WHERE
			Id = @Id
	END
	ELSE
	BEGIN
		INSERT AutoPopulateScheduleTemplate
		(
			name
			,description
			,autoPopulateTaskTemplateId
		)
		VALUES
		(
			'Auto Created Schedule'
			,'Auto Created Schedule'
			,@autoPopulateTaskTemplateId
		)

		DECLARE @autoPopulateScheduleTemplateId BIGINT = SCOPE_IDENTITY()

		UPDATE Employees
			SET autoPopulateSdheduleTemplateId = @autoPopulateScheduleTemplateId
		WHERE
			ID = @employeeId

	END

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_UpdateScheduleTemplate]  TO [webuser]
GO



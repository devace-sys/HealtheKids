USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertAutoPopulateTaskDays]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_InsertAutoPopulateTaskDays]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertAutoPopulateTaskDays]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_InsertAutoPopulateTaskDays]
	 @dayid SMALLINT
	,@autoPopulateTaskDetailsId BIGINT
	,@numberOfMinutes BIGINT
	,@Id BIGINT OUTPUT
AS    
BEGIN    
	DECLARE @Count SMALLINT

	SELECT 
		@Count=Count(*)
	FROM
		AutoPopulateTaskDays
	WHERE
		dayid = @dayid
		AND autoPopulateTaskDetailsId = @autoPopulateTaskDetailsId

	IF (@Count = 0)
	BEGIN
		INSERT INTO AutoPopulateTaskDays
		(
			dayid
			,autoPopulateTaskDetailsId
			,numberOfMinutes
		)
		VALUES
		(
			 @dayid
			,@autoPopulateTaskDetailsId
			,@numberOfMinutes
		)
	
		SET @Id = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
	
		SELECT 
			@id=id
		FROM
			AutoPopulateTaskDays
		WHERE
			dayid = @dayid
			AND autoPopulateTaskDetailsId = @autoPopulateTaskDetailsId
	
		UPDATE AutoPopulateTaskDays
		SET
			dayid = @dayid
			,autoPopulateTaskDetailsId = @autoPopulateTaskDetailsId
			,numberOfMinutes = @numberOfMinutes
		WHERE
			id = @id
	
	END

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_InsertAutoPopulateTaskDays]  TO [webuser]
GO



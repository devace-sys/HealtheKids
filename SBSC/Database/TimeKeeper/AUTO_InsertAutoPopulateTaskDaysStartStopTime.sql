USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[AUTO_InsertAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 7:36:11 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[AUTO_InsertAutoPopulateTaskDaysStartStopTime]
GO

/****** Object:  StoredProcedure [dbo].[AUTO_InsertAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 7:36:11 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[AUTO_InsertAutoPopulateTaskDaysStartStopTime]
(
   @recordId BIGINT
  ,@autoPopulateTaskDaysId BIGINT
  ,@starttime TIME
  ,@stoptime TIME
  ,@Id BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	DECLARE @Count BIGINT

	if (@recordId = 0)
	BEGIN
		SELECT 
			@Count=count(*)
		FROM 
			[TimeKeeper].[dbo].[AutoPopulateTaskDaysStartStopTime]
		WHERE
			autoPopulateTaskDaysId = @autoPopulateTaskDaysId
			AND starttime = @starttime
			AND stoptime = @stoptime
	END
	ELSE
	BEGIN
		SELECT 
			@Count=count(*)
		FROM 
			[TimeKeeper].[dbo].[AutoPopulateTaskDaysStartStopTime]
		WHERE
			Id = @recordId
	END

	if (@Count = 0)
	BEGIN
		INSERT [TimeKeeper].[dbo].[AutoPopulateTaskDaysStartStopTime]
		(
			autoPopulateTaskDaysId
			,starttime
			,stoptime
		)
		VALUES
		(
			@autoPopulateTaskDaysId
			,@starttime
			,@stoptime
		)

		SET @Id = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		if (@recordId = 0)
		BEGIN
			SELECT 
				@Id=id
			FROM 
				[TimeKeeper].[dbo].[AutoPopulateTaskDaysStartStopTime]
			WHERE
				autoPopulateTaskDaysId = @autoPopulateTaskDaysId
				AND starttime = @starttime
				AND stoptime = @stoptime
		END
		ELSE
		BEGIN
			SET @Id = @recordId
		END

		UPDATE [TimeKeeper].[dbo].[AutoPopulateTaskDaysStartStopTime]
			SET 
				autoPopulateTaskDaysId = @autoPopulateTaskDaysId
				,starttime = @starttime
				,stoptime = @stoptime
			WHERE
				id = @Id

	END

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[AUTO_InsertAutoPopulateTaskDaysStartStopTime] TO [webuser]
GO



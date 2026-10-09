USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertEmployeeTimeVerfication]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_InsertEmployeeTimeVerfication]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertEmployeeTimeVerfication]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_InsertEmployeeTimeVerfication]
	 @employeeID BIGINT
	,@lastDayOfSchedule DATETIME
	,@dateOfNotification DATETIME
	,@startDateOfTheWeek DATETIME
	,@stopDateOfTheWeek DATETIME
	,@comments VARCHAR(MAX)
	,@Id BIGINT OUTPUT	
AS    
BEGIN    
SET NOCOUNT ON;
	    DECLARE @NumberRecs AS SMALLINT
		SELECT 
			@NumberRecs=COUNT(*)
		FROM
			EmployeeTimeVerification
		WHERE
			employeeID = @employeeID
			AND lastDayOfSchedule >= @startDateOfTheWeek AND lastDayOfSchedule < @stopDateOfTheWeek

	    if (@NumberRecs = 0)
		BEGIN
			INSERT INTO EmployeeTimeVerification
			(
				employeeID
				,isVerified
				,lastDayOfSchedule
				,dateOfNotification
				,comments
			)
			VALUES
			(
				@employeeID
				,0
				,@lastDayOfSchedule
				,@dateOfNotification
				,@comments
			)

			SET @Id = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			SELECT TOP 1
				@Id=ID
			FROM
				EmployeeTimeVerification
			WHERE
				employeeID = @employeeID
				AND lastDayOfSchedule >= @startDateOfTheWeek AND lastDayOfSchedule < @stopDateOfTheWeek

			UPDATE EmployeeTimeVerification
			SET lastDayOfSchedule = @lastDayOfSchedule
				,dateOfNotification = @dateOfNotification
			WHERE
				ID = @ID
		END


END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_InsertEmployeeTimeVerfication]  TO [webuser]
GO



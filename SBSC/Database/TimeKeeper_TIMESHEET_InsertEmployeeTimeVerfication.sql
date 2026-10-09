USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertEmployeeTimeVerfication]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_InsertEmployeeTimeVerfication]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertEmployeeTimeVerfication]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_InsertEmployeeTimeVerfication]
(
	 @employeeID BIGINT
	,@lastDayOfSchedule DATETIME
	,@dateOfNotification DATETIME
	,@startDateOfTheWeek DATETIME
	,@stopDateOfTheWeek DATETIME
	,@comments VARCHAR(MAX)
	,@Id BIGINT OUTPUT	
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_InsertEmployeeTimeVerfication] 
			@employeeID
			,@lastDayOfSchedule
			,@dateOfNotification 
			,@startDateOfTheWeek
			,@stopDateOfTheWeek
			,@comments 
			,@Id OUTPUT	

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_InsertEmployeeTimeVerfication]  TO [webuser]
GO



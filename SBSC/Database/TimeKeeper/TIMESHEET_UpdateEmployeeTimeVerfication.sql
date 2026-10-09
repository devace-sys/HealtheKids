USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateEmployeeTimeVerfication]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_UpdateEmployeeTimeVerfication]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateEmployeeTimeVerfication]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_UpdateEmployeeTimeVerfication]
	@Id BIGINT	
	,@isVerified BIT
	,@employeeID BIGINT
	,@lastDayOfSchedule DATE
	,@dateVerified DATE
	,@comments VARCHAR(MAX)
	,@WhoVerifiedHours BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
		UPDATE EmployeeTimeVerification
		SET
			employeeID = @employeeID
			,isVerified = @isVerified
			,lastDayOfSchedule = @lastDayOfSchedule
			,dateVerified = @dateVerified
			,comments = @comments
			,WhoVerifiedHours = @WhoVerifiedHours
		WHERE
			id = @Id

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_UpdateEmployeeTimeVerfication]  TO [webuser]
GO



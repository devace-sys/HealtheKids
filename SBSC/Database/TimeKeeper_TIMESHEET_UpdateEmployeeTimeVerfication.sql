USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateEmployeeTimeVerfication]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_UpdateEmployeeTimeVerfication]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateEmployeeTimeVerfication]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_UpdateEmployeeTimeVerfication]
(
	@Id BIGINT	
	,@isVerified BIT
	,@employeeID BIGINT
	,@lastDayOfSchedule DATE
	,@dateVerified DATE
	,@comments VARCHAR(MAX)
	,@WhoVerifiedHours BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_UpdateEmployeeTimeVerfication] 
		@Id
		,@isVerified
		,@employeeID
		,@lastDayOfSchedule
		,@dateVerified
		,@comments
		,@WhoVerifiedHours

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_UpdateEmployeeTimeVerfication]  TO [webuser]
GO



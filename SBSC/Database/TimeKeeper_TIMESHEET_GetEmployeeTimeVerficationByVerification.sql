USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetEmployeeTimeVerficationByVerification]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetEmployeeTimeVerficationByVerification]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetEmployeeTimeVerficationByVerification]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetEmployeeTimeVerficationByVerification]
(
	 @employeeID BIGINT
	,@isVerified bit
)

AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetEmployeeTimeVerficationByVerification] @employeeID, @isVerified


END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetEmployeeTimeVerficationByVerification]  TO [webuser]
GO



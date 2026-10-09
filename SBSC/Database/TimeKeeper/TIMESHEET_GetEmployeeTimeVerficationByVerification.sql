USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeeTimeVerficationByVerification]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetEmployeeTimeVerficationByVerification]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeeTimeVerficationByVerification]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetEmployeeTimeVerficationByVerification]
(
	 @employeeID BIGINT
	,@isVerified bit
)
AS    
BEGIN    
SET NOCOUNT ON;

		SELECT 
			*
		FROM
			EmployeeTimeVerification
		WHERE
			employeeID = @employeeID
			AND isVerified = @isVerified
		ORDER BY
			dateOfNotification


END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetEmployeeTimeVerficationByVerification]  TO [webuser]
GO



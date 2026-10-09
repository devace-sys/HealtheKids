USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerificationByName]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerificationByName]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerificationByName]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerificationByName]
(
	@employeeId BIGINT
)
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHET_GetEmployeeVerificationByName] @employeeId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerificationByName]  TO [webuser]
GO



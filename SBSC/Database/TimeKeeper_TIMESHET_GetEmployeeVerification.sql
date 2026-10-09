USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerification]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerification]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerification]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerification]
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHET_GetEmployeeVerification]

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerification]  TO [webuser]
GO



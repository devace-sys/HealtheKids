USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetPresonInfo]    Script Date: 1/25/2020 9:38:35 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetPresonInfo]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetPresonInfo]    Script Date: 1/25/2020 9:38:35 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetPresonInfo]
  @EmployeeId                BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetPresonInfo] @EmployeeId
	
END


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetPresonInfo]  TO [webuser]
GO



USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntry]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntry]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntry]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntry]
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntry]

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntry]    TO [webuser]
GO



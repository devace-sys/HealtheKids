USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetAutoScheduleInfo]    Script Date: 11/9/2020 11:50:45 AM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetAutoScheduleInfo]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetAutoScheduleInfo]    Script Date: 11/9/2020 11:50:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetAutoScheduleInfo]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetAutoScheduleInfo]
(
	@Id BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetAutoScheduleInfo] @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetAutoScheduleInfo]    TO [webuser]
GO


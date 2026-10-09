USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateScheduleTemplate]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_UpdateScheduleTemplate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateScheduleTemplate]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_UpdateScheduleTemplate]
    @Id BIGINT
	,@autoPopulateTaskTemplateId BIGINT
	,@employeeId BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_UpdateScheduleTemplate] @Id, @autoPopulateTaskTemplateId, @employeeid


END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_UpdateScheduleTemplate]    TO [webuser]
GO



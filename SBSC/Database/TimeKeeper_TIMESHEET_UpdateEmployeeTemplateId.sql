USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateEmployeeTemplateId]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_UpdateEmployeeTemplateId]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateEmployeeTemplateId]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_UpdateEmployeeTemplateId]
(
	@Id BIGINT
	,@autoPopluateScheduleTemplateId BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_UpdateEmployeeTemplateId] @Id, @autoPopluateScheduleTemplateId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_UpdateEmployeeTemplateId]    TO [webuser]
GO



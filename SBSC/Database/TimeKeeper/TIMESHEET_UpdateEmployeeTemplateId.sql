USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateEmployeeTemplateId]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_UpdateEmployeeTemplateId]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateEmployeeTemplateId]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_UpdateEmployeeTemplateId]
	@EmployeeID BIGINT
	,@autoPopluateScheduleTemplateId BIGINT
AS    
BEGIN    
SET NOCOUNT ON;

update Employees
set autoPopulateSdheduleTemplateId = @autoPopluateScheduleTemplateId
where
	id = @EmployeeID

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_UpdateEmployeeTemplateId]  TO [webuser]
GO



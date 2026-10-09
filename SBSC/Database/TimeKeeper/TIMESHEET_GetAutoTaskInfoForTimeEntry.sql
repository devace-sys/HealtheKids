USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntry]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntry]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntry]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntry]
AS    
BEGIN    
SET NOCOUNT ON;
	
select 
	E.id as 'EmployeeId'
	,TET.name as 'TaskName'
	,DOTW.id as 'DayId'
	,DOTW.day
	,APTDetails.id as 'AutoPopulateDetailsId'
	,APTDetails.timeentrytaskid
	,APTDetails.clientid
	,APTDays.id as 'AautoPopulateDaysId'
	,APTDays.numberOfMinutes
from 
	Employees E
	INNER JOIN AutoPopulateScheduleTemplate APST
		ON APST.id = E.autoPopulateSdheduleTemplateId
	INNER JOIN AutoPopulateTaskTemplate APTT
		ON APTT.id = APST.autoPopulateTaskTemplateId
	INNER JOIN AutoPopulateTaskDetails APTDetails
		ON APTDetails.autoPopulateTaskTemplateId = APTT.id
	INNER JOIN AutoPopulateTaskDays APTDays
		ON APTDays.autoPopulateTaskDetailsId = APTDetails.id
	INNER JOIN DaysOfTheWeek DOTW
		ON DOTW.id = APTDays.dayid
	INNER JOIN TimeEntry_Tasks TET
		ON TET.id = APTDetails.timeentrytaskid
WHERE
	E.autoPopulateSdheduleTemplateId is not null
	AND APST.autoPopulateTaskTemplateId is not null
	AND DATENAME(WEEKDAY, GETDATE()) = DOTW.day
ORDER BY
	E.id
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntry]  TO [webuser]
GO



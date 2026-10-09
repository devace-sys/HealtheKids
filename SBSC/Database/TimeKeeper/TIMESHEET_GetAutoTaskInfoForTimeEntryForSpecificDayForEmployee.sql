USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDayForEmployee]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDayForEmployee]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDayForEmployee]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDayForEmployee]
	@DayId SMALLINT
	,@EmployeeId BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	
select 
	E.id as 'EmployeeId'
	,TET.name as 'TaskName'
	,TET.CanHaveMultipleClients
	,TET.SpecifyStartStopTime
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
where
	APTDays.dayid = @DayId
	AND E.id = @EmployeeId
ORDER BY
	E.id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDayForEmployee]  TO [webuser]
GO



USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetSchedule]    Script Date: 1/25/2020 7:33:27 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetSchedule]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetSchedule]    Script Date: 1/25/2020 7:33:27 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetSchedule]
(
    @employeeID        BIGINT
	,@startDate        DATETIME
	,@endDate          DATETIME
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	  select 
		S.employeeID
		,S.dateOfSchedule
		,SS.starttime
		,SS.stoptime
	  from 
		TimeKeeper.dbo.Schedule S
		inner join TimeKeeper.dbo.ScheduleStartAndStopTime SS
			ON S.id = SS.scheduleid
	  where 
		S.employeeID = @employeeID
		AND S.dateOfSchedule >= @startDate
		AND S.dateOfSchedule < @endDate
				     
END


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetSchedule]  TO [webuser]
GO



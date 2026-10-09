USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetSchedule]    Script Date: 1/25/2020 9:24:52 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetSchedule]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetSchedule]    Script Date: 1/25/2020 9:24:52 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetSchedule]
(
    @employeeID        BIGINT
	,@startDate        DATETIME
	,@endDate          DATETIME
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetSchedule] @employeeID, @startDate, @endDate
	
END



GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetSchedule]  TO [webuser]
GO



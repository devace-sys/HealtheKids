USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime]
(
	@autoPopulateScheduleDaysId bigint,
	@starttime time,
	@stoptime time,	
	@Id BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime] 	 
		@autoPopulateScheduleDaysId,
		@starttime,
		@stoptime,	
		@Id OUTPUT


END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime]    TO [webuser]
GO



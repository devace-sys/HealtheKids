USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetHolidayByDate]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetHolidayByDate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetHolidayByDate]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetHolidayByDate]
(
	@DateOfHoliday	DATETIME 
)
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetHolidayByDate] 
		@DateOfHoliday

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetHolidayByDate]  TO [webuser]
GO



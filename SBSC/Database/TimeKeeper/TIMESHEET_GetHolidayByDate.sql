USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetHolidayByDate]    Script Date: 1/25/2020 8:04:13 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetHolidayByDate]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetHolidayByDate]    Script Date: 1/25/2020 8:04:13 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE PROCEDURE [dbo].[TIMESHEET_GetHolidayByDate]
(
	@DateOfHoliday	DATETIME 
)
AS    
BEGIN    
SET NOCOUNT ON;

	SELECT
		*
	FROM
		[TimeKeeper].[dbo].[TimeKeeperHolidays]
	WHERE
		DateOfHolidayObserved = @DateOfHoliday

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetHolidayByDate] TO [webuser]
GO



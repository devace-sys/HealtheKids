USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetHolidays]    Script Date: 1/25/2020 8:04:13 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetHolidays]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetHolidays]    Script Date: 1/25/2020 8:04:13 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE PROCEDURE [dbo].[TIMESHEET_GetHolidays]
AS
BEGIN
SET NOCOUNT ON;

	SELECT
		*
	FROM
		[TimeKeeper].[dbo].[TimeKeeperHolidays]
	ORDER BY
		DateOfHolidayObserved

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetHolidays] TO [webuser]
GO

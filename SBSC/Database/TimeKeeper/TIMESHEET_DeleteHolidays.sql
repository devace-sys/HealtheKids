USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteHolidays]    Script Date: 1/25/2020 8:04:13 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_DeleteHolidays]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteHolidays]    Script Date: 1/25/2020 8:04:13 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE PROCEDURE [dbo].[TIMESHEET_DeleteHolidays]
(
	@ID BIGINT
)
AS    
BEGIN    
SET NOCOUNT ON;

	DELETE
	FROM
		[TimeKeeper].[dbo].[TimeKeeperHolidays]
	WHERE
		ID = @ID     

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_DeleteHolidays] TO [webuser]
GO



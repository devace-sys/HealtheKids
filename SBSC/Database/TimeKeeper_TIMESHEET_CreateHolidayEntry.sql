USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_CreateHolidayEntry]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_CreateHolidayEntry]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_CreateHolidayEntry]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_CreateHolidayEntry]
(
	@Name varchar(50),
	@Description varchar(max),
	@DateOfHoliday date,
	@Id BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_CreateHolidayEntry] 
		@Name
		,@Description
		,@DateOfHoliday
		,@Id OUTPUT

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_CreateHolidayEntry]  TO [webuser]
GO



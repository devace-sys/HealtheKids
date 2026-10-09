USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_CreateHolidayEntry]    Script Date: 1/25/2020 8:04:13 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_CreateHolidayEntry]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_CreateHolidayEntry]    Script Date: 1/25/2020 8:04:13 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE PROCEDURE [dbo].[TIMESHEET_CreateHolidayEntry]
(
	@Name varchar(50),
	@Description varchar(max),
	@DateOfHoliday date,
	@Id BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
      
    INSERT INTO [TimeKeeper].[dbo].[TimeKeeperHolidays]
    (
		[Name]
		,[Description]
		,DateOfHolidayObserved
    )
    VALUES
    (
		@Name
		,@Description
		,@DateOfHoliday
    )
    
    SET @Id = SCOPE_IDENTITY()
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_CreateHolidayEntry] TO [webuser]
GO



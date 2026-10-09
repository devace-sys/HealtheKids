USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertTimeEntryDay]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_InsertTimeEntryDay]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_InsertTimeEntryDay]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_InsertTimeEntryDay]
	@employeeId BIGINT
	,@dateForTimeEntry date
	,@Id BIGINT OUTPUT
AS    
BEGIN    
SET NOCOUNT ON;
	
	INSERT INTO TimeEntry_Day
	(
		employeeID
		,dateForTimeEntry
	)
	VALUES
	(
		@employeeId
		,@dateForTimeEntry
	)

	SET @Id = SCOPE_IDENTITY()


END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_InsertTimeEntryDay]  TO [webuser]
GO



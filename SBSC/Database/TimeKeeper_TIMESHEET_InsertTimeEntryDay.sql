USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertTimeEntryDay]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_InsertTimeEntryDay]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertTimeEntryDay]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_InsertTimeEntryDay]
	@employeeId BIGINT
	,@dateForTimeEntry date
	,@Id BIGINT OUTPUT

AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_InsertTimeEntryDay] @employeeId, @dateForTimeEntry, @Id OUTPUT

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_InsertTimeEntryDay]    TO [webuser]
GO



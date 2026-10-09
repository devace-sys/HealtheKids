USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_CreateTimeEntryDay]    Script Date: 1/25/2020 9:20:06 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_CreateTimeEntryDay]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_CreateTimeEntryDay]    Script Date: 1/25/2020 9:20:06 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_CreateTimeEntryDay]
(
  @EmployeeId                BIGINT,
  @dateForTimeEntry          DATE,
  @Id						 BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_CreateTimeEntryDay] @EmployeeId, @dateForTimeEntry, @Id OUTPUT

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_CreateTimeEntryDay]  TO [webuser]
GO



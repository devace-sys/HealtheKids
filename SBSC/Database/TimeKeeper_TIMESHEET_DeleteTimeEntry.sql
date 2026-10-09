USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_DeleteTimeEntry]    Script Date: 1/25/2020 9:34:20 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_DeleteTimeEntry]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_DeleteTimeEntry]    Script Date: 1/25/2020 9:34:20 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_DeleteTimeEntry]
(
	@Id						 BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_DeleteTimeEntry] @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_DeleteTimeEntry]  TO [webuser]
GO


USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteTimeEntry]    Script Date: 1/25/2020 8:03:30 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_DeleteTimeEntry]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_DeleteTimeEntry]    Script Date: 1/25/2020 8:03:30 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_DeleteTimeEntry]
(
	@Id						 BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	DELETE FROM [TimeKeeper].[dbo].[TimeEntries]
		WHERE id = @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_DeleteTimeEntry]  TO [webuser]
GO



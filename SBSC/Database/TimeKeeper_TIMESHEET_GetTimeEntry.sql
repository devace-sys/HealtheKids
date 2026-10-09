USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetTimeEntry]    Script Date: 1/25/2020 9:50:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetTimeEntry]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetTimeEntry]    Script Date: 1/25/2020 9:50:32 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetTimeEntry]
(
	 @Id bigint
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetTimeEntry] @Id
	
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetTimeEntry]  TO [webuser]
GO



USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateTimeEntryTaslEmplate]    Script Date: 1/25/2020 9:29:43 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_UpdateTimeEntryTaslEmplate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateTimeEntryTaslEmplate]    Script Date: 1/25/2020 9:29:43 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_UpdateTimeEntryTaslEmplate]
(
	 @Id bigint
	,@numberMinutes int
	,@orgClientID bigint)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_UpdateTimeEntryTaslEmplate] 
		@Id
		,@numberMinutes
		,@orgClientID 

END

GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TimeKeeper_TIMESHEET_UpdateTimeEntryTaslEmplate] TO [webuser]
GO


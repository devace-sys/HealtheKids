USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateTimeEntryTaslEmplate]    Script Date: 1/25/2020 8:05:08 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_UpdateTimeEntryTaslEmplate]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateTimeEntryTaslEmplate]    Script Date: 1/25/2020 8:05:08 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_UpdateTimeEntryTaslEmplate]
(
	 @Id bigint
	,@numberMinutes int
	,@orgClientID bigint
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	UPDATE [TimeKeeper].[dbo].[TimeEntries]
	   SET [numberMinutes] =		@numberMinutes
		  ,[orgClientID] =			@orgClientID
	 WHERE 
		Id = @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_UpdateTimeEntryTaslEmplate] TO [webuser]
GO




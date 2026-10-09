USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_AUTO_DeleteAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_AUTO_DeleteAutoPopulateTaskDaysStartStopTime]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_AUTO_DeleteAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_AUTO_DeleteAutoPopulateTaskDaysStartStopTime]
(
  @Id BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[AUTO_DeleteAutoPopulateTaskDaysStartStopTime] @Id


END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_AUTO_DeleteAutoPopulateTaskDaysStartStopTime]    TO [webuser]
GO



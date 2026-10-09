USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[AUTO_DeleteAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 7:36:11 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[AUTO_DeleteAutoPopulateTaskDaysStartStopTime]
GO

/****** Object:  StoredProcedure [dbo].[AUTO_DeleteAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 7:36:11 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[AUTO_DeleteAutoPopulateTaskDaysStartStopTime]
(
   @Id BIGINT
)    
AS    
BEGIN    
	SET NOCOUNT ON;
	DECLARE @Count BIGINT


	delete from [TimeKeeper].[dbo].[AutoPopulateTaskDaysStartStopTime]
	WHERE id = @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[AUTO_DeleteAutoPopulateTaskDaysStartStopTime] TO [webuser]
GO



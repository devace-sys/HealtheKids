USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULEStartAndStop_Delete]    Script Date: 1/25/2020 8:09:38 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULEStartAndStop_Delete]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULEStartAndStop_Delete]    Script Date: 1/25/2020 8:09:38 PM ******/

CREATE PROCEDURE [dbo].[SCHEDULEStartAndStop_Delete] 
(		@ID BIGINT
)
AS

	DELETE TimeKeeper.dbo.ScheduleStartAndStopTime
	WHERE
		ID = @ID
	

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULEStartAndStop_Delete]  TO [webuser]
GO



USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULEStartAndStop_Update]    Script Date: 1/25/2020 8:10:17 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULEStartAndStop_Update]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULEStartAndStop_Update]    Script Date: 1/25/2020 8:10:17 PM ******/

CREATE PROCEDURE [dbo].[SCHEDULEStartAndStop_Update] 
(		@ID BIGINT,
        @STARTTIME DATETIME,
		@STOPTIME DATETIME
)
AS

	UPDATE TimeKeeper.dbo.ScheduleStartAndStopTime
	SET
		starttime = @STARTTIME,
		stoptime = @STOPTIME
	WHERE
		ID = @ID
	

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULEStartAndStop_Update]    TO [webuser]
GO



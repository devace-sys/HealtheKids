USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULEStartAndStopTemplate_Update]    Script Date: 1/25/2020 7:59:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULEStartAndStopTemplate_Update]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULEStartAndStopTemplate_Update]    Script Date: 1/25/2020 7:59:40 PM ******/

CREATE PROCEDURE [dbo].[SCHEDULEStartAndStopTemplate_Update] 
(		@ID BIGINT,
        @STARTTIME DATETIME,
		@STOPTIME DATETIME
)
AS

	UPDATE TimeKeeper.dbo.AutoPopulateScheduleStartAndStopTime
	SET
		starttime = @STARTTIME,
		stoptime = @STOPTIME
	WHERE
		ID = @ID
	

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULEStartAndStopTemplate_Update]   TO [webuser]
GO



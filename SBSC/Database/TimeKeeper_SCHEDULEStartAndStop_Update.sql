USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULEStartAndStop_Update]    Script Date: 1/25/2020 9:46:05 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULEStartAndStop_Update]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULEStartAndStop_Update]    Script Date: 1/25/2020 9:46:05 PM ******/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULEStartAndStop_Update] 
(		@ID BIGINT,
        @STARTTIME DATETIME,
		@STOPTIME DATETIME
)
AS

	exec [TimeKeeper].[dbo].SCHEDULEStartAndStop_Update @ID, @STARTTIME, @STOPTIME
	

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULEStartAndStop_Update]   TO [webuser]
GO



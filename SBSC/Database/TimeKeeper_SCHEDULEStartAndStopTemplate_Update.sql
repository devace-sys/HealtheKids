USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULEStartAndStopTemplate_Update]    Script Date: 1/25/2020 9:16:23 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULEStartAndStopTemplate_Update]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULEStartAndStopTemplate_Update]    Script Date: 1/25/2020 9:16:23 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULEStartAndStopTemplate_Update]
(
		@ID BIGINT,
        @STARTTIME DATETIME,
		@STOPTIME DATETIME
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[SCHEDULEStartAndStopTemplate_Update] @ID, @STARTTIME, @STOPTIME
END																					 		

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULEStartAndStopTemplate_Update]  TO [webuser]
GO



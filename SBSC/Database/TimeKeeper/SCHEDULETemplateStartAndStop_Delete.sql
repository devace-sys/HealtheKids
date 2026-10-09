USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULETemplateStartAndStop_Delete]    Script Date: 1/25/2020 7:58:57 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULETemplateStartAndStop_Delete]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULETemplateStartAndStop_Delete]    Script Date: 1/25/2020 7:58:57 PM ******/

CREATE PROCEDURE [dbo].[SCHEDULETemplateStartAndStop_Delete] 
(		@ID BIGINT
)
AS

	DELETE TimeKeeper.dbo.AutoPopulateScheduleStartAndStopTime
	WHERE
		ID = @ID
	

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULETemplateStartAndStop_Delete]  TO [webuser]
GO



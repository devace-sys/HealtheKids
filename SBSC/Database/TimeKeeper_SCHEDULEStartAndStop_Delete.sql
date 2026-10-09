USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULEStartAndStop_Delete]    Script Date: 1/25/2020 9:13:54 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULEStartAndStop_Delete]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULEStartAndStop_Delete]    Script Date: 1/25/2020 9:13:54 PM ******/



CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULEStartAndStop_Delete] 
(		@ID BIGINT
)
AS

	exec [TimeKeeper].[dbo].[SCHEDULEStartAndStop_Delete] @ID
	

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULEStartAndStop_Delete]    TO [webuser]
GO



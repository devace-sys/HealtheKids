USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULETemplateStartAndStop_Delete]    Script Date: 1/25/2020 9:17:29 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULETemplateStartAndStop_Delete]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULETemplateStartAndStop_Delete]    Script Date: 1/25/2020 9:17:29 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULETemplateStartAndStop_Delete]
(
	@ID BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec TimeKeeper.dbo.SCHEDULETemplateStartAndStop_Delete @ID

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULETemplateStartAndStop_Delete]  TO [webuser]
GO



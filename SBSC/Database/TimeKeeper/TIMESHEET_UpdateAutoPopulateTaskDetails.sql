USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateAutoPopulateTaskDetails]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_UpdateAutoPopulateTaskDetails]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateAutoPopulateTaskDetails]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_UpdateAutoPopulateTaskDetails]
	@Id BIGINT
	,@clientid BIGINT
AS    
BEGIN    
SET NOCOUNT ON;


END
	UPDATE AutoPopulateTaskDetails
	SET clientid = @clientid
	WHERE Id = @Id
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_UpdateAutoPopulateTaskDetails]  TO [webuser]
GO



USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SelectSpedmonUsers]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SelectSpedmonUsers]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SelectSpedmonUsers]    Script Date: 1/25/2020 7:34:40 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SelectSpedmonUsers]
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_SelectSpedmonUsers]
					     
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SelectSpedmonUsers]  TO [webuser]
GO



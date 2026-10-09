USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHET_GetEmployeeTaskFavorites]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHET_GetEmployeeTaskFavorites]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHET_GetEmployeeTaskFavorites]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHET_GetEmployeeTaskFavorites]
(
	@Id                BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHET_GetEmployeeTaskFavorites] @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHET_GetEmployeeTaskFavorites]    TO [webuser]
GO



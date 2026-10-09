USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_GetEmployeeTaskFavorites]    Script Date: 1/25/2020 8:58:03 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_GetEmployeeTaskFavorites]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_GetEmployeeTaskFavorites]    Script Date: 1/25/2020 8:58:03 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_GetEmployeeTaskFavorites]
(
  @EmployeeID						 BIGINT 
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHET_GetEmployeeTaskFavorites] @EmployeeID

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_GetEmployeeTaskFavorites] TO [webuser]
GO



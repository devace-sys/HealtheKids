USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetClientFavorites]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetClientFavorites]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetClientFavorites]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetClientFavorites]
	@EmployeeID BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	
	select
		O.id
		,O.name
	from
		TimeKeeper.dbo.Organizations O
		inner join TimeKeeper.dbo.Employee_Organization_Favorites EOF
			on O.id = EOF.clientOrganizationID
	where
		O.name != 'All Clients'
		and O.active = 1
		AND EOF.EmployeeID = @EmployeeID
	order by
		O.name

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetClientFavorites]  TO [webuser]
GO



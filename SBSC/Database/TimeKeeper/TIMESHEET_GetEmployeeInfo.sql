USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeeInfo]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetEmployeeInfo]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeeInfo]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetEmployeeInfo]
AS    
BEGIN    
SET NOCOUNT ON;
	  
	SELECT
		E.id as id,
		ISNULL(P.spedMonUserName, 'Spedmon Login Missing') + ' (' + P.firstName + ' ' + P.lastName + ' - ' + O.name + ')' AS name
	FROM
		TimeKeeper.dbo.Employees E
		inner join TimeKeeper.dbo.People P
			ON P.id = E.personID
		inner join TimeKeeper.dbo.Organizations O
			ON O.id = E.organizationID
	WHERE
		E.endDate is NULL
				     
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetEmployeeInfo]  TO [webuser]
GO



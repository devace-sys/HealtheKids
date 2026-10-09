USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeeList]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetEmployeeList]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeeList]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetEmployeeList]
AS    
BEGIN    
SET NOCOUNT ON;
	  
            select
	            E.id AS EmployeeId
	            ,P.lastName + ', ' + P.firstName + ' (' + O.name + ')' AS [Name]
	            ,E.autoPopulateSchedule
	            ,E.autoPopulateSdheduleTemplateId
            from
	            TimeKeeper.dbo.People P
	            inner join TimeKeeper.dbo.Employees E
		            ON E.personID = P.id
	            inner join TimeKeeper.dbo.Organizations O
		            ON O.id = E.organizationID
                        and O.active = 1
            order by
	            P.lastName
	            ,P.firstName

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetEmployeeList]  TO [webuser]
GO



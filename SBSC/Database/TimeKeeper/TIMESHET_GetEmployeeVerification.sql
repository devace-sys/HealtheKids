USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHET_GetEmployeeVerification]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHET_GetEmployeeVerification]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHET_GetEmployeeVerification]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHET_GetEmployeeVerification]
AS    
BEGIN    
SET NOCOUNT ON;
	  
	select
		ETV.id
		,E.id AS 'employeeId'
		,P.lastName
		,P.firstName
		,ETV.lastDayOfSchedule
		,ETV.dateVerified
		,ETV.comments
	from
		People P
		inner join Employees E
			ON E.personID = P.id
		inner join EmployeeTimeVerification ETV
			ON ETV.employeeID = E.id
	order by
		ETV.lastDayOfSchedule DESC, P.lastName
		
	END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHET_GetEmployeeVerification]  TO [webuser]
GO



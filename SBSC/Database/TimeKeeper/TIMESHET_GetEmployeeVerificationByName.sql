USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHET_GetEmployeeVerificationByName]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHET_GetEmployeeVerificationByName]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHET_GetEmployeeVerificationByName]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHET_GetEmployeeVerificationByName]
(
	@employeeId BIGINT
)
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
    where
		ETV.employeeID = @employeeId
	order by
		ETV.lastDayOfSchedule DESC, P.lastName
		
	END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHET_GetEmployeeVerificationByName]  TO [webuser]
GO



USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHET_GetEmployeeVerificationByNameDateRange]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHET_GetEmployeeVerificationByNameDateRange]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHET_GetEmployeeVerificationByNameDateRange]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHET_GetEmployeeVerificationByNameDateRange]
(
    @employeeId BIGINT
	,@startDate Date
	,@endDate Date
)
AS    
BEGIN    
SET NOCOUNT ON;

    if (@startDate IS NOT NULL AND @endDate IS NOT NULL) 
	BEGIN	
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
			AND ETV.dateOfNotification >= @startDate
			AND ETV.dateOfNotification < @endDate
		order by
			ETV.lastDayOfSchedule DESC, P.lastName
	END
	ELSE IF (@endDate IS NULL)
	BEGIN
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
			AND ETV.dateOfNotification >= @startDate
		order by
			ETV.lastDayOfSchedule DESC, P.lastName
	END
	ELSE
	BEGIN
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
			AND ETV.lastDayOfSchedule < @startDate
		order by
			ETV.lastDayOfSchedule DESC, P.lastName
	END

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHET_GetEmployeeVerificationByNameDateRange]  TO [webuser]
GO



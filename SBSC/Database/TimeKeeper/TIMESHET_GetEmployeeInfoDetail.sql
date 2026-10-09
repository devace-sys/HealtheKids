USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHET_GetEmployeeInfoDetail]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHET_GetEmployeeInfoDetail]
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHET_GetEmployeeInfoDetail]
	@Id BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	  
            select
	            P.firstName
	            ,P.lastName
	            ,ISNULL(P.spedMonUserName, '') AS spedMonUserName
	            ,P.roleID
	            ,E.startDate
	            ,ISNULL(E.endDate, '') AS endDate
	            ,E.employeeStatus
                    ,E.[noPayroll]
	            ,E.positionID as PositionID
	            ,E.organizationID as OrganizationID
                ,E.partTime
                ,E.isExempt
                ,E.isSalaried
                ,E.specifyStartTime
                ,E.specifyEndTime
				,E.autoPopulateSdheduleTemplateId
				,E.PaidForHolidays
				,E.EmailAddress
				,E.Address
				,E.City
				,E.State
				,E.ZipCode
				,E.PhoneNumber
            from
	            TimeKeeper.dbo.People P
	            inner join TimeKeeper.dbo.Employees E
		            ON E.personID = P.id
            where
                E.id = @Id
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHET_GetEmployeeInfoDetail]  TO [webuser]
GO



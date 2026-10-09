USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetPresonInfo]    Script Date: 1/25/2020 7:42:12 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetPresonInfo]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetPresonInfo]    Script Date: 1/25/2020 7:42:12 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetPresonInfo]
  @EmployeeId                BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	  
	select
		PE.firstName AS FirstName,
		PE.lastName AS LastName,
		O.name AS Oranization,
		O.id AS OrganizationID,
		P.title AS Position,
		E.startDate,
		E.endDate,
		CASE 
			WHEN E.PartTime =1 THEN 'Part Time'
			ELSE 'Full Time'
		END AS PayStatus,
		CASE
			WHEN P.isHourly = 1 THEN P.hourlyRate
			ELSE -1 -- set to a dummy value of -1 if 
		END AS HourlyPay,
		CASE
			WHEN P.getsHolidayPay = 1 THEN 'Eligible for holiday pay'
			ELSE 'Not Eligible for holiday pay'
		END AS EligibleHolidayPay
	from
       dbo.Organizations O  
       inner join dbo.Employees E
	      ON E.organizationID = O.id
       inner join dbo.Positions P   
          ON P.id = E.positionID 
       inner join dbo.People PE  
          ON PE.id = E.personID  
	WHERE
		E.id = @EmployeeId
				     
END


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetPresonInfo]  TO [webuser]
GO



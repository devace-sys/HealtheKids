USE [SPEDMON]
GO


/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateEmployee]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_UpdateEmployee]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateEmployee]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_UpdateEmployee]
(
	@Id BIGINT
	,@personID BIGINT
	,@positionID BIGINT
	,@organizationID BIGINT
	,@partTime BIT
	,@startDate DATE
	,@endDate DATE
	,@usePositionTasks BIT
	,@autoPopulateSchedule BIT
	,@applyFLSARules BIT
	,@isExempt BIT
	,@isSalaried BIT
	,@notifyScheduleChange BIT
	,@specifyStartTime BIT
	,@specifyEndTime BIT
	,@noPayroll BIT
	,@employeeStatus SMALLINT
	,@PaidForHolidays BIT
	,@EmailAddress VARCHAR(100)
	,@Address VARCHAR(50)
	,@City VARCHAR(50)
	,@State VARCHAR(50)
	,@ZipCode VARCHAR(15)
	,@PhoneNumber VARCHAR(15)
)
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_UpdateEmployee] 	@Id 
						,@personID 
						,@positionID 
						,@organizationID 
						,@partTime 
						,@startDate 
						,@endDate 
						,@usePositionTasks 
						,@autoPopulateSchedule 
						,@applyFLSARules 
						,@isExempt 
						,@isSalaried 
						,@notifyScheduleChange 
						,@specifyStartTime 
						,@specifyEndTime
                                                ,@noPayroll 
						,@employeeStatus
						,@PaidForHolidays 
						,@EmailAddress
						,@Address
						,@City
						,@State
						,@ZipCode
						,@PhoneNumber


END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_UpdateEmployee]    TO [webuser]
GO



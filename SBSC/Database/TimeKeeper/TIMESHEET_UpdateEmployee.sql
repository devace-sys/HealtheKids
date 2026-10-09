USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateEmployee]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_UpdateEmployee]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_UpdateEmployee]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_UpdateEmployee]
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

    UPDATE [TimeKeeper].[dbo].[Employees]
       SET [personID] = @personID
          ,[positionID] = @positionID
          ,[organizationID] = @organizationID
          ,[partTime] = @partTime
          ,[startDate] = @startDate
          ,[endDate] = @endDate
          ,[usePositionTasks] = @usePositionTasks
          ,[autoPopulateSchedule] = @autoPopulateSchedule
          ,[applyFLSARules] = @applyFLSARules
          ,[isExempt] = @isExempt
          ,[isSalaried] = @isSalaried
          ,[notifyScheduleChange] = @notifyScheduleChange
          ,[specifyStartTime] = @specifyStartTime
          ,[noPayroll] = @noPayroll
          ,[specifyEndTime] = @specifyEndTime
          ,[employeeStatus] = @employeeStatus
		  ,[PaidForHolidays] = @PaidForHolidays
		  ,[EmailAddress] = @EmailAddress
		  ,[Address] = @Address
		  ,[City] = @City
		  ,[State] = @State
		  ,[ZipCode] = @ZipCode
		  ,[PhoneNumber] = @PhoneNumber
     WHERE 
          [id] = @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_UpdateEmployee]  TO [webuser]
GO



USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_CreateEmployee]    Script Date: 1/25/2020 8:04:13 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_CreateEmployee]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE PROCEDURE [dbo].[TIMESHEET_CreateEmployee]
(
    @personID BIGINT
    ,@positionID BIGINT
    ,@organizationID BIGINT
    ,@partTime BIT
    ,@startDate DATE
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
    ,@Id                         BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
      
    INSERT INTO [TimeKeeper].[dbo].[Employees]
    (
        [personID]
        ,[positionID]
        ,[organizationID]
        ,[partTime]
        ,[startDate]
        ,[usePositionTasks]
        ,[autoPopulateSchedule]
        ,[applyFLSARules]
        ,[isExempt]
        ,[isSalaried]
        ,[notifyScheduleChange]
        ,[specifyStartTime]
        ,[specifyEndTime]
        ,[noPayroll]
        ,[employeeStatus]
		,[PaidForHolidays]
		,[EmailAddress]
		,[Address]
		,[City]
		,[State]
		,[ZipCode]
		,[PhoneNumber]
    )
    VALUES
    (
        @personID
        ,@positionID
        ,@organizationID
        ,@partTime
        ,@startDate
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
    )
    
    SET @Id = SCOPE_IDENTITY()
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_CreateEmployee] TO [webuser]
GO



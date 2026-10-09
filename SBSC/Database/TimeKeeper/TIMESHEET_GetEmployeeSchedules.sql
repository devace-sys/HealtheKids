USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeeSchedules]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetEmployeeSchedules]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetEmployeeSchedules]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetEmployeeSchedules]
AS    
BEGIN    
SET NOCOUNT ON;
	  
    select
        id
        ,autoPopulateSdheduleTemplateId
    from
        TimeKeeper.dbo.Employees
    where 
        autoPopulateSdheduleTemplateId is not null

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetEmployeeSchedules]  TO [webuser]
GO



USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_GetScheduledByDate]    Script Date: 1/25/2020 7:36:11 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULE_GetScheduledByDate]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_GetScheduledByDate]    Script Date: 1/25/2020 7:36:11 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SCHEDULE_GetScheduledByDate]
(
  @DateOfSchedule                DATETIME,
  @EmployeeId					 BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	SELECT 
		[id]
		,[employeeid]
		,[dateOfSchedule]
		,[createdstamp]
		,[updatestamp]
	FROM 
		[TimeKeeper].[dbo].[Schedule]
	WHERE
		employeeID = @EmployeeId
		AND DATEADD(dd, DATEDIFF(dd, 0, dateOfSchedule), 0) = DATEADD(dd, DATEDIFF(dd, 0, @DateOfSchedule), 0)

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULE_GetScheduledByDate] TO [webuser]
GO



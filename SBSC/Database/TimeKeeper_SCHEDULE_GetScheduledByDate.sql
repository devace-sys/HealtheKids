USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_GetScheduledByDate]    Script Date: 1/25/2020 9:03:17 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULE_GetScheduledByDate]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_GetScheduledByDate]    Script Date: 1/25/2020 9:03:17 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULE_GetScheduledByDate]
(
  @DateOfSchedule                DATETIME,
  @EmployeeId					 BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[SCHEDULE_GetScheduledByDate] @DateOfSchedule, @EmployeeId
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULE_GetScheduledByDate] TO [webuser]
GO




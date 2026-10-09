USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_CreateNew]    Script Date: 1/25/2020 8:58:03 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULE_CreateNew]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_CreateNew]    Script Date: 1/25/2020 8:58:03 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULE_CreateNew]
(
  @EmployeeId                BIGINT,
  @ScheduleApproveId         BIGINT,
  @DateOfSchedule            DATETIME,
  @Id						 BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[SCHEDULE_CreateNew] @EmployeeId, @ScheduleApproveId, @DateOfSchedule, @Id OUTPUT

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULE_CreateNew] TO [webuser]
GO



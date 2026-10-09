USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_CreateNewScheduleApproved]    Script Date: 1/25/2020 9:01:10 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULE_CreateNewScheduleApproved]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_CreateNewScheduleApproved]    Script Date: 1/25/2020 9:01:10 PM ******/
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULE_CreateNewScheduleApproved]
(
  @EmployeeId                BIGINT,
  @StartDate				 DATE,
  @EndDate					 DATE,
  @Id						 BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	
	exec [TimeKeeper].[dbo].[SCHEDULE_CreateNewScheduleApproved] @EmployeeId   
																 ,@StartDate	
																 ,@EndDate		
																 ,@Id OUTPUT		
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULE_CreateNewScheduleApproved] TO [webuser]
GO



USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDays]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDays]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDays]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDays]
(
	 @dayid SMALLINT
	,@autoPopulateTaskDetailsId BIGINT
	,@numberOfMinutes BIGINT
	,@Id BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_InsertAutoPopulateTaskDays] 	 @dayid	,@autoPopulateTaskDetailsId, @numberOfMinutes, @Id OUTPUT


END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDays]    TO [webuser]
GO



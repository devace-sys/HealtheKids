USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_TEMPLATE_STOP_START_CreateNew]    Script Date: 1/25/2020 9:12:01 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_SCHEDULE_TEMPLATE_STOP_START_CreateNew]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_SCHEDULE_TEMPLATE_STOP_START_CreateNew]    Script Date: 1/25/2020 9:12:01 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_SCHEDULE_TEMPLATE_STOP_START_CreateNew]
(
  @ScheduleDayId           BIGINT,
  @StartTime            DATETIME,
  @StopTime             DATETIME,
  @Id					BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[SCHEDULE_TEMPLATE_STOP_START_CreateNew] @ScheduleDayId, @StartTime, @StopTime,  @Id
END																					 		

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_SCHEDULE_TEMPLATE_STOP_START_CreateNew]    TO [webuser]
GO



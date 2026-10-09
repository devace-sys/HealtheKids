USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_AUTO_InsertAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_AUTO_InsertAutoPopulateTaskDaysStartStopTime]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_AUTO_InsertAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_AUTO_InsertAutoPopulateTaskDaysStartStopTime]
(
  @recordId BIGINT
  ,@autoPopulateTaskDaysId BIGINT
  ,@starttime TIME
  ,@stoptime TIME
  ,@Id BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[AUTO_InsertAutoPopulateTaskDaysStartStopTime]
	    @recordId 	 
		,@autoPopulateTaskDaysId
		,@starttime
		,@stoptime
		,@Id OUTPUT


END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_AUTO_InsertAutoPopulateTaskDaysStartStopTime]    TO [webuser]
GO



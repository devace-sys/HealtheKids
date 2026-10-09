USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_CalendarScheduleableTasks_Delete]    Script Date: 1/25/2020 8:09:38 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_CalendarScheduleableTasks_Delete]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_CalendarScheduleableTasks_Delete]    Script Date: 1/25/2020 8:09:38 PM ******/

CREATE PROCEDURE [dbo].[TIMESHEET_CalendarScheduleableTasks_Delete] 
(
  @userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT,            /* TODO: userGroup and userRank aren't being used in this SPROC.  I think we have to accept these params because the middleware
                                      usually or always passes them in?  */
  @tetid        bigint,
  @daynum       int,

  @editDelReason   VARCHAR(7000),  /* TODO: This is usually passed in by middleware into save SPROCs.  It's not actually being used right now in here */
  @msgNoRec   VARCHAR(100),
  @msgNoEdit       VARCHAR(1000), /* TODO: the middleware passes this arg into save sprocs but we haven't implemented editable/non-editable permissions on this record type, yet */
  @validateRec     bit, /* TODO: the middleware passes this arg into save sprocs but we're not implementing any save validation here */
  @spDetails       VARCHAR(8000) OUTPUT,
  @recordID        BIGINT OUTPUT
)
AS

	DELETE TimeKeeper.dbo.ScheduleStartAndStopTime
	WHERE
		ID = @ID
	

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_CalendarScheduleableTasks_Delete]  TO [webuser]
GO



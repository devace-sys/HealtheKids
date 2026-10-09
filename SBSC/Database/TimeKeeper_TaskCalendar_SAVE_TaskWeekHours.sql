USE [SPEDMON]
GO

DROP PROCEDURE if exists [dbo].[TimeKeeper_TaskCalendar_SAVE_TaskWeekHours]
GO

CREATE PROCEDURE [dbo].[TimeKeeper_TaskCalendar_SAVE_TaskWeekHours]    
 (
  @userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT,            /* TODO: userGroup and userRank aren't being used in this SPROC.  I think we have to accept these params because the middleware
                                      usually or always passes them in?  */
  @recIDMulti        varchar(8000),

  @e_id              bigint,

  @editDelReason   VARCHAR(7000),  /* TODO: This is usually passed in by middleware into save SPROCs.  It's not actually being used right now in here */
  @msgNoRec   VARCHAR(100),
  @msgNoEdit       VARCHAR(1000), /* TODO: the middleware passes this arg into save sprocs but we haven't implemented editable/non-editable permissions on this record type, yet */
  @validateRec     bit, /* TODO: the middleware passes this arg into save sprocs but we're not implementing any save validation here */
  @spDetails       VARCHAR(8000) OUTPUT,
  @recordID        BIGINT OUTPUT
)  
AS 
   
BEGIN

exec [TimeKeeper].[dbo].TaskCalendar_SAVE_TaskWeekHours    
  @userID,    
  @userGroup,    
  @userRank,            /* TODO: userGroup and userRank aren't being used in this SPROC.  I think we have to accept these params because the middleware
                                      usually or always passes them in?  */
  @recIDMulti,

  @e_id,

  @editDelReason,  /* TODO: This is usually passed in by middleware into save SPROCs.  It's not actually being used right now in here */
  @msgNoRec,
  @msgNoEdit, /* TODO: the middleware passes this arg into save sprocs but we haven't implemented editable/non-editable permissions on this record type, yet */
  @validateRec, /* TODO: the middleware passes this arg into save sprocs but we're not implementing any save validation here */
  @spDetails OUTPUT,
  @recordID OUTPUT


END
GO

grant execute on [TimeKeeper_TaskCalendar_SAVE_TaskWeekHours] to webuser
GO

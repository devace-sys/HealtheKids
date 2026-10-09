USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSIONS_VIEW_UPCOMING_FOR_USER') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TELECOMM_SESSIONS_VIEW_UPCOMING_FOR_USER
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TELECOMM_SESSIONS_VIEW_UPCOMING_FOR_USER] (
   @userID              BIGINT    
 , @appName             VARCHAR(50)
 , @purposeID           bigint
)    
RETURNS TABLE

AS RETURN
(

  select top (dbo.CONST_MAX_ROWS())
      sessionID        = ts.id
    , roomID           = ts.roomID
    , roomTitle        = ts.title
    , participantEmail = tsp.email
    , participantPIN   = tsp.pin
    , meetingStartDate = ts.startDate
    , meetinEndDate    = ts.endDate
    , inviteRsvpToken  = tsp.inviteRsvpToken
  from dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp
  join dbo.TELECOMM_SESSIONS              as ts on ts.id = tsp.telecommSessionID

  where (

        (tsp.userID   = @userID)
    and (ts.appName   = @appName)
    and (ts.purposeID = @purposeID)
    and (datediff(day,ts.startDate,getdate()) <= 0)
  )
  order by
    ts.startDate asc

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TELECOMM_SESSIONS_VIEW_UPCOMING_FOR_USER] TO [webuser]
GO 
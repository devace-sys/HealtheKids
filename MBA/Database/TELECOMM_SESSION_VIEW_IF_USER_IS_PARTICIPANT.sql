USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_VIEW_IF_USER_IS_PARTICIPANT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION TELECOMM_SESSION_VIEW_IF_USER_IS_PARTICIPANT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TELECOMM_SESSION_VIEW_IF_USER_IS_PARTICIPANT] (
     @roomID              bigint 
    ,@userID              BIGINT
 
 )    
 
RETURNS TABLE
 
 /***************************************************************************    
  * TELECOMM_SESSION_VIEW_IF_USER_IS_PARTICIPANT */    
 /**    
  * Returns a minimal set of fields 
  *    
  * @return                 Table 
  ***************************************************************************/     
 
AS RETURN
( 

  select top 1
      sessionID        = ts.id 
    , roomID           = ts.roomID
	, roomTitle        = ts.title
	, participantEmail = tsp.email
    , participantPIN   = tsp.pin

  from dbo.TELECOMM_SESSIONS              as ts
  join dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp on tsp.telecommSessionID = ts.id
  
  where ( 
	    (ts.id      = @roomID)
	and (tsp.userID = @userID)
  )



)

GO

GRANT SELECT ON  [dbo].[TELECOMM_SESSION_VIEW_IF_USER_IS_PARTICIPANT] TO [webuser]
GO

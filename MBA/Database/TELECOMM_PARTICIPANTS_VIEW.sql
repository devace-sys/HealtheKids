USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_PARTICIPANTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TELECOMM_PARTICIPANTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[TELECOMM_PARTICIPANTS_VIEW] ( 
   @userID              BIGINT
 , @userGroup           INT    
 , @userRank            INT
 , @appName             varchar(50)
 , @sessionID           bigint
 , @roleID              bigint
 , @recID               bigint
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * TELECOMM_PARTICIPANTS_VIEW */
/**
 * Displays data
 *
 * @return                 Table
 ***************************************************************************/ 

select 
     idx = ROW_NUMBER() OVER(ORDER BY tsp.name asc, tsp.id asc)
   , tsp.name
   , tsp.title
   , tsp.email
   , tsp.phone
   , tsp.pin
   , tsp.userID
   , tsp.roleID
   , tsp.entityID

   , tsp.inviteRsvpToken
   , tsp.inviteRsvpNotes

   , tsp.inviteRsvpWillAttend

from dbo.TELECOMM_SESSIONS              as ts
join dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp on tsp.telecommSessionID = ts.id 
  
where (      
       (ts.id = @sessionID) 
  and ((@roleID is null) or (tsp.roleID = @roleID))
  and ((@recID  is null) or (tsp.id     = @recID))
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[TELECOMM_PARTICIPANTS_VIEW] TO [webuser]
GO



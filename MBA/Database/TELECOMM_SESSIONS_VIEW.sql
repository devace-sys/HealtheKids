USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSIONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TELECOMM_SESSIONS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[TELECOMM_SESSIONS_VIEW] ( 
   @userID              BIGINT
 , @userGroup           INT    
 , @userRank            INT
 , @appName             varchar(50)
 , @clientID            bigint
 , @purposeID           bigint
 , @facilitatorEntityID bigint
 , @active              bit
 , @recID               bigint
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * TELECOMM_SESSIONS_VIEW */
/**
 * Displays data
 *
 * @return                 Table
 ***************************************************************************/ 

with
cte_p1
as
(
  select 
     ts.*
   , meetingDateStr           = dbo.RPT_DATE_FMT(ts.meetingDate)
   , meetingTimeStr           = dbo.RPT_TIME_FMT(ts.meetingTime, 0)
   , meetingDurationInMinsStr = convert(varchar(256),meetingDurationInMins) 
   , participantDetailsJSON   = pd.jsonStr
  from dbo.TELECOMM_SESSIONS as ts

  cross apply (
    select top 1 
      jsonStr = convert(nvarchar(max), 
	(
      select 
       tsp1.idx
     , tsp1.name
     , tsp1.title
     , tsp1.email
     , tsp1.phone
     , tsp1.userID
     , tsp1.roleID
     , tsp1.entityID 
     from dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp1 
     where 
           (tsp1.telecommSessionID = ts.id) 
       and (tsp1.idx != 0)
      for JSON PATH, ROOT('participantdetails'), INCLUDE_NULL_VALUES
      ) 
    )
  ) as pd
  where (
      (1=1)
    and (ts.appName   = @appName)
    and (ts.purposeID = @purposeID)
    and ((@clientID            is null) or (ts.clientID            = @clientID))
    and ((@facilitatorEntityID is null) or (ts.facilitatorEntityID = @facilitatorEntityID))
    and ((@recID               is null) or (ts.id                  = @recID))
    and ((@active              is null) or (ts.active              = @active))
  )
)
,
cte_p2
as
(
  select 
    p1.* 
  , canEdit = dbo.TELECOMM_SESSION_CAN_EDIT(p1.active,p1.startDate,p1.endDate)
  from cte_p1 as p1
)
select * from cte_p2
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[TELECOMM_SESSIONS_VIEW] TO [webuser]
GO



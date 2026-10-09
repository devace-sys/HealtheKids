USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

DROP PROCEDURE if exists dbo.TELECOMM_SESSION_GET_INFO_FOR_RSVP
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TELECOMM_SESSION_GET_INFO_FOR_RSVP] ( 

 --  @userID              BIGINT
 --, @userGroup           INT    
 --, @userRank            INT

 --  @appName               varchar(50)    -- passed in at middleware but not used here
   @userIP                varchar(500)   -- passed in at middleware but not used here
 , @userAgent             varchar(8000)  -- passed in at middleware but not used here

 , @email                 varchar(256)   -- passed in at middleware but not used here;
                                         -- we are fetching by rsvp invite token, not email

  , @roomID                varchar(256)
  , @inviteRsvpToken       nvarchar(128)
  , @roomTitle             varchar(512)   output

  , @participantsHtmlTbl       varchar(max)   output
  , @formInviteText           varchar(max)   output

  , @numMinutes               int         output
  , @startTime                datetime       output
  , @endTime                  datetime       output

  , @inviteRsvpWillAttend     bit            output
--, @altDateRequested         date           output
  , @inviteRsvpNotes          varchar(512)   output

  , @clientName            as varchar(1000) output
  , @participantName       as varchar(256)  output
  , @patId                 as bigint        output
  , @patName               as varchar(256)  output

  , @sessionOK                 bit         output
  , @sessionID                 bigint      output-- debugging is easier when sessionID and sessionOK are returned to middleware

 --, @active              bit
 --, @recID               bigint

)

AS
BEGIN

declare @today datetime = getdate()

declare @var_email        varchar(256)  -- @email is already declared as a non-output param; not sure if we can overwrite it here
      , @pin              varchar(50) 
 
 /*============================================================
  * Find participant record using rsvp token
  *============================================================*/ 
 
select top 1
    @var_email = tsp.email
  , @pin   = tsp.pin
 
from dbo.TELECOMM_SESSIONS              as ts
join dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp on tsp.telecommSessionID = ts.id
where (
      (ts.roomID = @roomID)
  and (inviteRsvpToken = @inviteRsvpToken)
)
 
/*============================================================
  * Call sesion validate skipping not started check 
  *============================================================*/

declare
    @participantClientID      bigint   -- not used, but the validate_core sproc requires this output param
  , @participantID            bigint   -- ditto, ditto
  , @isSessionFacilitator     bit
 
exec [dbo].[TELECOMM_SESSION_VALIDATE_CORE]
    @roomID                  
  , @var_email                   
  , @pin                     
  , @today                   
  , 1 -- @skipMeetingHasNotStartedCheck
  , @sessionOK                output
  , @sessionID                output
  , @participantClientID      output
  , @participantID            output
  , @isSessionFacilitator     output 
 
--declare @clientName            as varchar(1000) output
--declare @participantName       as varchar(256)  output

declare @meetingDate           as date
declare @meetingTime           as time(0)
declare @meetingDurationInMins as int
declare @participantsList      as varchar(max)
declare @purposeSpecificData as varchar(max)
declare @purposeID            as bigint
 
set @formInviteText = ''
 
 /*============================================================
  * Get basic participant info and their rsvp status
  *============================================================*/ 
 
 select top 1
 
    @inviteRsvpWillAttend      = tsp.inviteRsvpWillAttend
  --, @altDateRequested       = tsp.altDateRequested
  , @inviteRsvpNotes              = tsp.inviteRsvpNotes
  , @participantName        = tsp.name
 
from dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp
where
  (id = @participantID)
 
 /*============================================================
  * Get basic meeting info
  *============================================================*/ 
 
select top 1
    @roomTitle             = ts.title
  --, @formInviteText           = ''
  , @clientName            = isnull(clc.CLIENT_NAME,'')
  , @meetingDate           = ts.meetingDate
  , @meetingTime           = ts.meetingTime
  , @meetingDurationInMins = ts.meetingDurationInMins
  , @purposeSpecificData   = ts.purposeSpecificData
  , @purposeID             = ts.purposeID

  , @startTime             = ts.startDate
  , @endTime               = ts.endDate
  , @numMinutes            = ts.meetingDurationInMins
 
from       dbo.TELECOMM_SESSIONS as ts
left join Spedmon.dbo.CLIENTS_CLIENT as clc on clc.CLIENT_ID = ts.clientID
where
  (ts.id = @sessionID) 
 
/*============================================================
  * Build @formInviteText based on meeting purpose
  *==========================================================*/ 

--declare @patId bigint
--declare @patName [nvarchar](100)

SET @formInviteText =
    'Hello ' + @participantName + ':' 
  + '<br><br><strong>' + @clientName + '</strong> has scheduled '
  + '<strong>'  + @roomTitle + '</strong> '

if (@purposeID = 3)
begin
 
  --set @participantsHtmlTbl = ''

  SELECT
    @patId=JSON_VALUE( @purposeSpecificData,  '$."patID"' )

  SELECT top 1
    @patName = CONCAT_NAME
  FROM [SPEDMON].dbo.PATIENTS_Patient WHERE PATIENT_ID = @patId

  SET @formInviteText +=
  'for ' + @patName + ' '
 


  --declare @otherParticipantsRsvpStatus as varchar(max) = ''
 
  /* Create a html table using string_agg, etc..*/

  set
    @participantsHtmlTbl = '<br>Other Participants:<br><br><table class="table">' +
      '<thead>' +
      '<th>Participant</th>' +
	  '<th>Title</th>' +
      '<th>Will Attend?</th>' +  
      '</thead><tbody>' +
      '<tr>'

 select
    @participantsHtmlTbl +=
      STRING_AGG(
         ISNULL( '<td>' +
           tsp."name" + '</td><td>' + tsp.title +'</td><td>' +
          [spedmon].dbo.RPT_BIT_TO_YNU( tsp.inviteRsvpWillAttend ) +
          -- regrettably, the Users db doesn't have this conversion utility function
          -- so we're reaching into the Spedmon database
         '</td>', '')
         ,
         '</tr><tr>'
      )
    
  from dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp
  where (tsp.telecommSessionID = @sessionID)
  AND ( ISNULL(tsp.email, '') != '' OR ISNULL(tsp."name", '') != '' )

 set
    @participantsHtmlTbl += 
      '</tr></tbody></table>'

end

SET @formInviteText +=
  'at <strong> ' + CAST( @startTime as varchar ) +
  -- TODO: format the @startTime var TWICE
  --       to use "on ... at ..." verbiage
  '</strong>'  +
  '. This meeting should last about ' + CAST(@numMinutes as varchar ) + ' minutes.' +
  '  Please confirm that you will attend the meeting, by clicking the ' +
  '<strong>Yes, I will attend</strong> button.  If you are not able to attend, ' +
  'please click <strong>No, I cannot attend</strong> and provide a reason in the comments field below.'

end 

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TELECOMM_SESSION_GET_INFO_FOR_RSVP] TO [webuser]
GO



USE [users]
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_SAVE_CORE
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_SAVE
GO


IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'TelecommParticipantDetails')
DROP TYPE TelecommParticipantDetails
GO

/*-------------------------------
 * Object Definitions
 *------------------------------*/

CREATE TYPE TelecommParticipantDetails AS TABLE (   
    [idx]                           bigint
  , [name]                          varchar(256)
  , [title]                         varchar(256)
  , [email]                         varchar(256)
  , [phone]                         varchar(256)
  , [pin]                           varchar(50)
  , [userID]                        bigint
  , [roleID]                        bigint	  
  , [entityID]                      bigint

  , inviteRsvpToken                 nvarchar(128)


  , inviteRsvpWillAttend                  bit
  --, inviteRsvpAlternateDatetimeRequested  datetime

  , inviteRsvpNotes                       varchar(512)

	    
)
GO

GRANT EXECUTE ON TYPE::TelecommParticipantDetails TO [webuser]
  -- this execute statement should be here, not in USERS_SAVE_CORE.sql
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_SAVE] (
    @userID                           BIGINT    
  , @userGroup                        INT    
  , @userRank                         INT 
  , @appName                          varchar(50)    /* Application name (from web.config)*/
  , @environmentID                    BIGINT         /* 1= dev, 2= test, 3= production */
  , @purposeID                        BIGINT         /* 1= General meeting, 2= Telehealth, 3= IEP */
  , @authorizationMethodID            BIGINT         /* 1= email/pin, 2= App account*/
  , @clientID                         bigint
  , @hasFacilitator                   bit
  , @facilitatorIsParticipant         bit
  , @facilitatorName                  varchar(256)
  , @facilitatorTitle                 varchar(256)
  , @facilitatorEmail                 varchar(256)
  , @facilitatorPhone                 varchar(256)
  , @facilitatorUserID                bigint
  , @facilitatorRoleID                bigint	  
  , @facilitatorEntityID              bigint	    
  , @title                            varchar(512)
  , @content                          nvarchar(max)
  , @formsHTML                        nvarchar(max)
  , @formsJSON                        nvarchar(max)
  , @meetingDate                      date
  , @meetingTime                      time(0)
  , @meetingDurationInMins            int  
  , @participantDetailsJSON           varchar(max)
  , @participantDetails               TelecommParticipantDetails READONLY
  , @filesToShareUploadIDs            varchar(8000)
  , @purposeSpecificData              varchar(max)     /* pupose specific data*/
  , @editDelReason                    VARCHAR(7000)    
  , @validateRec               BIT    
  , @saveType                  INT    
  , @recID                     BIGINT    
  , @MsgNoRec                  VARCHAR(1000)    
  , @MsgNoEdit                 VARCHAR(1000) 
  , @MsgDupRec                 VARCHAR(1000)     
  , @MsgDataError              VARCHAR(1000)
  , @MsgNotActive              VARCHAR(1000)     
  , @recordID                  BIGINT        OUTPUT  
  , @jsonData                  varchar(max)  OUTPUT
  , @spDetails                 VARCHAR(8000) OUTPUT)    

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_SESSION_SAVE */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
declare @today           as DATETIME         -- Current date/time stamp    
declare @roomID          as varchar(256)
declare @serverSessionID as varchar(256)
declare @startDate       as datetime
declare @endDate         as datetime
declare @meetingDateTime as datetime
declare @roomBaseURL                 as varchar(256)
declare @inviteEmailBodyTemplateText as varchar(max)
declare @inviteEmailBodyTemplateHtml as varchar(max)
declare @tranOpen        as bit       = 0
declare @canEdit         as bit = 0

declare @participantsToSave as table (
    [idx]                           bigint
  , [name]                          varchar(256)
  , [title]                         varchar(256)
  , [email]                         varchar(256)
  , [phone]                         varchar(256)
  , [pin]                           varchar(50)
  , [userID]                        bigint
  , [roleID]                        bigint	  
  , [entityID]                      bigint	  
  , [userToken]                     nvarchar(128)
  , [canEditOrRemove]               bit
  , [sessionFacilitator]            bit
  , inviteRsvpToken                       nvarchar(128)

  , inviteRsvpWillAttend                  bit
  , inviteRsvpAlternateDatetimeRequested  datetime
  , inviteRsvpNotes                       varchar(512)

)

declare @patEmailsAndPhoneNumbersToUpdate as table (
    idx        bigint identity(1,1)
  , patientID  bigint
  , email      nvarchar(256)
  , phone      nvarchar(14)
)

declare @minIdx as bigint
declare @maxIdx as bigint
declare @curIdx as bigint

/*============================================================
 * Init
 *============================================================*/  

set @recordID  = 0
set @today     = GETDATE()    
set @spDetails = ''
set @jsonData  = ''
set @tranOpen  = 0
  
set @jsonData = '{"roomID":""'
              + ',"meetingDateTime":"'
              + ',"meetingTitle":""'
              + ',"meetingDate":""'
              + ',"meetingTime":""'
              + ',"meetingDurationInMins":0'
              + ',"hasFacilitator":false'
              + ',"facilitatorIsParticipant":false'
              + ',"facilitatorName":""'
              + ',"facilitatorTitle":""'
              + ',"facilitatorEmail":""'
			  + ',"purposeID":0'
			  + ',"roomBaseURL":""'
			  + ',"inviteEmailBodyTemplateText":""'
			  + ',"inviteEmailBodyTemplateHtml":""'
              + ',"serverSessionID":""'
              + ',"participants":[]}'



BEGIN TRY    

/*============================================================
 * Verify parameters
 *============================================================*/  
   
IF (@appName       IS NULL) RAISERROR ('appName is required',        11, 1)  
IF (@title         IS NULL) RAISERROR ('title is required',          11, 1)  
if (@environmentID IS NULL) RAISERROR ('environmentid is required',  11, 1)  
if (@meetingDate   is null) RAISERROR ('Meeting date required',      11, 1)
if (@meetingTime   is null) RAISERROR ('Meeting time required',      11, 1)

set @meetingDurationInMins = isnull(@meetingDurationInMins,0)

if (@meetingDurationInMins < 10)  RAISERROR ('Meeting duration must be at least 10 minutes', 11,1)
if (@meetingDurationInMins > 480) RAISERROR ('Meeting duration cannot exceed 8 hours',       11,1)

set @startDate = convert (datetime, @meetingDate) + convert(datetime,@meetingTime)
set @endDate   = dateadd (minute, @meetingDurationInMins,@startDate)
set @meetingDateTime = @startDate

if (@meetingDateTime <= @today) RAISERROR ('Meeting cannot be scheduled in the past', 11, 1)


/*============================================================
 * Manage participant data
 *============================================================*/  

/*-------------------------------    
 * Add facilitator to save list
 *------------------------------*/

if ((@hasFacilitator = 1) and (@facilitatorIsParticipant = 1))
begin
  insert into @participantsToSave
  select
	    idx                = 0
	  , name               = @facilitatorName
      , title              = @facilitatorTitle
      , email              = trim(isnull(@facilitatorEmail,''))
      , phone              = @facilitatorPhone
      , pin                = null
	  , userID             = @facilitatorUserID
      , roleID             = @facilitatorRoleID
      , entityID           = @facilitatorEntityID		
	  , userToken          = null
	  , canEditOrRemove    = 0

	  , sessionFacilitator = 1
      ,  inviteRsvpToken         = null

      , inviteRsvpWillAttend     = null
      , inviteRsvpAlternateDatetimeRequested  = null
      , inviteRsvpNotes                       = null

end

/*-------------------------------    
 * Add other participants to
 * save list
 *------------------------------*/

insert into @participantsToSave
select      
	pd.idx
  , pd.name 
  , pd.title
  , email = trim(isnull(pd.email,''))
  , pd.phone
  , pin = null
  , pd.userID
  , pd.roleID
  , pd.entityID
  , userToken          = null
  , canEditOrRemove    = 1
  , sessionFacilitator = 0
  ,  inviteRsvpToken         = null

  , inviteRsvpWillAttend     = null
  , inviteRsvpAlternateDatetimeRequested  = null
  , inviteRsvpNotes                       = null
from @participantDetails as pd


/*-------------------------------    
 * Check for duplicates
 *------------------------------*/

if exists(select 1 from @participantsToSave where (email != '') group by email having count(idx) > 1)
begin
  RAISERROR ('Each participant must have their own email', 11, 1)
end

/*============================================================
 * If this is a record edit
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  
  /*-------------------------------    
   * Find record
   *------------------------------*/

  select top 1   
      @recordID = ts.id 
    , @roomID   = ts.roomID 
    , @canEdit  = dbo.TELECOMM_SESSION_CAN_EDIT (ts.active,ts.startDate, ts.endDate)  
  
  from dbo.TELECOMM_SESSIONS as ts
  
  where 
    (ts.id = @recID)
 
  /*-------------------------------    
   * Not found?  Get out.
   *------------------------------*/

  if (@recordID is null) RAISERROR (@msgNoRec, 11, 1)

  /*-------------------------------    
   * Can no longer edit?  Get out.
   *------------------------------*/

  if (@canEdit = 0) RAISERROR (@msgNoEdit, 11, 1)

  /*-------------------------------    
   * Load in previous pins for
   * participants
   *------------------------------*/

  update t1
  set 
    t1.pin = t2.pin

  from @participantsToSave                as t1
  join dbo.TELECOMM_SESSIONS_PARTICIPANTS as t2 on  (t2.telecommSessionID = @recordID)
                                                and (t2.email = t1.email)                                                
  where (
        (t1.pin is null) 
    and (t2.pin is not null)  
	and (t1.email != '')  
  )

  update t1
  set 
    t1.inviteRsvpToken = t2.inviteRsvpToken

  from @participantsToSave                as t1
  join dbo.TELECOMM_SESSIONS_PARTICIPANTS as t2 on  (t2.telecommSessionID = @recordID)
                                                and (t2.email = t1.email)                                                
  where (
        (t1.inviteRsvpToken is null) 
    and (t2.inviteRsvpToken is not null)  
	and (t1.email != '')  
  )

  update t1
  set 
    t1.inviteRsvpWillAttend = t2.inviteRsvpWillAttend

  from @participantsToSave                as t1
  join dbo.TELECOMM_SESSIONS_PARTICIPANTS as t2 on  (t2.telecommSessionID = @recordID)
                                                and (t2.email = t1.email)                                                
  where (
        (t1.inviteRsvpWillAttend is null) 
    and (t2.inviteRsvpWillAttend is not null)  
	and (t1.email != '')  
  )

  update t1
  set 
    t1.inviteRsvpAlternateDatetimeRequested = t2.inviteRsvpAlternateDatetimeRequested

  from @participantsToSave                as t1
  join dbo.TELECOMM_SESSIONS_PARTICIPANTS as t2 on  (t2.telecommSessionID = @recordID)
                                                and (t2.email = t1.email)                                                
  where (
        (t1.inviteRsvpAlternateDatetimeRequested is null) 
    and (t2.inviteRsvpAlternateDatetimeRequested is not null)  
	and (t1.email != '')  
  )

  update t1
  set 
    t1.inviteRsvpNotes = t2.inviteRsvpNotes

  from @participantsToSave                as t1
  join dbo.TELECOMM_SESSIONS_PARTICIPANTS as t2 on  (t2.telecommSessionID = @recordID)
                                                and (t2.email = t1.email)                                                
  where (
        (t1.inviteRsvpNotes is null) 
    and (t2.inviteRsvpNotes is not null)  
	and (t1.email != '')  
  )


end

/*============================================================
 * Advisement validation
 *============================================================*/  
        
IF (@validateRec = 1) RETURN(0)  

BEGIN TRANSACTION
set @tranOpen = 1

/*============================================================
 * Save New
 *============================================================*/  
   
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN    


/*-------------------------------    
 * Create new session record
 *------------------------------*/  

  insert into dbo.TELECOMM_SESSIONS (
        [appName] 
	  , [environmentID]
	  , [purposeID]
	  , [authorizationMethodID]
	  , [clientID]
	  , hasFacilitator
	  , facilitatorIsParticipant
	  , facilitatorName
      , facilitatorTitle
      , facilitatorEmail
      , facilitatorPhone
      , facilitatorUserID
      , facilitatorRoleID
      , facilitatorEntityID	
      , [title] 
	  , [content]
	  , [formsHTML]
	  , [formsJSON]
	  , [meetingDate]
	  , [meetingTime]
	  , [meetingDurationInMins]
      , [startDate]  
	  , [endDate]  
	  , [participantDetailsEnteredJSON]
	  , [purposeSpecificData]
      , [created]  
      , [createdBy] 
  )
  values (
      @appName
	, @environmentID
    , @purposeID
	, @authorizationMethodID
	, @clientID 
	, @hasFacilitator
	, @facilitatorIsParticipant
	, @facilitatorName
    , @facilitatorTitle
    , @facilitatorEmail
    , @facilitatorPhone
    , @facilitatorUserID
    , @facilitatorRoleID
    , @facilitatorEntityID		
    , @title
    , @content
	, @formsHTML
	, @formsJSON
    , @meetingDate
	, @meetingTime
	, @meetingDurationInMins
	, @startDate
    , @endDate
	, @participantDetailsJSON
	, @purposeSpecificData
    , @today
    , @userID
  )
    
  set @recordID = SCOPE_IDENTITY()  
  
  /*-------------------------------    
   * Generate room ID
   * This is the ID we distribute
   * to the participants
   * 
   * 999-999-999-9999999999999999999
   *
   *------------------------------*/  
  
  set @roomID = (select convert(varchar,abs(VALUE_TINYINT)) from dbo.GENERATE_RANDOM_NUMBERS)              			               			  
			  + '-'			  
			  + (select convert(varchar,abs(VALUE_TINYINT)) from dbo.GENERATE_RANDOM_NUMBERS)              			  
			  + '-'
			  + (select convert(varchar,abs(VALUE_TINYINT)) from dbo.GENERATE_RANDOM_NUMBERS)              			  
			  + '-'            
			  + convert(varchar,12)
		
  /*-------------------------------    
   * Generate server session ID
   * This is the ID we use to
   * setup and access a telecom
   * session with our telecomm
   * server software
   *------------------------------*/  

  set @serverSessionID = @appName
                       + '-'
                       + convert(varchar,@environmentID)
                       + '-'
                       + @roomID

  /*-------------------------------    
   * Update our session record
   * with the required data
   *------------------------------*/  

  update dbo.TELECOMM_SESSIONS
  set 
      roomID          = @roomID
	, serverSessionID = @serverSessionID
  where (id = @recordID)

END

/*============================================================
 * Edit existing
 *============================================================*/  

ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT()) 
BEGIN
  
  set @recordID = @recID
  
  /*-------------------------------    
   * Update fields user is allowed
   * to change
   *------------------------------*/  

  update dbo.TELECOMM_SESSIONS 
    set 
       title                          = @title
     , content                        = @content    
	 , meetingDate                    = @meetingDate
	 , meetingTime                    = @meetingTime
	 , meetingDurationInMins          = @meetingDurationInMins    
	 , startDate                      = @startDate
     , endDate                        = @endDate
	 , participantDetailsEnteredJSON  = @participantDetailsJSON
	 , lastModfied                    = @today 
     , lastModifedBy                  = @userID    
   where (ID = @recordID)

END
ELSE
BEGIN
  RAISERROR ('Unknown save type', 11, 1)  
END


/*============================================================
 * Manage participant data part 2/2
 *============================================================*/  

/*-------------------------------    
 * Generate new pins if needed
 *------------------------------*/

update @participantsToSave
set 
  pin = (select top 1 pin = convert(varchar,abs(VALUE_SMALLINT)) from dbo.GENERATE_RANDOM_NUMBERS)
where (pin is null)

update @participantsToSave
set 
   inviteRsvpToken = ( select top 1 VALUE_TINYINT+20 from dbo.GENERATE_RANDOM_NUMBERS)
where (inviteRsvpToken is null)

/*-------------------------------    
 * Generate new tokens
 *------------------------------*/

update @participantsToSave
set 
  userToken = dbo.GENERATE_PASSWORD ((select top 1 VALUE_TINYINT+20 from dbo.GENERATE_RANDOM_NUMBERS))

/*-------------------------------    
 * For IEP meetings
 * assign facilitator role
 * for predetermined participant slots
 *
 * TODO: Move to app specific sproc
 * when we convert this to a save core
 * This is a temporary
 * solution since app specific
 * code is not suppposed to be here
 *------------------------------*/

if (@purposeID = 3)
begin
  update @participantsToSave
    set sessionFacilitator = 1
  where idx in (4,5,6)

  update @participantsToSave
    set sessionFacilitator = 0
  where idx not in (4,5,6)
end

/*-------------------------------    
 * Clear out previous participant
 * data
 *------------------------------*/

delete dbo.TELECOMM_SESSIONS_PARTICIPANTS
where (telecommSessionID = @recordID)


-- TODO: We need to make sure that editing an IEP/telecom meeting in the save form doesn't over-write
-- any of the hidden fields for dbo.TELECOMM_SESSIONS_PARTICIPANTS that don't render visibly in the save form.
-- Namely, inviteRsvpToken, inviteRsvpNotes, requestedRescheduleDatetime ...

-- I haven't tested this yet but I predict it may require a bug-fix, low priority...
-- or high priority!!

/*-------------------------------    
 * For district specific 
 * participants who do not
 * have a userID attempt to 
 * find a userID based on their
 * email. 
 *------------------------------*/

update ps
  set ps.userID = ua2.id
from @participantsToSave as ps
cross apply (
  select top 1 
    ua1.id 
  from dbo.USERS_ALL as ua1
  where (
        (ua1.clientID  = @clientID)                                  /* Limit to client */
    and (ua1.email     = convert(nvarchar(256),isnull(ps.email,''))) /* Make sure we are comparing against same datatype */
    and (ua1.email != N'')                                           /* Exclude empty emails */
	and (ua1.email not like (N'@quit@%'))                            /* Account must be active */
    and (ua1.userGroupID = 1)                                        /* District specific user group*/
	and (ua1.roleID in (7,5))                                        /* prac or lea coordinator role */
  )
) as ua2
where (
      (ps.userID is null)
  and (ps.roleID in (7,5)) /* Practitioners or LEA Coordinators */
)

/*-------------------------------    
 * For parent guardians 
 * find a userID based on their
 * email and role. 
 * These users will only
 * have one account but may have
 * multiple client associations.
 *------------------------------*/

update ps
  set ps.userID = ua2.id
from @participantsToSave as ps
cross apply (
  select top 1 
    ua1.id 
  from dbo.USERS_ALL as ua1
  where (
        (ua1.email     = convert(nvarchar(256),isnull(ps.email,''))) /* Make sure we are comparing against same datatype */
    and (ua1.email != N'')                                           /* Exclude empty emails */
	and (ua1.email not like (N'@quit@%'))                            /* Account must be active */
    and (ua1.userGroupID = 3)                                        /* Third party user group */
	and (ua1.roleID      = 12)                                       /* Parent guardians */
  )
) as ua2
where (
    
      (ps.userID is null)
  and (ps.roleID in (12)) /* Parent guardians */
)

/*-------------------------------    
 * Put in participant data
 *------------------------------*/

insert into dbo.TELECOMM_SESSIONS_PARTICIPANTS
(
	[telecommSessionID]  ,
	[idx]                ,
	[name]               ,
	[title]              ,
	[email]              ,
	[phone]              ,
	[pin]                ,
	[userID]             ,
	[roleID]             ,
	[entityID]           ,
	[userToken]          ,
	[canEditOrRemove]    ,
	[sessionFacilitator] ,


    [inviteRsvpToken]    ,

    inviteRsvpWillAttend ,
    inviteRsvpAlternateDatetimeRequested ,
    inviteRsvpNotes      ,

	[attendedSession]
)
select 
  telecommSessionID = @recordID
, ps.* 
, attendedSession = 0
from @participantsToSave as ps

/*============================================================
 * Manage participant email and phone retention
 *============================================================*/  

/*-------------------------------    
 * Patients
 *------------------------------*/

insert into @patEmailsAndPhoneNumbersToUpdate
select 
    patientID = pd.entityID
  , email     = pd.email
  , phone     = pd.phone
from @participantDetails as pd
where (pd.roleID = 99)

select @minIdx = min(idx), @maxIdx = max(idx) from @patEmailsAndPhoneNumbersToUpdate
set @curIdx = @minIdx

while (@curIdx <= @maxIdx)
begin

  declare @patientID as bigint
  declare @email     as nvarchar(256)
  declare @phone     as nvarchar(14)

  select top 1 
      @patientID = t1.patientID
	, @email     = t1.email
    , @phone      = t1.phone
  from @patEmailsAndPhoneNumbersToUpdate as t1
  where (idx = @curIdx)

  exec SPEDMON.dbo.PATIENT_EMAIL_ADDRESS_MANAGE_CORE @userID, @today , @patientID, @email    
  exec SPEDMON.dbo.PATIENT_PHONE_NUMBER_MANAGE_CORE  @userID, @today , @patientID, @phone    

  set @curIdx = @curIdx + 1

end

/*============================================================
 * Manage file share data
 *============================================================*/  

exec dbo.TELECOMM_SESSION_MANAGE_SHARED_FILES_CORE @userID, @today, @recordID, @filesToShareUploadIDs

/*-------------------------------    
 * Prepare output data
 *------------------------------*/

declare @participantJsonData as varchar(max)

set @participantJsonData = (
select 
    [idx]
  , [name]
  , title = isnull(title,'')
  , [email]
  , phone = isnull(phone,'')
  , [pin]  
  , userID = isnull(userID,-1)
  , roleID = isnull(roleID,-1)
  , entityID = isnull(entityID,-1)

  , inviteRsvpToken

  , inviteRsvpWillAttend
  , inviteRsvpAlternateDatetimeRequested
  , inviteRsvpNotes

from @participantsToSave
--from dbo.TELECOMM_SESSIONS_PARTICIPANTS 
--where (telecommSessionID = @recordID)
FOR JSON AUTO, INCLUDE_NULL_VALUES
)
 
select 
	  @roomBaseURL                 = tsp.roomBaseURL                
	, @inviteEmailBodyTemplateText = tsp.inviteEmailBodyTemplateText
	, @inviteEmailBodyTemplateHtml = tsp.inviteEmailBodyTemplateHtml
from [dbo].[TELECOMM_SESSION_PURPOSE] as tsp
where tsp.id = @purposeID

set @jsonData = '{'
              + '"roomID":"'                + STRING_ESCAPE (isnull(@roomID,''),'JSON') +'"'
			  + ',"meetingDateTime":"'      + STRING_ESCAPE (convert(varchar, @meetingDateTime, 22 ),'JSON') + '"' 
              + ',"meetingTitle":"'         + STRING_ESCAPE (isnull(@title,''),'JSON') + '"'              
			  + ',"meetingDate":"'          + STRING_ESCAPE (dbo.RPT_DATE_FMT(@meetingDate),'JSON') + '"' 
              + ',"meetingTime":"'          + STRING_ESCAPE (dbo.RPT_TIME_FMT(@meetingTime,0),'JSON') + '"' 
              + ',"meetingDurationInMins":' + convert(varchar(100),isnull(@meetingDurationInMins,0))  
              + ',"hasFacilitator":'           + iif((@hasFacilitator = 1),'true','false')
			  + ',"facilitatorIsParticipant":' + iif((@facilitatorIsParticipant = 1),'true','false')  
              + ',"facilitatorName":"'         + STRING_ESCAPE (isnull(@facilitatorName,''), 'JSON') + '"'
              + ',"facilitatorTitle":"'        + STRING_ESCAPE (isnull(@facilitatorTitle,''),'JSON') + '"'
              + ',"facilitatorEmail":"'        + STRING_ESCAPE (isnull(@facilitatorEmail,''),'JSON') + '"'
			  + ',"purposeID":'                     + convert(varchar(10),isnull(@purposeID,0))  
	  	      + ',"roomBaseURL":"'                  + STRING_ESCAPE (isnull(@roomBaseURL,''), 'JSON') +'"'
			  + ',"inviteEmailBodyTemplateText":"'  + STRING_ESCAPE (isnull(@inviteEmailBodyTemplateText,''), 'JSON') +'"'
			  + ',"inviteEmailBodyTemplateHtml":"'  + STRING_ESCAPE (isnull(@inviteEmailBodyTemplateHtml,''), 'JSON') +'"'
			  + ',"serverSessionID":"'              + STRING_ESCAPE (isnull(@serverSessionID,''), 'JSON') +'"'
              + ',"participants":'             + @participantJsonData + '}'
              
set @tranOpen = 0
COMMIT TRANSACTION

RETURN(0)    

END TRY    
BEGIN CATCH    
   
if (@tranOpen  = 1) ROLLBACK TRANSACTION

  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
         
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON TYPE::TelecommParticipantDetails TO [webuser]
GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_SAVE] TO [webuser]
GO

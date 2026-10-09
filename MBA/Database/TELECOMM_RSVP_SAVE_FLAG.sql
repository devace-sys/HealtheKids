USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_RSVP_SAVE_FLAG') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_RSVP_SAVE_FLAG
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TELECOMM_RSVP_SAVE_FLAG]     
 (

    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    

  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT

  , @recID          bigint,  -- 0; ignored

  @roomID             varchar(256)
  --, @rsvpToken          nvarchar(128)
  ,
    @inviteRsvpWillAttend                 BIT           ,
    @inviteRsvpToken                      nvarchar(128) ,
    @inviteRsvpAlternateDatetimeRequested datetime      ,
    @inviteRsvpNotes                      varchar(512)  ,

    @msgDupRec          VARCHAR(1000)     -- not checked, not used   

  , @MsgNoRec           VARCHAR(1000)     -- not checked, not used   
  , @MsgNoEdit          VARCHAR(1000)     -- not checked, not used   
  , @MsgDataError       VARCHAR(1000)     -- not checked, not used   

  , @MsgNotActive       VARCHAR(1000)     -- not checked, not used   

  , @spDetails          VARCHAR(8000) OUTPUT
  , @recordID           BIGINT        OUTPUT

 ) 
   
AS    
BEGIN     
    
/***************************************************************************    
 * TELECOMM_RSVP_SAVE_FLAG */    
/**    
 * Saves the RSVP response for a meeting participant.
 * 
 * For IEP meetings (purposeID = 3), also writes the confirmation
 * status back to the patient's spEdParticipantDetailsJSON so the
 * IEP grid can display Yes/No/N/A without a separate query.
 * 
 * @param   roomID                    Room ID of the meeting
 * @param   inviteRsvpWillAttend      1 = will attend, 0 = will not attend
 * @param   inviteRsvpToken           Unique RSVP token for this participant
 * @param   inviteRsvpAlternateDatetimeRequested  Alternate date requested
 * @param   inviteRsvpNotes           Notes from the participant
 ***************************************************************************/         
     
SET NOCOUNT ON    

DECLARE @TranOpen     AS BIT    

set @spDetails                 = ''
set @recordID                  = 0

declare
    @email                    varchar(256)
  , @pin                      varchar(50) 
  , @today                    datetime
  , @skipMeetingHasNotStartedCheck bit = 0
  , @sessionOK                bit
  , @sessionID                bigint
  , @participantClientID      bigint
  , @participantID            bigint
  , @isSessionFacilitator     bit

  , @auditLogID              bigint

SET @today = GETDATE()

select top 1
    @email = tsp.email
  , @pin   = tsp.pin
from dbo.TELECOMM_SESSIONS              as ts
join dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp on tsp.telecommSessionID = ts.id
where (
      (ts.roomID = @roomID)
  and (inviteRsvpToken = @inviteRsvpToken)
)

BEGIN TRY    
     
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/

/*============================================================
  * Call sesion validate skipping not started check 
  *============================================================*/ 
 
exec [dbo].[TELECOMM_SESSION_VALIDATE_CORE]
    @roomID                  
  , @email                   
  , @pin                     
  , @today                   
  , 1 -- @skipMeetingHasNotStartedCheck
  , @sessionOK                output
  , @sessionID                output
  , @participantClientID      output
  , @participantID            output
  , @isSessionFacilitator     output

 
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
    
  /*-------------------------------    
   * UPDATE existing participant    
   * RSVP data    
   *------------------------------*/    
          
  UPDATE [dbo].[TELECOMM_SESSIONS_PARTICIPANTS]
  SET     
    inviteRsvpWillAttend = @inviteRsvpWillAttend                 ,
    inviteRsvpToken      = @inviteRsvpToken                      ,
    inviteRsvpAlternateDatetimeRequested = @inviteRsvpAlternateDatetimeRequested ,
    inviteRsvpNotes = @inviteRsvpNotes                      
  WHERE id = @participantID

  /*-------------------------------    
   * Create audit log entry    
   *------------------------------*/    

  declare @logDataJSON varchar(max) = '{'
                     + ' "willAttendSession":"' + cast( @inviteRsvpWillAttend as varchar) + '"'
                     + ',"altDateRequested":"' + cast( @inviteRsvpAlternateDatetimeRequested as varchar)   + '"'
      + ',"rsvpNotes":"'         + STRING_ESCAPE( @inviteRsvpNotes , 'json' )         + '"'
      + '}'
 
  exec dbo.TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE
      @sessionID
   , @today
   , @participantID
   , 'RSVP'
   , '' -- todo: @userIP
   , '' -- todo: @userAgent
   , @logDataJSON
   , @auditLogID output

  /*============================================================
   * Write RSVP confirmation back to patient IEP JSON
   * 
   * For IEP meetings (purposeID = 3), the session's 
   * purposeSpecificData contains the patID.  We use it to
   * find the patient record and update their 
   * spEdParticipantDetailsJSON with the confirmation status
   * so the IEP grid displays Yes/No/N/A without a separate
   * query back to the TeleComm tables.
   *============================================================*/

  declare @purposeID           as bigint
  declare @purposeSpecificData as varchar(max)
  declare @patID               as bigint
  declare @existingJSON        as varchar(max)
  declare @confirmationValue   as varchar(20)

  /*-------------------------------    
   * Get session purpose and data
   *------------------------------*/

  select top 1
      @purposeID           = ts.purposeID
    , @purposeSpecificData = ts.purposeSpecificData
  from dbo.TELECOMM_SESSIONS as ts
  where (ts.id = @sessionID)

  /*-------------------------------    
   * Only process IEP meetings
   * (purposeID = 3)
   *------------------------------*/

  if (@purposeID = 3 and @purposeSpecificData is not null)
  begin

    /*-------------------------------    
     * Extract patID from the
     * purpose specific data JSON
     * using the existing SPEDMON
     * deserialization UDF
     *------------------------------*/

    select top 1
      @patID = psd.patID
    from SPEDMON.dbo.TELECOMM_IEP_DESERIALIZE_PURPOSE_SPECIFIC_DATA(@purposeSpecificData) as psd

    if (@patID is not null and @patID > 0)
    begin

      /*-------------------------------    
       * Load the existing participant
       * details JSON from the patient
       *------------------------------*/

      select top 1
        @existingJSON = pap.spEdParticipantDetailsJSON
      from SPEDMON.dbo.PATIENTS_Patient as pap
      where (pap.PATIENT_ID = @patID)

      /*-------------------------------    
       * Determine confirmation value
       *------------------------------*/

      set @confirmationValue = case 
        when @inviteRsvpWillAttend = 1 then 'accepted'
        when @inviteRsvpWillAttend = 0 then 'declined'
        else 'none'
      end

      /*-------------------------------    
       * Update the JSON if it exists
       * and contains participant data.
       *
       * Find the participant by email
       * in the participants array and
       * set their confirmation field.
       *------------------------------*/

      if (@existingJSON is not null and len(@existingJSON) > 2)
      begin

        declare @participantIdx as int = null

        /*-------------------------------    
         * Find the array index of the
         * participant whose email
         * matches the RSVP respondent
         *------------------------------*/

        select top 1
          @participantIdx = cast(t1.[key] as int)
        from OPENJSON(@existingJSON, '$.participants') as t1
        cross apply OPENJSON(t1.[value])
          with (
            email varchar(256) '$.email'
          ) as t2
        where (
              (t2.email is not null)
          and (ltrim(rtrim(lower(t2.email))) = ltrim(rtrim(lower(@email))))
        )

        /*-------------------------------    
         * If found, update that
         * participant's confirmation
         * field using JSON_MODIFY
         *------------------------------*/

        if (@participantIdx is not null)
        begin

          declare @jsonPath as nvarchar(200) = '$.participants[' + cast(@participantIdx as varchar(10)) + '].confirmation'

          set @existingJSON = JSON_MODIFY(@existingJSON, @jsonPath, @confirmationValue)

          /*-------------------------------    
           * Write the updated JSON back
           * to the patient record
           *------------------------------*/

          update SPEDMON.dbo.PATIENTS_Patient
          set spEdParticipantDetailsJSON = @existingJSON
          where (PATIENT_ID = @patID)

        end

      end

    end

  end
       
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
     
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY    
    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
    
  -- Error or raise error with severity 11 to 19 will be caught here    
    
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
    
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
    
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
    
  -- Reraise the error so it returns back to the server    
    
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
GO




GRANT EXECUTE ON  [dbo].[TELECOMM_RSVP_SAVE_FLAG] TO [webuser]
GO

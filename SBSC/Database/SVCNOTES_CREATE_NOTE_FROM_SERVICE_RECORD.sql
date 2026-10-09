USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_NOTE_FROM_SERVICE_RECORD') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_NOTE_FROM_SERVICE_RECORD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.SVCNOTES_CREATE_NOTE_FROM_SERVICE_RECORD
(
  @userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,  
  @svcRecID      BIGINT,   
  @entryType     INT,
  @saveType      INT,    
  @validateRec   BIT
)

AS
BEGIN

/***************************************************************************    
 * SVCNOTES_CREATE_NOTE_FROM_SERVICE_RECORD */ 
 
/**    
 * Create a new service record note
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 *
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete  
 *  
 * @param   svcRecID        Service record to associate with this note
 * @returns recordID        New record id of the note
 ***************************************************************************/     

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userID        IS NULL) RAISERROR ('userID is required',            11, 1)
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',         11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',          11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',        11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',         11, 1)
IF (@entryType     IS NULL) RAISERROR ('Entry type is required',        11, 1)
IF (@svcRecID      IS NULL) RAISERROR ('Service record id is required', 11, 1)

/*============================================================
 * Exit if we do not want to generate a note based on the
 * context in which this sproc is called
 *============================================================*/ 
  
IF (@userGroup   != dbo.CONST_USER_GROUP_CLIENT()) RETURN (0)  
--IF (@saveType    != dbo.CONST_SAVE_TYPE_NEW())     RETURN (0)
IF (@validateRec =  1)                             RETURN (0)

/*============================================================
 * Exit if the entry type is the svc journal entry screen
 * we collect note data from events
 *============================================================*/  

IF (@entryType   = 10) RETURN (0)

/*============================================================
 * Fetch service record data to associate with this note
 *============================================================*/  

declare @today      as datetime         = GETDATE()    
declare @recordID   as bigint           = null
declare @clientID   as bigint
declare @pracID     as bigint
declare @groupID    as bigint
declare @patID      as bigint
declare @dos        as datetime
declare @SvcType    as int
declare @patAbsent  as bit  
declare @svcNote    as varchar(8000)

select 
  @SvcType   = svcType, 
  @patAbsent = patAbsent, 
  @clientID  = clientID,
  @pracID    = pracID,
  @groupID   = groupID,
  @patID     = patID,
  @dos       = dos,
  @svcNote   = isnull(notes,'')    
from SERVICE_RECORDS as sr where sr.id = @SvcRecID
      
/*============================================================
 * If the service record does not exist get out
 *============================================================*/  

if (@SvcType is null) RAISERROR ('Service record does not exist', 11, 1)

/*============================================================
 * Check what the practitioner should be using for notes
 *============================================================*/  

declare @inputPracID         as bigint
declare @mustUseNoteType     as bigint
declare @currentTemplateID   as bigint
declare @mustSetAPreference  as bit
declare @canChangePreference as bit
declare @currentPreferenceID as bigint
declare @typePrefID          as bigint
declare @prefNote            as varchar(8000)
declare @shortPrefDesc       as varchar(8000)
declare @longPrefDesc        as varchar(8000)
declare @mustUseReason       as varchar(8000)
declare @useFormattedNotes   as bit
 
exec SVCNOTES_CHECK_PRAC_PREF @pracID,
                              @inputPracID         OUTPUT,
                              @mustUseNoteType     OUTPUT,
                              @currentTemplateID   OUTPUT,
                              @mustSetAPreference  OUTPUT,
                              @canChangePreference OUTPUT,
                              @currentPreferenceID OUTPUT,
                              @typePrefID          OUTPUT, 
                              @prefNote            OUTPUT,
                              @shortPrefDesc       OUTPUT,
                              @longPrefDesc        OUTPUT,
                              @mustUseReason       OUTPUT,
                              @useFormattedNotes   OUTPUT
  
/*============================================================
 * Now determine if we are using formatted notes starting
 * with the preference or template value
 *============================================================*/  
  
declare @usingFormattedNotes as bit
set @usingFormattedNotes = @useFormattedNotes

/*============================================================
 * Determine if the service type requires using formatted notes
 * If so, this overrides the preference or template value
 *============================================================*/  
  
  --if (@svcType = dbo.CONST_SERVICES_ASSESS()) set @usingFormattedNotes = 1
  
/*============================================================
 * Determine if the service type will never use formatted notes
 * If so this overides the preference or template value
 *============================================================*/  

if (@SvcType = dbo.CONST_SERVICES_TRANSPORT()) set @usingFormattedNotes = 0
     
/*============================================================
 * Determine if we should not use a formatted note because
 * the patient is absent.  This overides the preference or
 * template value.
 *============================================================*/  

if ((@SvcType = dbo.CONST_SERVICES_TREATMENT()) and (@patAbsent = 1))
begin
  set @usingFormattedNotes = 0
end
     

/*============================================================
 * If we are using formatted notes
 *============================================================*/  

if (@usingFormattedNotes = 1)
begin

  /*============================================================
   * Determine note type from service type
   *============================================================*/    

  declare @noteType as bigint
  select @NoteType = id from SvcNote_NoteType as snnt where snnt.SvcType = @SvcType

  /*============================================================
   * Call sproc to do the rest
   *============================================================*/    

  exec SVCNOTES_CREATE_NOTE @userID, 
                            @userGroup, 
                            @userRank, 
                            @clientID, 
                            @pracID,
                            @groupID, 
                            @patID, 
                            @dos, 
                            @noteType, 
                            @entryType,                             
                            @recordID OUTPUT

  /*============================================================
   * Create our service record service note cross reference
   *============================================================*/  

  insert into SvcNote_SvcRec
  (
    clientID,
    svcNoteID,
    svcRecID,
    created
  )
  values
  (
    @clientID,
    @recordID,
    @svcRecID,
    @today
  )
end
 
/*============================================================
 * Create our notes audit record
 *============================================================*/  
 
insert into SERVICE_RECORD_NOTES_AUDIT_DATA
(
   svcRecID
  ,pracID
  ,patID
  ,svcType
  ,patAbsent
  ,svcNoteID
  ,svcNotes
  ,mustUseNoteType
  ,currentTemplateID
  ,mustSetAPreference
  ,canChangePreference
  ,currentPreferenceID
  ,typePrefID
  ,prefNote
  ,shortPrefDesc
  ,longPrefDesc
  ,mustUseReason
  ,useFormattedNotes
  ,usingFormattedNotes
  ,created
  ,createdBy	
) 
values 
( 
   @svcRecID
  ,@pracID
  ,@patID
  ,@SvcType
  ,@patAbsent
  ,@recordID
  ,@svcNote
  ,@mustUseNoteType
  ,@currentTemplateID
  ,@mustSetAPreference
  ,@canChangePreference
  ,@currentPreferenceID
  ,@typePrefID
  ,@prefNote
  ,@shortPrefDesc
  ,@longPrefDesc
  ,@mustUseReason
  ,@useFormattedNotes
  ,@usingFormattedNotes
  ,@today
  ,@userID
)
 
return (0)  

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SVCNOTES_CREATE_NOTE_FROM_SERVICE_RECORD] TO [webuser]
GO


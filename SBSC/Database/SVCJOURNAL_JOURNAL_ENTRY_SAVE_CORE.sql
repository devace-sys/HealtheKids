USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_ENTRY_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_ENTRY_SAVE_CORE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE dbo.SVCJOURNAL_JOURNAL_ENTRY_SAVE_CORE (
    @userID            BIGINT    
  , @userGroup         INT    
  , @userRank          INT
  , @requestIP         varchar(1000)
  , @requestUserAgent  varchar(1000)
  , @clientID          bigint
  , @pracID            bigint
  , @patID             bigint    
  , @iep               bit
  , @journalID         bigint
  , @eventType         bigint 
  , @startTime         time(0)
  , @endTime           time(0)
  , @orpDocID          BIGINT
  , @notes                            VARCHAR(8000)
  , @noteCriteriaQuestionsJSON        varchar(max)
  , @noteCriteriaAnswersJSON          varchar(max)
  , @svcNotesFormBuilderQuestionsJSON varchar(max)
  , @svcNotesFormBuilderAnswersJSON   varchar(max)
  , @editDelReason     VARCHAR(7000)
  , @validateRec       BIT    
  , @saveType          INT  
  , @recID             BIGINT   
  , @MsgNoRec          VARCHAR(1000)    
  , @MsgNoEdit         VARCHAR(1000) 
  , @MsgDupRec         VARCHAR(1000)   
  , @MsgDataError      VARCHAR(1000)
  , @MsgNotActive      VARCHAR(1000)     
  , @spDetails         VARCHAR(8000) OUTPUT
  , @recordID          BIGINT        OUTPUT
)    
AS    
BEGIN     
    
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_ENTRY_SAVE_CORE */    
/**    
 * Creates or edits new service journal entry 
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   pracID          Practitioner id
 * @param   patID           Patient id
 * @param   dos             Service date
 * @param   editDelReason   Reason for record edit or delete    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @param   recID           Record id of existing patient record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found    
 * @param   MsgNoSite       Desired error message if a siteID is not found     
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    

BEGIN TRY

/*###########################################################################
  # Setup
  ###########################################################################*/

/*============================================================
 * Init output parameters
 *============================================================*/  
    
SET @recordID   = 0    
SET @spDetails  = ''    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
    
/*============================================================
 * Declare and init worker variables
 *============================================================*/  

declare @today                     as datetime
declare @recCount                  as int     = 0
declare @patAbsent                 as bit     = null
declare @eventTypeRecID            as bigint  = null
declare @eventTypeParentRecID      as bigint  = null
declare @eventTypeContSvcGroupPart as bigint  = null
declare @startOfDayTime            as time(0) = null
declare @endOfDayTime              as time(0) = null
declare @numStartOfDay             as bigint  = null
declare @numEndOfDay               as bigint  = null
declare @numBadBreaks              as bigint  = null
declare @numOverlaps               as int     = 0
declare @numContIEP                as int     = 0
declare @numContNonIEP             as int     = 0
declare @orpRequired               as bit     = 0
declare @groupID                   as bigint  = null
declare @rdrGroupSvcClassNameID    as bigint  = null
declare @dos                       as datetime = null
declare @standAloneNonBillSvc      as bit      = null

declare @noteCrit1Question  as varchar(8000) = null
declare @noteCrit2Question  as varchar(8000) = null
declare @noteCrit3Question  as varchar(8000) = null
declare @noteCrit4Question  as varchar(8000) = null
declare @noteCrit5Question  as varchar(8000) = null
declare @noteCrit6Question  as varchar(8000) = null
declare @noteCrit7Question  as varchar(8000) = null
declare @noteCrit8Question  as varchar(8000) = null
declare @noteCrit9Question  as varchar(8000) = null
declare @noteCrit10Question as varchar(8000) = null
declare @noteCrit1Answer    as varchar(max)  = null
declare @noteCrit2Answer    as varchar(max)  = null
declare @noteCrit3Answer    as varchar(max)  = null
declare @noteCrit4Answer    as varchar(max)  = null
declare @noteCrit5Answer    as bit           = null
declare @noteCrit6Answer    as bit           = null
declare @noteCrit7Answer    as bit           = null

declare @noteCrit8Answer    as decimal(38,4) = null
declare @noteCrit9Answer    as decimal(38,4) = null
declare @noteCrit10Answer   as decimal(38,4) = null

declare @noteCriteriaQuestionsDetails table (
	  idx bigint identity(1,1)
	, [name] varchar(256)
	, label  varchar(8000)
)

declare @parsedNoteCriteriaQuestionsJSON as varchar(max) = null
set @parsedNoteCriteriaQuestionsJSON = dbo.STRING_UNESCAPE_JSON(@noteCriteriaQuestionsJSON,1)

insert into @noteCriteriaQuestionsDetails select *
from OPENJSON(@parsedNoteCriteriaQuestionsJSON)
  with (
      [name] varchar(256)  '$.name'
    , label  varchar(8000) '$.label'
  )

declare @existingEntries as table (
    journalID        bigint
  , journalEntryID   bigint
  , eventType        bigint
  , eventTypeForProc bigint
  , entryStartTime   time(0)
  , entryEndTime     time(0)
  , orpDocID         bigint
  , eventTypeContSvcGroupPart bigint
  , iep              bit
  , standAloneNonBillSvc bit
)
 
set @today = GETDATE()    



/*###########################################################################
  # Deal with orp document id default selection issue for event
  # (its currently coming up at 0)
  #
  # TODO: Fix this issue higher up when possible
  ###########################################################################*/

if (@orpDocID = 0) set @orpDocID = null

/*###########################################################################
  # Required validation for new and edit
  ###########################################################################*/

if ((@saveType = dbo.CONST_SAVE_TYPE_NEW()) or (@saveType = dbo.CONST_SAVE_TYPE_EDIT()))
begin
    
/*============================================================
 * Verify that the journal exists and it has not been closed
 *============================================================*/  

set @recCount  = 0
set @patAbsent = null

select top 1 

    @patAbsent = patAbsent 
  , @dos       = dos
from dbo.SvcJournals 

where (
      (clientID  = @clientID) 
  and (patID     = @patID) 
  and (id        = @journalID) 
  and (active    = 1) 
  and (completed = 0)
)

if (@patAbsent is null)
  RAISERROR ('Journal does not exist or it has been closed', 11, 1)
      
/*============================================================
 * Verify that event type exists and retrieve meta data
 *============================================================*/  

select top 1
    @eventTypeRecID            = t1.id
  , @eventTypeParentRecID      = t1.parentID
  , @eventTypeContSvcGroupPart = t1.contSvcGroupPart
  , @orpRequired               = t1.reqORP
  , @standAloneNonBillSvc      = t1.standAloneNonBillSvc
from dbo.SvcJournal_Event_Types as t1
where (id = @eventType)

if (@eventTypeRecID is null)
  RAISERROR ('Event type does not exist', 11, 1)

/*============================================================
 * Enforce the selection of an order or prescription if 
 * the service documented in the entry :
 *
 * -> was provided after 7/1/2018
 * -> requires an ORP document
 * -> is provided by a practitioner (rendering practitioner) in
 *    the health services group family as the family is 
 *    defined for ORP groups
 *============================================================*/  

if (@orpRequired = 1) and (@dos >= dbo.CONST_ORP_DOCUMENTATION_FOR_TREATMENT_REQUIRED_START_DATE())
begin
  
  set @groupID = null
  
  /* Get discipline group for rendering practitioner */
  
  select top 1
    @groupID  = gg.GROUP_ID
  from dbo.PRACTITIONER_GROUPS       as pg
  join dbo.GROUP_Group               as gg on  gg.GROUP_ID = pg.GROUP_ID
  where (
        (pg.PRACTITIONER_ID = @pracID)
    and (pg.GROUP_TYPE in (1,2))  
  )

  /* Get ORP service class name ID from rendering practitioners group id */

  set @rdrGroupSvcClassNameID = null
  set @rdrGroupSvcClassNameID = dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_GROUP_ID(@groupID)
   
  /* If rendering practitioner group is classified as health services and no order/prescription
     has been selected then get out */

  if ((@rdrGroupSvcClassNameID = 3) and (@orpDocID is null))
  begin   
    RAISERROR ('The selection of an order or prescription is required', 11, 1)
  end  

end

/*============================================================
 * If this is a same day entry make sure that the start and end
 * times are not in the future.  
 *
 * Allow for a 6 minute window of difference to account for
 * possible difference in peoples clocks.
 * 
 * Note: This does not account for different time zone.
 *============================================================*/  

declare @refDate as date = convert(date,@today)

if ( datediff (day, @dos,@refDate) = 0)
begin
  declare @refTime       as time(0) = convert(time(0),@today)
  declare @startTimeDiff as int     = datediff (minute,@startTime,@refTime)
  declare @endTimeDiff   as int     = datediff (minute,@endTime,@refTime)
  if (@startTimeDiff < -6) RAISERROR ('Start time cannot be in the future', 11, 1)
  if (@endTimeDiff   < -6) RAISERROR ('End time cannot be in the future',   11, 1)
end 

/*============================================================
 * Verify that start and end times are in correct temporal 
 * positions
 *============================================================*/  

if (@startTime > @endTime)
  RAISERROR ('Start time cannot be after end time', 11, 1)

/*============================================================
 * Load existing entries -- if any
 * If this is an edit we exclude the entry being edited
 * We also exclude entries flagged as standAloneNonBillible
 * svcs
 *============================================================*/  

insert into @existingEntries
select
      journalID            = sj.id
    , journalEntryID       = sjee.id
    , eventType            = sjet.id
    , eventTypeForProc     = coalesce (sjet.parentID,sjet.id)
    , entryStartTime       = sjee.entryStartTime
    , entryEndTime         = sjee.entryEndTime
    , orpDocID             = sjee.orpDocID
    , contSvcGroupPart     = sjet.contSvcGroupPart
    , iep                  = sjee.iep
	, standAloneNonBillSvc = sjet.standAloneNonBillSvc
from dbo.SvcJournals               as sj
join dbo.SvcJournal_Event_Entries  as sjee on  sjee.journalID = sj.id
join dbo.SvcJournal_Event_Types    as sjet on  sjet.id        = sjee.eventType

where (
        (sjee.active = 1)
   and  ((@recID is null)     or  (sjee.id    != @recID))
   and  ((sj.id = @journalID) and (sjee.pracID = @pracID))
 )

/*============================================================
 * If the event is a start, end or break 
 * peform event specific validation
 *============================================================*/  

if (
     @eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY()
  or @eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY()
  or @eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY()
)

begin

  /* TODO: Get plan type counts for all existing cont entries.  They need to be the same */

  set @numContIEP    = 0
  set @numContNonIEP = 0
  select @numContIEP    = count(journalID) from @existingEntries where ((iep = 1) and (eventTypeContSvcGroupPart is not null))
  select @numContNonIEP = count(journalID) from @existingEntries where ((iep = 0) and (eventTypeContSvcGroupPart is not null))
  if (@iep = 1) set @numContIEP    = @numContIEP    + 1
  if (@iep = 0) set @numContNonIEP = @numContNonIEP + 1
  
  if ((@numContIEP > 0) and (@numContNonIEP > 0))
  begin
    RAISERROR ('All cont mon entries must be the same plan type', 11, 1)
  end
  
  /* Get start and end times */
  
  select 
      @startOfDayTime = min(entryStartTime)
    , @endOfDayTime   = max(entryEndTime) 
  from @existingEntries
  where (    eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY()
         or  eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY()
  )
    
  /* Get num start */
  
  select @numStartOfDay = count(journalID) 
  from @existingEntries 
  where ( eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY())
    
  /* Get num end */
  
  select 
    @numEndOfDay = count(journalID) 
  from @existingEntries 
  where ( eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY())
 
  /* Start of day validate */
  
  if (@eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY())
    if (@numStartOfDay > 0) 
      RAISERROR ('You cannot have more that one entry of this type per day', 11, 1)
 
  /* End of day validate */
   
  if (@eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY())
  begin
    if (@numStartOfDay = 0)          RAISERROR ('You cannot record an end of day entry until you record the start day', 11, 1)
    if (@numEndOfDay   > 0)          RAISERROR ('You cannot have more that one end of day entry per day', 11, 1)
    if (@startOfDayTime >= @endTime) RAISERROR ('End of day time cannot be before start of day time', 11, 1)
    
    /* Test for breaks entered before or after start/end of day */
    
    select 
      @numBadBreaks = COUNT(journalID) 
    from @existingEntries 
    where (
          (eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY())
      and ((entryStartTime >= @startTime) or (entryEndTime >= @endTime))
    )
    
    if (@numBadBreaks > 0)
      RAISERROR ('You have recorded one or more breaks before the start of day or after end of day', 11, 1)    

  end

  /* Break validate */
  
  if (@eventTypeContSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY())
  begin

    if (@numStartOfDay = 0)
      RAISERROR ('You cannot record a break entry until you record the start entry', 11, 1)    
    
    if (@startTime <= @startOfDayTime) 
      RAISERROR ('You cannot record a break entry before a start of day entry', 11, 1)
  
    if (@numEndOfDay = 1)
      if (@endTime >= @endOfDayTime)   
        RAISERROR ('You cannot record a break entry after a end of day entry', 11, 1)  
  end

end

/*============================================================
 * Check for overlapping entries
 * Only applies to cases where its not a stand alone non
 * billable svc (like additional notes or RMTS docs)
 *============================================================*/  

if (@standAloneNonBillSvc = 0)
begin
  select @numOverlaps = COUNT(journalID) 
  from @existingEntries as t1
  where (((@startTime <= t1.entryEndTime) and (t1.entryStartTime <= @endTime)) and (t1.standAloneNonBillSvc = 0))
  if (@numOverlaps > 0) RAISERROR ('You cannot have overlapping or duplicate entries', 11, 1)    
end

/*###########################################################################
  # Optional validation
  ###########################################################################*/  

IF (@validateRec = 1) 
BEGIN
  
  IF (@patAbsent = 1) 
    SET @spDetails = dbo.UPDATE_DETAILS(@spDetails, 'The patient is marked as absent.', dbo.CONST_RET_WARN())
  
  SET @recordID = 0
  RETURN(0)    

END      

end

/*============================================================
 * Extract note criteria questions and answers from JSON
 *============================================================*/
 
 /* get the note criteria questions*/

select
 @noteCrit1Question = ncqd.label
from @noteCriteriaQuestionsDetails as ncqd
where ncqd.name = 'text-1'

select
 @noteCrit2Question = ncqd.label
from @noteCriteriaQuestionsDetails as ncqd
where ncqd.name = 'text-2'

select
 @noteCrit3Question = ncqd.label
from @noteCriteriaQuestionsDetails as ncqd
where ncqd.name = 'text-3'

select
 @noteCrit4Question = ncqd.label
from @noteCriteriaQuestionsDetails as ncqd
where ncqd.name = 'text-4'

select
 @noteCrit5Question = ncqd.label
from @noteCriteriaQuestionsDetails as ncqd
where ncqd.name = 'radio-group-1'

select
 @noteCrit6Question = ncqd.label
from @noteCriteriaQuestionsDetails as ncqd
where ncqd.name = 'radio-group-2'

select
 @noteCrit7Question = ncqd.label
from @noteCriteriaQuestionsDetails as ncqd
where ncqd.name = 'radio-group-3'

select
 @noteCrit8Question = ncqd.label
from @noteCriteriaQuestionsDetails as ncqd
where ncqd.name = 'number-1'

select
 @noteCrit9Question = ncqd.label
from @noteCriteriaQuestionsDetails as ncqd
where ncqd.name = 'number-2'

select
 @noteCrit10Question = ncqd.label
from @noteCriteriaQuestionsDetails as ncqd
where ncqd.name = 'number-3'

/* get the note criteria answers*/

set @noteCrit1Answer  = JSON_VALUE(@noteCriteriaAnswersJSON,'$."text-1"')
set @noteCrit2Answer  = JSON_VALUE(@noteCriteriaAnswersJSON,'$."text-2"')
set @noteCrit3Answer  = JSON_VALUE(@noteCriteriaAnswersJSON,'$."text-3"')
set @noteCrit4Answer  = JSON_VALUE(@noteCriteriaAnswersJSON,'$."text-4"')
set @noteCrit5Answer  = JSON_VALUE(@noteCriteriaAnswersJSON,'$."radio-group-1"')
set @noteCrit6Answer  = JSON_VALUE(@noteCriteriaAnswersJSON,'$."radio-group-2"')
set @noteCrit7Answer  = JSON_VALUE(@noteCriteriaAnswersJSON,'$."radio-group-3"')
set @noteCrit8Answer  = nullif(JSON_VALUE(@noteCriteriaAnswersJSON,'$."number-1"'), '')
set @noteCrit9Answer  = nullif(JSON_VALUE(@noteCriteriaAnswersJSON,'$."number-2"'), '')
set @noteCrit10Answer = nullif(JSON_VALUE(@noteCriteriaAnswersJSON,'$."number-3"'), '')
 

/*===========================================================
 * Create new journal entry
 *===========================================================*/   

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  insert into dbo.SvcJournal_Event_Entries (
      journalID
    , iep
    , pracID
    , eventType
    , entryStartTime
    , entryEndTime
    , orpDocID
    , entryNotes
    , created
    , createdBy
  )
  values (
    
      @journalID
    , @iep
    , @pracID
    , @eventType 
    , @startTime
    , @endTime
    , @orpDocID
    , @notes
    , @today          
    , @userID
  )

  set @recordID = SCOPE_IDENTITY()

  /*-------------------------------    
    * Create new record to hold
    * form builder data 
	* (for service selection)
    *------------------------------*/  
  
   insert into dbo.SvcJournal_Event_Entries_Form_Builder_Data (
      entryID
	, entryNotesFormBuilderQuestionsJSON
	, entryNotesFormBuilderAnswersJSON
  )
  values (
      @recordID
	, @svcNotesFormBuilderQuestionsJSON
	, @svcNotesFormBuilderAnswersJSON
  )

  /*-------------------------------    
    * Create new record to hold 
    * form builder data 
	* (for order note criteria)
    *------------------------------*/ 

  insert into dbo.SvcJournal_Event_Entries_Note_Criteria_Questions_Answers (
        entryID                  
	  , noteCriteriaQuestionsJSON
	  , noteCriteriaAnswersJSON  
	  , noteCrit1Question        
	  , noteCrit1Answer          
	  , noteCrit2Question        
	  , noteCrit2Answer          
	  , noteCrit3Question        
	  , noteCrit3Answer          
	  , noteCrit4Question        
	  , noteCrit4Answer          
	  , noteCrit5Question        
	  , noteCrit5Answer          
	  , noteCrit6Question        
	  , noteCrit6Answer          
	  , noteCrit7Question        
	  , noteCrit7Answer          
	  , noteCrit8Question        
	  , noteCrit8Answer          
	  , noteCrit9Question        
	  , noteCrit9Answer          
	  , noteCrit10Question       
	  , noteCrit10Answer         
  )
  values (
        @recordID                  
	  , @noteCriteriaQuestionsJSON
	  , @noteCriteriaAnswersJSON  
	  , @noteCrit1Question        
	  , @noteCrit1Answer          
	  , @noteCrit2Question        
	  , @noteCrit2Answer          
	  , @noteCrit3Question        
	  , @noteCrit3Answer          
	  , @noteCrit4Question        
	  , @noteCrit4Answer          
	  , @noteCrit5Question        
	  , @noteCrit5Answer          
	  , @noteCrit6Question        
	  , @noteCrit6Answer          
	  , @noteCrit7Question        
	  , @noteCrit7Answer          
	  , @noteCrit8Question        
	  , @noteCrit8Answer          
	  , @noteCrit9Question        
	  , @noteCrit9Answer          
	  , @noteCrit10Question       
	  , @noteCrit10Answer
  )

end

/*===========================================================
 * Edit existing journal entry
 *===========================================================*/   
 
else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  update dbo.SvcJournal_Event_Entries 
  set
      eventType      = @eventType
    , iep            = @iep
    , entryStartTime = @startTime
    , entryEndTime   = @endTime
    , orpDocID       = @orpDocID
    , entryNotes     = @notes
    , lastModified   = @today
    , lastModifiedBy = @userID
  where (
        (journalID = @journalID) 
    and (id        = @recID) 
    and (pracID    = @pracID) 
    and (active    = 1))
    
  set @recordID = @recID
  
  /*-------------------------------    
    * Manage form builder data
	* (for service selection) 
    *------------------------------*/

	declare @fbdRecID as bigint = null

	 select top 1  
	    @fbdRecID =  seefbd.id
	 from dbo.SvcJournal_Event_Entries_Form_Builder_Data as seefbd
	 where (seefbd.entryID = @recordID)
	 
	 /* Only edit existing data */

	 if (@fbdRecID is not null)
	 begin
	   /* Then edit */
       update dbo.SvcJournal_Event_Entries_Form_Builder_Data 
       set 
          entryNotesFormBuilderQuestionsJSON = @svcNotesFormBuilderQuestionsJSON
	    , entryNotesFormBuilderAnswersJSON   = @svcNotesFormBuilderAnswersJSON
       where (entryID = @recordID)
	 end
	 else
	 begin
		/* Otherwise, we do an insert */
		if (@svcNotesFormBuilderQuestionsJSON != '{}')
		begin
			insert into dbo.SvcJournal_Event_Entries_Form_Builder_Data (
			      entryID
				, entryNotesFormBuilderQuestionsJSON
				, entryNotesFormBuilderAnswersJSON
			 )
			 values (
			      @recordID
				, @svcNotesFormBuilderQuestionsJSON
				, @svcNotesFormBuilderAnswersJSON
			 )
		end
	 end

  /*-------------------------------    
    * Manage form builder data
	* (for note criteria) 
    *------------------------------*/
	   
  declare @fbdRecIDForOrder as bigint = null

  select top 1  
     @fbdRecIDForOrder =  seencqa.id
  from dbo.SvcJournal_Event_Entries_Note_Criteria_Questions_Answers as seencqa
  where (seencqa.entryID = @recordID)
  
  /* Only edit existing data */
  
  if (@fbdRecIDForOrder is not null)
  begin
    /* Then edit */
       update dbo.SvcJournal_Event_Entries_Note_Criteria_Questions_Answers 
       set                 
		    noteCriteriaQuestionsJSON = @noteCriteriaQuestionsJSON
		  , noteCriteriaAnswersJSON   = @noteCriteriaAnswersJSON 
		  , noteCrit1Question         = @noteCrit1Question       
		  , noteCrit1Answer           = @noteCrit1Answer         
		  , noteCrit2Question         = @noteCrit2Question       
		  , noteCrit2Answer           = @noteCrit2Answer         
		  , noteCrit3Question         = @noteCrit3Question       
		  , noteCrit3Answer           = @noteCrit3Answer         
		  , noteCrit4Question         = @noteCrit4Question       
		  , noteCrit4Answer           = @noteCrit4Answer         
		  , noteCrit5Question         = @noteCrit5Question       
		  , noteCrit5Answer           = @noteCrit5Answer         
		  , noteCrit6Question         = @noteCrit6Question       
		  , noteCrit6Answer           = @noteCrit6Answer         
		  , noteCrit7Question         = @noteCrit7Question       
		  , noteCrit7Answer           = @noteCrit7Answer         
		  , noteCrit8Question         = @noteCrit8Question       
		  , noteCrit8Answer           = @noteCrit8Answer         
		  , noteCrit9Question         = @noteCrit9Question       
		  , noteCrit9Answer           = @noteCrit9Answer         
		  , noteCrit10Question        = @noteCrit10Question      
		  , noteCrit10Answer          = @noteCrit10Answer        
       where (entryID = @recordID)
  end
  else
	 begin
		/* Otherwise, we do an insert */
		if (@noteCriteriaQuestionsJSON != '{}')
		begin
			insert into dbo.SvcJournal_Event_Entries_Note_Criteria_Questions_Answers (
		        entryID                  
			  , noteCriteriaQuestionsJSON
			  , noteCriteriaAnswersJSON  
			  , noteCrit1Question        
			  , noteCrit1Answer          
			  , noteCrit2Question        
			  , noteCrit2Answer          
			  , noteCrit3Question        
			  , noteCrit3Answer          
			  , noteCrit4Question        
			  , noteCrit4Answer          
			  , noteCrit5Question        
			  , noteCrit5Answer          
			  , noteCrit6Question        
			  , noteCrit6Answer          
			  , noteCrit7Question        
			  , noteCrit7Answer          
			  , noteCrit8Question        
			  , noteCrit8Answer          
			  , noteCrit9Question        
			  , noteCrit9Answer          
			  , noteCrit10Question       
			  , noteCrit10Answer         
		)
		values (
		        @recordID                  
			  , @noteCriteriaQuestionsJSON
			  , @noteCriteriaAnswersJSON  
			  , @noteCrit1Question        
			  , @noteCrit1Answer          
			  , @noteCrit2Question        
			  , @noteCrit2Answer          
			  , @noteCrit3Question        
			  , @noteCrit3Answer          
			  , @noteCrit4Question        
			  , @noteCrit4Answer          
			  , @noteCrit5Question        
			  , @noteCrit5Answer          
			  , @noteCrit6Question        
			  , @noteCrit6Answer          
			  , @noteCrit7Question        
			  , @noteCrit7Answer          
			  , @noteCrit8Question        
			  , @noteCrit8Answer          
			  , @noteCrit9Question        
			  , @noteCrit9Answer          
			  , @noteCrit10Question       
			  , @noteCrit10Answer
		)
		end
	 end 

end

/*===========================================================
 * "Delete" existing journal entry
 *===========================================================*/   

/* TODO: Remove when we can since we created a dedicated sproc to handle delete */

else if (@saveType = dbo.CONST_SAVE_TYPE_DELETE())
begin

  update dbo.SvcJournal_Event_Entries 
  set
      active         = 0
    , lastModified   = @today
    , lastModifiedBy = @userID
  where (
        (journalID = @journalID) 
    and (id        = @recID) 
    and (pracID    = @pracID) 
    and (active    = 1))

end


/*============================================================
 * All done get out
 *============================================================*/  
    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
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
         
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_ENTRY_SAVE_CORE] TO [webuser]
GO

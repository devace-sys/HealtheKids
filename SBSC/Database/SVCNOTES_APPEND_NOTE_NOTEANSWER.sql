USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_APPEND_NOTE_NOTEANSWER') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_APPEND_NOTE_NOTEANSWER
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_APPEND_NOTE_NOTEANSWER ( 
  @userID                               bigint,
  @userGroup                            int,
  @userRank                             int,
  @noteTypeID                           bigint,
  @clientID		                    bigint,  
  @pracID                               bigint,
  @patID                                bigint,
  @noteID                               bigint,
  @questionID                           bigint,    
  @answerOrder                          bigint,
  @answerID                             bigint,	  
  @answerValue                          varchar(max),
  @answerMarked                         bit,
  @answerSource                         varchar(50),
  @headerID	                         bigint,
  @headerNoteAnswerID 				bigint,
  @originalFileName                     varchar(8000),
  @savedFileName                        varchar(8000),
  @fileSize                             bigint,
  @fileMimeType                         varchar(8000),
  @answerInputType                      bigint,
  @today                                datetime
)
AS
BEGIN

/***************************************************************************    
 * SVCNOTES_APPEND_NOTE_NOTEANSWER */    
/**    
 * Adds answers for a given svc note.  Manages bookmarks.  Adds file records.
 *
 * Note: This is designed to be called from SVC_NOTES_APPEND_NOTE_NOTEANSWERS
 *    
 * @param   userID                       The userid of who saved the record    
 * @param   userGroup                    Users group    
 * @param   userRank                     User rank
 * @param   clientID                     Client ID
 * @param   pracID                       Practitioner ID
 * @param   patID                        Patient ID
 * @param   noteID                       Record id of note
 * @param   questionID                   Question id
 * @param   answerOrder                       
 * @param   answerID                          
 * @param   answerValue 
 * @param   answerMarked
 * @param   answerSource
 * @param   headerID	 
 * @param   headerNoteAnswer
 * @param   originalFileName             If the answer is a file this is 
 *                                       the original filename that was uploaded
 * @param   savedFileName                If the answer is a file this is the
 *                                       filename that was generated for it
 ***************************************************************************/     

/*###########################################################################
  # Init 
  ###########################################################################*/  
  
declare @recCount            as bigint = 0
declare @svcNoteNoteAnswerID as bigint = null
declare @fileUploadID        as bigint = null

/*###########################################################################
  # Save new answer
  ###########################################################################*/  

/*============================================================
 * Check for duplicate answer
 *============================================================*/  	          

select 
  @recCount = count(NoteID) 
from SvcNote_Note_Answers 
where 
  ((NoteID                   = @noteID)
    and (questionID          = @questionID)
    and (answerID	         = @answerID)
    and (answerValue         = @answerValue)
    and (OriginatingAnswerID = @headerID)
    and (Parent_NoteAnswerID = @headerNoteAnswerID))

if (@recCount != 0) return(0) 

/*============================================================
 * Insert new answer
 *============================================================*/  	
  
insert into SvcNote_Note_Answers (  
    SelectedOrder
  , NoteID
  , QuestionID 
  , AnswerID	  
  , AnswerValue
  , AnswerMarked
  , AnswerSource
  , OriginatingAnswerID
  , Parent_NoteAnswerID
)
values (
    @answerOrder
  , @noteID 
  , @questionID
  , @answerID
  , @answerValue
  , @answerMarked
  , @answerSource
  , @headerID
  , @headerNoteAnswerID
)

set @svcNoteNoteAnswerID = SCOPE_IDENTITY() 

/*###########################################################################
  # Save new file if applicable
  ###########################################################################*/  

if (@answerInputType = 2)
begin

  declare @noteTypeName as varchar(1000)

  select @noteTypeName = NoteTypeName from SvcNote_NoteType where id = @noteTypeID

  exec FILE_UPLOAD_SAVE   @userID
                        , @userGroup
                        , @userRank
                        , @clientID
                        , @pracID
                        , null
                        , @patID
                        , @originalFileName
                        , @savedFileName
                        , @userID
                        , null
                        , 3
                        , 100
                        , @noteTypeName
                        , @fileSize          
                        , @fileMimeType      
                        , @fileUploadID output

  /*============================================================
   * Update SvcNote Note Answers Files
   *============================================================*/  	

  insert into SvcNote_Note_Answers_Files (
      noteID
    , questionID
    , answerID	  
    , answerValue
    , headerID
    , headerNoteAnswerID
    , svcNoteNoteAnswerID
    , fileUploadID
  )
  values(
      @noteID 
    , @questionID
    , @answerID
    , @answerValue
    , @headerID
    , @headerNoteAnswerID
    , @svcNoteNoteAnswerID
    , @fileUploadID
  )

end

/*###########################################################################
  # If this answer is a new custom answer, add it to the answer selections
  # tables and update the answer we just inserted with the new answerID
  # (a temporary id is passed in that will be replaced with this new value)
  # We will also handle the bookmarking inside 
  ###########################################################################*/       

if (@answerSource = dbo.CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_NEW())
begin
  exec SVCNOTES_CREATE_CUSTOM_ANSWER @noteID, null, @QuestionID, @pracID, @answerValue, @svcNoteNoteAnswerID, @answerMarked
end

/*###########################################################################
  # Manage bookmarks
  ###########################################################################*/       

if (@answerMarked = 1)
begin

  /*============================================================
   * User bookmarked answer from the 'all' list so we want to
   * add the answer to their favorites
   *============================================================*/
      
   if (@answerSource = dbo.CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_ALL()) 
   begin
     exec SVCNOTES_CREATE_PRAC_FAV_ANSWER @noteID, @answerID, @pracID
   end

  /*============================================================
   * User removed a bookmark from their favorites so we need to
   * remove it from their favorites
   *============================================================*/
            
  else if (@answerSource = dbo.CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_FAV())
  begin
    update SvcNote_Answers set Active = 0 where id = @answerID
  end
  
  /*============================================================
   * Answer marked but source unknown
   *============================================================*/

  else
  
  begin
    return (0)
  end
end

/*###########################################################################
  # Done
  ###########################################################################*/       

return (0)  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[SVCNOTES_APPEND_NOTE_NOTEANSWER] TO [webuser]

GO
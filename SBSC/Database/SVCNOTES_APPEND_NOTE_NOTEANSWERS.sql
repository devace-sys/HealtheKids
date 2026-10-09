USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_APPEND_NOTE_NOTEANSWERS') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_APPEND_NOTE_NOTEANSWERS
GO


IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'SvcNoteAnswerSubmittedTblType')
DROP TYPE SvcNoteAnswerSubmittedTblType
GO

/*-------------------------------
 * Object Definitions
 *------------------------------*/
 
CREATE TYPE SvcNoteAnswerSubmittedTblType AS TABLE
( 
  noteID                      bigint,
  questionID                  bigint,
  headerID                    bigint,
  headerNoteAnswerID          bigint,
  answerID                    bigint,	  
  answerValue                 varchar(max),
  answerMarked                bit,
  answerSource                varchar(50),
  answerSelected              bit,
  answerOrder                 bigint
)

GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

 

CREATE PROCEDURE dbo.SVCNOTES_APPEND_NOTE_NOTEANSWERS 
(
  @userID                 bigint,
  @userGroup              int,
  @userRank               int,
  @clientID		      bigint,  
  @pracID                 int,
  @noteID                 bigint,
  @questionID             bigint,
  @originalFileName       varchar(8000),
  @savedFileName          varchar(8000),
  @fileSize               bigint,
  @fileMimeType           varchar(8000),
  @svcNoteAnswersSubmitted SvcNoteAnswerSubmittedTblType READONLY
)
AS
BEGIN

/***************************************************************************    
 * SVCNOTES_APPEND_NOTE_NOTEANSWERS */    
/**    
 * Adds answers for a given service note question
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank
 * @param   clientID                     Client ID
 * @param   pracID                       Practitioner ID
 * @param   noteID                       Record id of note
 * @param   questionID                   Question id
 * @param   originalFileName             If the answer is a file this is 
 *                                       the original filename that was uploaded
 * @param   savedFileName                If the answer is a file this is the
 *                                       filename that was generated for it
 * @param   svcNoteAnswersSubmitted      Answers submitted
 * @returns recordID                     New record id of the note
 ***************************************************************************/    

/*###########################################################################
  # Init
  ###########################################################################*/    

declare @noteTypeID        as bigint    = 0
declare @numAllowedAnswers as bigint    = 0
declare @complete          as bit       = 0
declare @completedOn       as datetime  = null
declare @today             as datetime  = getdate()
declare @numSubmitted      as int       = 0
declare @answerInputType   as bigint    = 0
declare @patID             as bigint    = null
declare @TranOpen          as bit       = 0
declare @optionalQuestion  as bit		= 0

BEGIN TRY    

/*###########################################################################
  # Make sure note exists and grab some data from it
  ###########################################################################*/    

set @noteTypeID = null

select 
  @noteTypeID   = NoteTypeID,
  @patID        = patID
from 
  SvcNote_Notes   
where 
      id     = @noteID  
  and pracID = @pracID  
   
if (@noteTypeID is null) return(0)

/*###########################################################################
  # Make sure question exists and grab some data from it
  ###########################################################################*/    

set @numAllowedAnswers = -1

select
    @numAllowedAnswers = isnull(NumAllowedAnswers,0),
    @answerInputType   = AnswerInputType,
    @optionalQuestion  = QuestionisOptional
  from 
    SvcNote_Questions 
  where 
        NoteTypeID = @noteTypeID
    and id         = @questionID
    
--if (@numAllowedAnswers < 0) return(0)
--TODO: This does not seem to work, fix


/*###########################################################################
  # Import answers submitted
  ###########################################################################*/  

/*============================================================
 * Create table to import answers into getting rid of some 
 * duplicates and creating a unique sequential id at the same
 * time that we will use for the answer selected order
 *============================================================*/  	

 declare @answersSubmittedImport as table
 (   
   id                          int IDENTITY(1,1),
   headerID                    bigint,
   headerNoteAnswerID 	        bigint,
   answerID                    bigint,	  
   answerValue                 varchar(max),
   answerMarked                bit,
   answerSource                varchar(50)     
 )

/*============================================================
 * Pull in answers submitted
 * Replace appropriate columns with null
 *============================================================*/  	

insert into @answersSubmittedImport (headerID, headerNoteAnswerID, answerID, answerValue, answerMarked, answerSource)

select distinct *
from
(
  select 
      case when headerID            = 0 then null else headerID           end as headerID
    , case when headerNoteAnswerID  = 0 then null else headerNoteAnswerID end as headerNoteAnswerID 
    , answerID
    , answerValue
    , answerMarked
    , answerSource      
  from @svcNoteAnswersSubmitted     
) as snas

/*============================================================
 * If the input type is for a file, we will not have any answers
 * submitted by the user but we do want to save a placeholder
 * answer.  Look up the appropriate answer
 *============================================================*/  	
  
if (@answerInputType = 2)
begin
  insert into @answersSubmittedImport (headerID, headerNoteAnswerID, answerID, answerValue, answerMarked, answerSource)

  select distinct *
  from
  (
    select 
      case when headerID            = 0 then null else sna.headerID           end as headerID
    , case when headerNoteAnswerID  = 0 then null else sna.headerNoteAnswerID end as headerNoteAnswerID 
    , sna.answerID
    , sna.answerValue
    , sna.answerMarked
    , sna.answerSource      
    from SvcNote_Questions as snq 
    join SVCNOTES_NOTE_QUESTION_ANSWER_SELECTIONS_VIEW (@userID,@userGroup,@userRank, @clientID, @pracID, @noteID, @questionID, null, null, null) as sna on sna.QuestionID = snq.id
    where 
      snq.id                  = @questionID 
      and snq.AnswerInputType = @answerInputType 
    ) as snas
end

/*============================================================
 * 
 * If no answers were provided in the selection AND the question is skippable,
 * populate the selection with the appropriate skippable answer for this question
 *
 *============================================================*/  

if @optionalQuestion = 1 and (select COUNT(*) from @answersSubmittedImport) = 0
BEGIN

  insert into @answersSubmittedImport (headerID, headerNoteAnswerID, answerID, answerValue, answerMarked, answerSource)

  select distinct *
  from
  (
    select 
      case when headerID            = 0 then null else sna.headerID           end as headerID
    , case when headerNoteAnswerID  = 0 then null else sna.headerNoteAnswerID end as headerNoteAnswerID 
    , sna.answerID
    , sna.answerValue
    , sna.answerMarked
    , sna.answerSource      
    from SvcNote_Questions as snq 
    join SVCNOTES_NOTE_QUESTION_ANSWER_SELECTIONS_VIEW (@userID,@userGroup,@userRank, @clientID, @pracID, @noteID, @questionID, null, null, null) as sna on sna.QuestionID = snq.id
    join SvcNote_Answers sna_skippable on sna_skippable.id = sna.answerID and sna_skippable.UseAnswerForQuestionSkip = 1
    where 
      snq.id                  = @questionID 
      and snq.AnswerInputType = @answerInputType 
    ) as snas

END


    
/*###########################################################################
  # Get and check answer counts
  ###########################################################################*/  

/*============================================================
 * Count the answers imported
 *============================================================*/  	

set @numSubmitted = 0
select @numSubmitted = count(id) from @answersSubmittedImport
  
/*============================================================
 * If there is nothing to insert, get out
 *============================================================*/  	

if (@numSubmitted = 0) return(0)  
  
/*============================================================
 * If only one answer is allowed but we have more that one
 * provided get out
 *============================================================*/  	

--if ((@numAllowedAnswers = 1) and (@numSubmitted > 1)) return(0)

BEGIN TRANSACTION    
SET @TranOpen  = 1 

/*###########################################################################
  # Remove previously answered decsendant answers
  ###########################################################################*/  

/*============================================================
 * Delete answers for this question as well as later answers
 * for the given note
 *============================================================*/  
 	
declare @index as bigint = 1
while (@index <= @numSubmitted)
begin	
  declare @delete_header       as bigint
  declare @delete_answerheader as bigint
  select 
      @delete_header       = asi.headerID
    , @delete_answerheader = asi.headerNoteAnswerID 
  from @answersSubmittedImport asi
  where asi.id = @index
  exec svcnotes_delete_noteanswers @noteid, @questionid, @delete_header, @delete_answerheader
  set @index = @index +1	
end

/*###########################################################################
  # Save answer(s), save file references, and manage bookmarks (part of save)
  ###########################################################################*/  
 
declare @curSelected as int = 1
 
while (@curSelected <= @numSubmitted)
begin
  
  /*-------------------------------
   * Init holding variables
   *------------------------------*/        
    
  declare @headerID           as bigint       = null
  declare @headerNoteAnswerID as bigint       = null
  declare @answerID           as bigint       = null
  declare @answerValue        as varchar(max) = null
  declare @answerMarked       as bit          = null
  declare @answerSource       as varchar(50)  = null
    
  /*-------------------------------
   * Load answer into holding vars
   *------------------------------*/        

  select top 1   
      @curSelected                  = id 
    , @answerID                     = answerID
    , @answerValue                  = answerValue
    , @answerMarked                 = answerMarked
    , @answerSource                 = answerSource
    , @headerID                     = headerID
    , @headerNoteAnswerID		 = headerNoteAnswerID
      
  from  @answersSubmittedImport where id = @curSelected
    
  /*-------------------------------
   * Save answer
   *------------------------------*/        

  exec SVCNOTES_APPEND_NOTE_NOTEANSWER   @userID          
                                       , @userGroup        
                                       , @userRank
                                       , @noteTypeID
                                       , @clientID	
                                       , @pracID
                                       , @patID       
                                       , @noteID       
                                       , @questionID        
                                       , @curSelected
                                       , @answerID
                                       , @answerValue
                                       , @answerMarked
                                       , @answerSource
                                       , @headerID
                                       , @headerNoteAnswerID
                                       , @originalFileName
                                       , @savedFileName
                                       , @fileSize
                                       , @fileMimeType
                                       , @answerInputType
                                       , @today
   
 

  /*-------------------------------
   * Get id of next answer
   *------------------------------*/      

  set @curSelected = @curSelected + 1                

end
     
/*###########################################################################
  # Update note record
  ###########################################################################*/    

/*============================================================
 * Retain given questionID, this will become the last question
 * id answered
 *============================================================*/  
 	
declare @lastQuestionIDAnswered as bigint 
set @lastQuestionIDAnswered = @questionID
        
/*============================================================
 * Check to see if the note is completed
 *============================================================*/  

declare @nextQuestionID as bigint = null  
set @nextQuestionID = dbo.SVCNOTES_NOTE_QUESTION_GET_CURRENT_ID(null,null,null,NULL,null,@noteid)

/*-------------------------------
 * Note is complete
 *------------------------------*/  

if (@nextQuestionID is null) 
begin
  set @complete    = 1 
  set @completedOn = @today
end

/*-------------------------------
 * Note is incomplete
 *------------------------------*/  

else
begin    
  set @complete    = 0
  set @completedOn = null
end

/*============================================================
 * Update Service note record
 *============================================================*/  

update SvcNote_Notes 
set   
   Completed              = @complete
  ,CompletionDate         = @completedOn
  ,lastQuestionAnsweredID = @lastQuestionIDAnswered
  ,LastUpdated            = @today
  ,LastUpdatedBy          = @userID    
where id = @noteID

/*============================================================
 * Update file upload records if the servive note is complete
 *============================================================*/  

if (@complete = 1)
begin

  declare @numFiles  as int = 0
  declare @curFile   as int = 1  
  declare @uploadIDs as table (idx bigint identity(1,1), uploadID bigint)
  
  insert into @uploadIDs 
  select fileUploadID as uploadID from SvcNote_Note_Answers_Files where noteID = @noteID 
  
  select @numFiles = COUNT(idx) from @uploadIDs
  
  declare @statusCode as bigint = dbo.CONST_FILE_UPLOAD_STATUS_FORM_COMPLETE()
  declare @uploadID   as bigint = null
  declare @statusID   as bigint = null

  while (@curFile <= @numFiles)
  begin
    
    set @uploadID = null
        
    select top 1 @uploadID = uploadID from @uploadIDs where idx = @curFile
    
    exec dbo.FILE_UPLOAD_SET_STATUS 
        @uploadID
      , @completedOn
      , @userID
      , @statusCode
      , null
      , null
      , null
      , @statusID output
    
    set @curFile = @curFile + 1
  
  end
  
end

/*###########################################################################
  # Done
  ###########################################################################*/       

IF (@TranOpen = 1) COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  -- Error or raise error with severity 11 to 19 will be caught here    
    
  /*-------------------------------    
   * Cancel any pending    
   * transactions  
   *------------------------------*/    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  /*-------------------------------    
   * Identify error
   *------------------------------*/    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage 
       
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH
	
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON TYPE::SvcNoteAnswerSubmittedTblType TO [webuser]

GRANT EXECUTE ON  [dbo].[SVCNOTES_APPEND_NOTE_NOTEANSWERS] TO [webuser]

GO
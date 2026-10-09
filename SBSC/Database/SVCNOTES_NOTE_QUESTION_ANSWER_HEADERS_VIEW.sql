USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_QUESTION_ANSWER_HEADERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTES_NOTE_QUESTION_ANSWER_HEADERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_QUESTION_ANSWER_HEADERS_VIEW ( 
  @userID         bigint,
  @userGroup      int,   
  @userRank       int,
  @clientID	   bigint,
  @pracID		   bigint,
  @noteID         bigint, 
  @questionID     bigint) 

RETURNS @headerView TABLE  
(
	 [noteID]						bigint
	,[questionID]					bigint
	,[questionText]					varchar(max)
	,[questionNumAllowedAnswers]	bigint
	,[questionIsOptional]			bit
	,[answerUserFavoritesAllowed]	bit
	,[answerUserEnteredAllowed]		bit
	,[headerID]						bigint
	,[headerNoteAnswerID]			bigint
	,[headerText]					varchar(max)
	,[headerOrder]					bigint
	
)

BEGIN
  with cte_base
  as
  (
  select 
      NoteID                                   as  [noteID]
    , QuestionID                               as  [questionID]
    , snq.QuestionText                         as  [questionText]
    , isnull(snq.NumAllowedAnswers,0)          as  [questionNumAllowedAnswers]
    , snq.QuestionisOptional                   as  [questionIsOptional]
    , snq.AnswersUserFavoritesAllowed          as  [answerUserFavoritesAllowed]
    , snq.AnswersUserEnteredAllowed            as  [answerUserEnteredAllowed]
    , isnull(ClosureHeaderAnswerID,0)          as  [headerID]
    , isnull(HeaderNoteAnswerID,0)			  as   [headerNoteAnswerID]
    , isnull(AnswerHeaderText,'Select Answer') as  [headerText]
  from SVCNOTES_NOTE_QUESTION_ANSWERS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @noteID, @questionID, null) as snqav
  join SvcNote_Questions as snq on snq.id = snqav.QuestionID
  )
  ,
  cte_grouping
  as
  (
  select distinct * from cte_base
  )
  ,
  cte_ordering
  as
  (
  select *, row_number() over (order by [headerID]) as [headerOrder] from cte_grouping
  ) 
  insert into @headerView
  select 

  
[noteID]
,[questionID]
,[questionText]
,[questionNumAllowedAnswers]
,[questionIsOptional]
,[answerUserFavoritesAllowed]
,[answerUserEnteredAllowed]
,[headerID]
,[headerNoteAnswerID]
,[headerText]
,[headerOrder]
  
  from cte_ordering
  OPTION (OPTIMIZE FOR UNKNOWN)
  
  RETURN
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].SVCNOTES_NOTE_QUESTION_ANSWER_HEADERS_VIEW TO [webuser]
GO
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_QUESTION_SELECTIONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.[SVCNOTES_NOTE_QUESTION_SELECTIONS_VIEW]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_QUESTION_SELECTIONS_VIEW ( 
  @userID         bigint,
  @userGroup      int,   
  @userRank       int,
  @clientID	   bigint,
  @pracID		   bigint,
  @noteID         bigint, 
  @questionID     bigint) 

RETURNS TABLE AS RETURN(
  with cte_base
  as
  (
  
  select 
      @noteID                         as  [noteID]
    , id                              as  [questionID]
    , QuestionText                    as  [questionText]
    , isnull(NumAllowedAnswers,0)     as  [questionNumAllowedAnswers]
    , QuestionisOptional              as  [questionIsOptional]
    , AnswersUserFavoritesAllowed     as  [answerUserFavoritesAllowed]
    , AnswersUserEnteredAllowed       as  [answerUserEnteredAllowed]
    , QuestionSequence                as  [questionOrder]
    , AnswerInputType                 as  [answerInputType]
    
  from SVCNOTES_NOTE_QUESTIONS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @noteID, @questionID)
   
  )
  ,
  cte_ordering
  as
  (
  select * from cte_base
  ) 
  select * from cte_ordering
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCNOTES_NOTE_QUESTION_SELECTIONS_VIEW] TO [webuser]
GO
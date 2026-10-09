USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_QUESTION_ANSWER_SELECTIONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTES_NOTE_QUESTION_ANSWER_SELECTIONS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_QUESTION_ANSWER_SELECTIONS_VIEW ( 
  @userID                  bigint,
  @userGroup               int,   
  @userRank                int,
  @clientID	            bigint,
  @pracID		            bigint,
  @noteID                  bigint, 
  @questionID              bigint,
  @answerSource            varchar(50),
  @headerID                bigint,
  @headerNoteAnswerID      bigint) 


RETURNS TABLE AS RETURN(

/***************************************************************************    
 * SVCNOTES_NOTE_QUESTION_ANSWER_SELECTIONS_VIEW */    
/**    
 * Shows possible answers that the user can select
 *    
 * @param   userID            Users ID
 * @param   userGroup         Users group    
 * @param   userRank          User rank
 * @param   clientID          Client ID
 * @param   pracID            Practitioner ID
 * @param   noteID            Record id of note
 * @param   questionID        Question id
 * @param   answerSource      What source to pull from
 * @param   headerReferenceID Reference id for the header
 * @returns table
 ***************************************************************************/     

with cte_base
as
(
  select  
      NoteID                                    as  [noteID]
    , QuestionID                                as  [questionID]
    , isnull(ClosureHeaderAnswerID,0)           as  [headerID]
    , isnull(HeaderNoteAnswerID,0)			   as  [headerNoteAnswerID]
    , AnswerID                                  as  [answerID]
    , AnswerText                                as  [answerValue]
    , [answerMarked]   = convert(bit,(case when IsPracFavorite = 1 then 1 else 0 end))
    , [answerSource]   = case when IsPracFavorite = 1 then dbo.CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_FAV() else dbo.CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_ALL() end
    , [answerSelected] = convert(bit,(case when StoredAnswerID is null then 0 else 1 end))
    , isnull(AnswerSequence,0)                  as  [answerOrder]
   
  from SVCNOTES_NOTE_QUESTION_ANSWERS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @noteID, @questionID, null)
)
,
cte_selections_filter
as
(
  select 
  * 
  from cte_base 
  where 
    ((1=1) 
    and ((@answerSource is null) or (answerSource       = @answerSource))
    and ((@headerID     is null) or (headerID           = @headerID)))
    and ((@headerID     is null) or (headerNoteAnswerID = @headerNoteAnswerID))
)
,
cte_output
as
(
  select top (dbo.CONST_MAX_ROWS()) * from cte_selections_filter
  order by answerOrder, [answerValue]
)

select * from cte_output

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCNOTES_NOTE_QUESTION_ANSWER_SELECTIONS_VIEW] TO [webuser]
GO
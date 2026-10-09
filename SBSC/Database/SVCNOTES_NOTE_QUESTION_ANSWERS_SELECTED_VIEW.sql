USE SPEDMON
GO


-- Cleanup
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_SELECTED_ANSWERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.[SVCNOTES_NOTE_SELECTED_ANSWERS_VIEW]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_QUESTION_ANSWERS_SELECTED_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.[SVCNOTES_NOTE_QUESTION_ANSWERS_SELECTED_VIEW]
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_QUESTION_ANSWERS_SELECTED_VIEW ( 
  @userID              INT,    
  @userGroup           INT,    
  @userRank            INT,
  @clientID	        bigint,
  @pracID		        bigint,
  @noteID              bigint, 
  @questionID          bigint,
  @answerSource        varchar(50),
  @headerID            bigint,
  @headerNoteAnswerID  bigint) 

RETURNS TABLE AS RETURN(

/***************************************************************************    
 * SVCNOTES_NOTE_QUESTION_ANSWERS_SELECTED_VIEW */    
/**    
 * Shows the answers that the user selected
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

with 
cte_selections_base
as
(
 select 
      NoteID                                 as [noteID]
    , QuestionID                             as [questionID]
    , isnull(OriginatingAnswerID,0)          as [headerID]
    , isnull(Parent_NoteAnswerID,0)		as [headerNoteAnswerID]
    , AnswerID							as [answerID] 	  
    , AnswerValue						as [answerValue]
    , CONVERT(bit,AnswerMarked)			as [answerMarked]
    , AnswerSource						as [answerSource]
    , convert(bit,1)                         as [answerSelected]
    , SelectedOrder                          as [answerOrder]

    
 from SvcNote_Note_Answers    
  where 
        (NoteID     = @noteID)
    and (QuestionID = @questionID)
)
,
cte_selections_filter
as
(
  select * 
  from cte_selections_base 
  where ((1=1) 
  and ((@headerID     is null) or (headerID           = @headerID)))
  and ((@headerID     is null) or (headerNoteAnswerID = @headerNoteAnswerID))
)
,
cte_output
as
(
  select top (dbo.CONST_MAX_ROWS()) * from cte_selections_filter
  order by answerOrder
)

select * from cte_output

/*  select 
      id                  as [selectionIdx]
    , QuestionID          as [selectionFrom]
    , OriginatingAnswerID as [selectionFor]
    , answerValue         as [selectionName]
    , AnswerID            as [selectionValue]
    , AnswerMarked        as [selectionMarked]
    , AnswerSource        as [selectionSource]
    , AnswerInputId       as [selectionInputId]
  from 
    SvcNote_Note_Answers    
  where 
        (NoteID = @noteID)
    and QuestionID = @questionID
*/

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCNOTES_NOTE_QUESTION_ANSWERS_SELECTED_VIEW] TO [webuser]
GO
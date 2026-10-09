USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_QUESTION_GET_CURRENT_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTES_NOTE_QUESTION_GET_CURRENT_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_QUESTION_GET_CURRENT_ID

( @userID         bigint,
  @userGroup      INT,   
  @userRank       INT,
  @clientID		  bigint,
  @pracID		  bigint,
  @NoteID         bigint) 

RETURNS BIGINT AS 

BEGIN
	/* From available questions, determine which question should be displayed for answering. */
	/* If a question has (enough) answers, it shouldn't be displayed */
	/* Sort by QuestionSequence and pick the top 1 Q. */

declare @returnQuestionID bigint
	
	set @returnQuestionID =
	(
	select top 1
		Accessible_Questions.id
	
	from SVCNOTES_NOTE_QUESTIONS_VIEW(@userid, @usergroup,@userrank,NULL,@pracid,@noteID,NULL) Accessible_Questions
	
	cross apply (select AnswerHeaderID as headerID, HeaderNoteAnswerID, COUNT(*) as Answerable from SVCNOTES_NOTE_QUESTION_ANSWERS_VIEW(@userid, @usergroup, @userrank, @clientID, @pracID, @noteID, Accessible_Questions.id,null) group by AnswerHeaderID,HeaderNoteAnswerID) headerview_AnswerCount
				
	cross apply (select COUNT(*) answers_provided from SvcNote_Note_Answers snna 
			where snna.noteID = @noteID 
			and snna.questionID = Accessible_Questions.id 
			and (snna.OriginatingAnswerID = headerview_AnswerCount.[headerID] or headerview_AnswerCount.[headerID] is null )
			and (snna.Parent_NoteAnswerID = headerview_AnswerCount.headerNoteAnswerID or headerview_AnswerCount.headerNoteAnswerID is null )
			)answercount

	where 
		/* we want to only look at questions for the notetype of this note */
		NoteTypeID = (select top 1 NotetypeID from svcnote_notes where id = @noteID)
		
		and 
		
		((ISNULL(NumAllowedAnswers,0) = 0 and answers_provided = 0) or ((ISNULL(NumAllowedAnswers,0) <> 0 and NumAllowedAnswers <> answers_provided)))
		
		and headerview_AnswerCount.answerable <> 0
		
    order by Accessible_Questions.QuestionSequence
	)
	return @returnQuestionID
END
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_CLOSURE_QUESTION_ANSWER_PROGRESSION') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_QUESTION_ANSWER_PROGRESSION
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_QUESTION_ANSWER_PROGRESSION 
(
	@QuestionAncestor bigint,
	@QuestionDescendant bigint
)

/***************************************** 
	In a lot of cases, all of the answers to one question will link to all the answers in another question
		* This is for 'followup' answer tracking rather than question-answer-question progression
******************************************/

AS
BEGIN

	/* Update the default designator for next question, since all the answers to this question are pointing at the next question */

	update SvcNote_Questions
	set DefaultNextQuestionID = @QuestionDescendant
	where id = @QuestionAncestor

	declare @ancestorAnswers bigint_tabletype, @descendantAnswers bigint_tabletype
	
	insert into @ancestorAnswers
		select id as parID from SvcNote_Answers where QuestionID = @QuestionAncestor
		
	insert into @descendantAnswers
		select id as chiID from SvcNote_Answers where QuestionID = @QuestionDescendant
	

	exec SVCNOTES_CREATE_CLOSURE_ANSWER_SUBSET @ancestorAnswers, @descendantAnswers

END
GO
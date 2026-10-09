
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_CLOSURE_QUESTION_PROGRESSION') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_QUESTION_PROGRESSION
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_QUESTION_PROGRESSION 
(
	@QuestionAncestor bigint,
	@QuestionDescendant bigint
)

/***************************************** 
	The default for flow in most question->question svcnote transitions is in a specific order 
		- all of the answer options for Question 1 will point to Question 2, for instance. 
		Cases where an answer will cause a question to be skipped are relatively less frequent.
		
		This stored procedure links all the answers for the Ancestor Question to have the Descendant question as their child in the closure table.
******************************************/

AS
BEGIN

	declare @ancestorAnswers bigint_tabletype
	insert into @ancestorAnswers
		select id from SvcNote_Answers where QuestionID = @QuestionAncestor
		
	exec SVCNOTES_CREATE_CLOSURE_QUESTION_SUBSET @ancestorAnswers, @QuestionDescendant
	
	/* Since all of the answers for this question point to the descendant question, update the nextquestion default for this question so later answers can point the same way */
	
	update SvcNote_Questions set DefaultNextQuestionID = @QuestionDescendant where id = @QuestionAncestor

END
GO
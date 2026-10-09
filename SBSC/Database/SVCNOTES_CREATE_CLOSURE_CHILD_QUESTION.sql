
/* Basic sproc to create new answers. Called from other stored procedures to produce cloned 'favorites' or multi=use practitioner custom answers */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_CLOSURE_CHILD_QUESTION') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_CHILD_QUESTION
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_CHILD_QUESTION 
(
	@answerParentID bigint,
	@questionChildID bigint
)

/***************************************** 
	Create closure records for a answer-question parent-child relationship 
	This is used to determine which questions become available as previous questions are answered.
******************************************/

AS
BEGIN

	declare @ParentUID uniqueidentifier = (select ClosureID from SvcNote_Answer_Closure_UIDs where AnswerID = @answerParentID)
	
	declare @ChildUID uniqueidentifier = (select ClosureID from SvcNote_Question_Closure_UIDs where QuestionID = @questionChildID)

	exec SVCNOTES_CREATE_CLOSURE_CHILD @ParentUID, @childUID

END
GO
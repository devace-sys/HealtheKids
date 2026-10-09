
/* Basic sproc to create new answers. Called from other stored procedures to produce cloned 'favorites' or multi=use practitioner custom answers */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_CLOSURE_CHILD_ANSWER') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_CHILD_ANSWER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_CHILD_ANSWER 
(
	@answerParentID bigint,
	@answerChildID bigint
)

/***************************************** 
	Create closure records for a answer-answer parent-child relationship 
	This is used to determine which answers become available as 'followups'
******************************************/

AS
BEGIN

	declare @ParentUID uniqueidentifier = (select ClosureID from SvcNote_Answer_Closure_UIDs where AnswerID = @answerParentID)
	
	declare @ChildUID uniqueidentifier = (select ClosureID from SvcNote_Answer_Closure_UIDs where AnswerID = @answerChildID)

	exec SVCNOTES_CREATE_CLOSURE_CHILD @ParentUID, @childUID

END
GO
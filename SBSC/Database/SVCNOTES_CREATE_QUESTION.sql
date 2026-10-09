
/* Basic sproc to create new answers. Called from other stored procedures to produce cloned 'favorites' or multi=use practitioner custom answers */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_QUESTION') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_QUESTION
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_QUESTION
(

		@Active bit,
		@NoteTypeID bigint,
		@QuestionSequence bigint,
		@QuestionText varchar(MAX),
		@AnswerInputType bigint,
		@NumAllowedAnswers bigint,
		@AnswersUserFavoritesAllowed bit,
		@AnswersUserEnteredAllowed bit,
		@AnswersFileUploadAllowed bit,
		@AnswersFreeTextAllowed bit,
		@QuestionisOptional bit, 
		
	@NewQuestionID bigint OUTPUT
)

/***************************************** 
	Basic sproc to create new service note questions. 
	
******************************************/

AS
BEGIN

	BEGIN
		insert into SvcNote_Questions (Active, NoteTypeID, QuestionSequence, QuestionText, AnswerInputType, NumAllowedAnswers, AnswersUserFavoritesAllowed, AnswersUserEnteredAllowed, AnswersFileUploadAllowed, AnswersFreeTextAllowed, QuestionisOptional)
		VALUES (@Active, @NoteTypeID, @QuestionSequence, @QuestionText, @AnswerInputType, @NumAllowedAnswers, @AnswersUserFavoritesAllowed, @AnswersUserEnteredAllowed, @AnswersFileUploadAllowed, @AnswersFreeTextAllowed, @QuestionisOptional)
																																				   
		set @NewQuestionID = SCOPE_IDENTITY()
		
				/* Closure hierarchy - setup the initial depth-zero AD identity */
		
		declare @UID uniqueidentifier = NEWID()
		
		insert into SvcNote_Question_Closure_UIDs (QuestionID, ClosureID) VALUES (@NewQuestionID, @UID)
		
		insert into SvcNote_Hierarchy_Closure (Ancestor, Descendant, Depth) VALUES (@UID, @UID, 0)
	
		
	END

END
GO
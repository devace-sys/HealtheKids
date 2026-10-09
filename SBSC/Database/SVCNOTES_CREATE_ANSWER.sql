
/* Basic sproc to create new answers. Called from other stored procedures to produce cloned 'favorites' or multi=use practitioner custom answers */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_ANSWER') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_ANSWER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_ANSWER 
(
	@Active bit,
	@AnswerSequence bigint,
	@QuestionID bigint,
	@PracIDFavorite bigint,
	@GroupTypeLimiter bigint,
	@ClientIDLimiter bigint, 
	@IsFollowup bit,
	@IsCustomAnswer bit,
	@AnswerText varchar(max),
	@AnswerInputType bigint,
	@AnswerEndsNote bit,
	@AnswerRequiresFile bit,
	@AnswerRequiresText bit,
	
	
	
	
	
	@NewAnswerID bigint OUTPUT
)

/***************************************** 
	Basic sproc to create new service note answers. 
	
	Called from other stored procedures to produce cloned 'favorites' or multi=use practitioner custom answers 
******************************************/

AS
BEGIN

	declare @existing_answerID bigint
	
	set @existing_answerID = (select id from SvcNote_Answers 
					where AnswerText = @AnswerText 
					and QuestionID = @QuestionID
					and (PracIDFavorite = @PracIDFavorite or @PracIDFavorite is null)
					and (GroupTypeLimiter = @GroupTypeLimiter or @GroupTypeLimiter is null)
					and (AnswerInputType = @AnswerInputType or @AnswerInputType is null)
					)


	IF @existing_answerID is null
	BEGIN
		insert into SvcNote_Answers (Active, AnswerSequence, QuestionID, PracIDFavorite, ClientIDLimiter, GroupTypeLimiter,IsFollowup, IsCustomAnswer,AnswerText,AnswerInputType, AnswerRequiresFile, AnswerRequiresText)
		VALUES (@Active, @AnswerSequence, @QuestionID,@PracIDFavorite, @ClientIDLimiter,@GroupTypeLimiter,@IsFollowup, @IsCustomAnswer,@AnswerText,NULL, @AnswerRequiresFile, @AnswerRequiresText)
																																				   
		set @NewAnswerID = SCOPE_IDENTITY()
	
		/* Force all answers to indicate they can't be used as skip answers  */
		/* TODO - refactor so skip flag is passed through sproc arguments & is handled intelligently */
		/* What happens if skip answer already exists for Q? */
		
		update SvcNote_Answers
		set UseAnswerForQuestionSkip = 0
		where id = @NewAnswerID
		
	
		/* Set early termination flag */
		/* TODO: early termination flag is deprecated; refactor out */
		insert into SvcNote_Questions_AnswerEndsNote (QuestionID, AnswerID, AnswerEndsNote) VALUES (@QuestionID, @NewAnswerID, @AnswerEndsNote)
		
		/* Closure hierarchy - setup the initial depth-zero AD identity */
		
		declare @UID uniqueidentifier = NEWID()
		
		insert into SvcNote_Answer_Closure_UIDs (AnswerID, ClosureID) VALUES (@NewAnswerID, @UID)
		insert into SvcNote_Hierarchy_Closure (Ancestor, Descendant, Depth) VALUES (@UID, @UID, 0)
		
		/* Link this answer into the question progression default for this question, if there is one */
		
		declare @defaultnextquestionID bigint = (select top 1 snq.DefaultNextQuestionID from SvcNote_Questions snq where snq.id = @QuestionID)
		if @defaultnextquestionID is not null
		begin
			exec SVCNOTES_CREATE_CLOSURE_CHILD_QUESTION @newanswerID, @defaultnextquestionID 
		end
		
	END
	
	else if (select active from SvcNote_Answers where id = @existing_answerID) = 0
	BEGIN
		set @NewAnswerID = @existing_answerID
		
		update SvcNote_Answers set Active = 1 where id = @existing_answerID and Active = 0
	
	END

END
GO
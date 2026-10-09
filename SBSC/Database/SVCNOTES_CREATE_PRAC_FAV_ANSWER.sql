/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_USER_FAV_ANSWER') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_USER_FAV_ANSWER
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_PRAC_FAV_ANSWER') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_PRAC_FAV_ANSWER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_PRAC_FAV_ANSWER 
(
	@NoteID bigint,
	@AnswerID bigint,
	@PracID bigint
)

/*************************************

Clones an existing answer and copies over associated followup links.

The created answer is associated with the userid that favorited the original answer

TODO - @NoteID argument is not used anywhere in this sproc. Look at refactoring this out of the incoming argument list.
***************************************/

AS
BEGIN
	declare @Active bit,
	@AnswerSequence bigint,
	@QuestionID bigint,
	@ClientIDLimiter bigint,
	@PracIDFavorite bigint,
	@GroupTypeLimiter bigint,
	@IsFollowup bit,
	@IsCustomAnswer bit,
	@AnswerText varchar(max),
	@AnswerInputType varchar(max),
	@AnswerEndsNote bit,
	@AnswerRequiresFile bit,
	@AnswerRequiresText bit,
	
	@NewAnswerID bigint

	select
		@Active = Active,
		@AnswerSequence = AnswerSequence,
		@QuestionID = QuestionID,
		@PracIDFavorite = @PracID,
		@GroupTypeLimiter = GroupTypeLimiter,
		@IsFollowup = IsFollowup,
		@IsCustomAnswer = 0,
		@AnswerText = AnswerText,
		@AnswerInputType = AnswerInputType,
		@AnswerRequiresFile = AnswerRequiresFile,
		@AnswerRequiresText = AnswerRequiresText,
		@ClientIDLimiter = ClientIDLimiter
		
	from SvcNote_Answers sna	
	where sna.id = @AnswerID
	
	/* Todo - this is part of the AnswerEndsNote refactor into Svcnote_Answers */
	set @AnswerEndsNote = (select top 1 AnswerEndsNote from SvcNote_Questions_AnswerEndsNote where QuestionID = @QuestionID and AnswerID = @AnswerID)
	
	/* Create the new answer entry */
	
	execute dbo.SVCNOTES_CREATE_ANSWER @active, @answersequence, @questionID, @PracIDFavorite, @groupTypeLimiter, @ClientIDLimiter, @isfollowup, @iscustomAnswer, @answertext, @answerinputtype, @AnswerEndsNote, @AnswerRequiresFile, @AnswerRequiresText, @NewAnswerID OUTPUT

	
	/* Check to see if followup links exist (if this is an answer that was reactivated) */
	if @NewAnswerID is not null AND NOT EXISTS (select 1 from SvcNote_Answer_Followup where AnsweredID = @NewAnswerID or FollowupAnswerID = @NewAnswerID)
	BEGIN
		/* Apply followup links so new answer inherits and passes on information */
	
		insert into SvcNote_Answer_Followup (AnsweredID, FollowupAnswerID)
		(
			select @NewAnswerID, FollowupAnswerID
			from SvcNote_Answer_Followup
			where AnsweredID = @AnswerID
		
			UNION
		
			select AnsweredID, @NewAnswerID
			from SvcNote_Answer_Followup
			where FollowupAnswerID = @AnswerID	
		)
	END
	
	/* Copy over closure entries from original answer */

	declare @oldanswerGUID uniqueidentifier = (select ClosureID from SvcNote_Answer_Closure_UIDs where AnswerID = @AnswerID)
	declare @newanswerGUID uniqueidentifier = (select ClosureID from SvcNote_Answer_Closure_UIDs where AnswerID = @NewAnswerID)
	
	insert into SvcNote_Hierarchy_Closure (Ancestor, Descendant, Depth)
	select @newanswerGUID, snhc.Descendant, snhc.Depth from SvcNote_Hierarchy_Closure snhc where snhc.Ancestor = @oldanswerGUID and Depth <> 0
	UNION
	select snhc.Ancestor, @newanswerGUID, snhc.Depth from SvcNote_Hierarchy_Closure snhc where snhc.Descendant = @oldanswerGUID and Depth <> 0

END
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_CUSTOM_ANSWER') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_CUSTOM_ANSWER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_CUSTOM_ANSWER 
(
	@NoteID bigint,
	@Step bigint,
	@QuestionID bigint,
	@PracIDFavorite bigint,
	@AnswerText varchar(max),
	@svcNoteNoteAnswerID bigint,
	@answerMarked bit
)
AS
BEGIN

declare @NewAnswerID bigint

/* Todo - this is part of the AnswerEndsNote refactor into Svcnote_Answers.  It is passed into but is not used */
declare @CustomAnswerEndsNote bit = (select top 1 ISNULL(AnswerEndsNote,0) from SvcNote_Questions_AnswerEndsNote where QuestionID = @QuestionID and AnswerID = 0)

declare	@AnswerRequiresFile bit = 0
declare	@AnswerRequiresText bit = 1

/*============================================================
 * Create a new answer selection that is visible to just the 
 * practitioner.  We will handle the bookmark option lower down
 *============================================================*/

execute dbo.SVCNOTES_CREATE_ANSWER 1, NULL, @QuestionID, @PracIDFavorite, NULL, NULL, 0, 1, @AnswerText, NULL, @CustomAnswerEndsNote, @AnswerRequiresFile, @AnswerRequiresText, @NewAnswerID output

/*============================================================
 * Update the note answer itself that we assume was entered
 *============================================================*/

update SvcNote_Note_Answers set AnswerID = @NewAnswerID where id = @svcNoteNoteAnswerID


/* Add closure entries using the default next question value for the specified question */																																

declare @nextQ bigint = (select q.DefaultNextQuestionID from SvcNote_Questions q where id = @QuestionID)

execute dbo.SVCNOTES_CREATE_CLOSURE_CHILD_QUESTION @newAnswerid, @nextq

/* Look at non-custom answers for the question this answer was created for 
	if there are parent answers (for headers), brute-force those associations for this new custom answer.
*/


declare @newCustomAnswer bigint
declare @parentAnswerClosures table (idx bigint identity(1,1), ParentAnswer uniqueidentifier, CustomChildAnswer uniqueidentifier)


set @newCustomAnswer = @newAnswerid /* svcnote_answer.id for custom answer favorite */
set @questionID = (select top 1 questionID from SvcNote_Answers where id = @newCustomAnswer)


/* For each of the other answers for the question with the new custom answer, identify:
	What potential parent answers are there for these answers?	
*/

insert into @parentAnswerClosures

select distinct Ancestor, (select ClosureID from SvcNote_Answer_Closure_UIDs where AnswerID = @newCustomAnswer) from SvcNote_Answers sna_sibs
inner join SvcNote_Answer_Closure_UIDs snacu on sna_sibs.id = snacu.AnswerID
inner join SvcNote_Hierarchy_Closure shc on (snacu.ClosureID = shc.Descendant) and Depth = 1
inner join SvcNote_Answer_Closure_UIDs par_snacu on shc.Ancestor = par_snacu.ClosureID
where QuestionID = @questionID and PracIDFavorite is null

declare @counter bigint = 1

while @counter <> (select MAX(idx)+1 from @parentAnswerClosures)
BEGIN
	
	declare @parent uniqueidentifier, @child uniqueidentifier
	
	select @parent = ParentAnswer, @child = CustomChildAnswer from @parentAnswerClosures where idx = @counter

	exec SVCNOTES_CREATE_CLOSURE_CHILD @parent, @child

	set @counter = @counter + 1
END

/*============================================================
 * Since the new answer is initially created as an answer that
 * would be visible to just the practitioner we need to 
 * remove it from view if the practitioner does not want to
 * bookmark it for later use
 *============================================================*/

if (@answerMarked = 0)
begin  
  update SvcNote_Answers set Active = 0 where id =  @NewAnswerID 
end

END
GO
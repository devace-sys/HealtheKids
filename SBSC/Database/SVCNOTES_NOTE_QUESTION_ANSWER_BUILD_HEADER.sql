USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_QUESTION_ANSWER_BUILD_HEADER') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTES_NOTE_QUESTION_ANSWER_BUILD_HEADER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_QUESTION_ANSWER_BUILD_HEADER

(
  @NoteID         bigint, 
  @QuestionID     bigint,
  @AnswerID		  bigint
) 

RETURNS @HeaderValues TABLE 
(
	concatHeader varchar(max),
	ClosureHeaderAnswerID bigint, /* this is the most recent answerID that applies to this header */
	HeaderNoteAnswerID bigint /* This is the id-based entry in svcnote_note_answer that has this header as its answerID */
)
BEGIN
/* query for header building*/
/* Given a noteID and answerid: */



	declare @answerguid uniqueidentifier = 
		(select ClosureID from SvcNote_Answer_Closure_UIDs where AnswerID = @AnswerID)
		
	declare @buffer table (id bigint identity(1,1), ClosestNoteAnswerParent bigint, ClosestAnswerParent bigint,  ConcatText varchar(max),NextHeaderAnswerID bigint, NextHeaderAnswerNoteID bigint)
	
	insert into @buffer (ClosestNoteAnswerParent, ClosestAnswerParent, ConcatText, NextHeaderAnswerID, NextHeaderAnswerNoteID)
	
	/* What closure answers have this answer as a depth-1 (immediate) child? */
	select distinct snna.id, sna_parent.id, sna_parent.AnswerText, snna.OriginatingAnswerID, snna.Parent_NoteAnswerID 
	
	from SvcNote_Hierarchy_Closure shc
	inner join SvcNote_Answer_Closure_UIDs snacu_parent 
		on shc.Ancestor = snacu_parent.ClosureID
	inner join SvcNote_Answers sna_parent 
		on snacu_parent.AnswerID = sna_parent.id
	
	/* Of all the possible answers, which ones did the user use for this note? */
	inner join SvcNote_Note_Answers snna 
		on sna_parent.id = snna.AnswerID 
		and snna.NoteID = @noteid
	
	where shc.Descendant = @answerguid and Depth = 1

declare @delimiter char = '|'

while (select COUNT(*) from @buffer where NextHeaderAnswerID is not null) <> 0
BEGIN

update @buffer
set ConcatText = OutputBuffer.AnswerText + @delimiter + ConcatText,
	NextHeaderAnswerID = OutputBuffer.OriginatingAnswerID,
	NextHeaderAnswerNoteID = OutputBuffer.Parent_NoteAnswerID
from
(
select b.id as bufferID, AnswerText, snna_parent.OriginatingAnswerID, snna_parent.Parent_NoteAnswerID 
from @buffer b
	inner join SvcNote_Answers sna_parent on sna_parent.id = b.NextHeaderAnswerID
	inner join SvcNote_Note_Answers snna_parent on snna_parent.AnswerID = sna_parent.id
			and snna_parent.NoteID = @noteid
			and b.NextHeaderAnswerNoteID = snna_parent.id
) as OutputBuffer

where NextHeaderAnswerID is not null and OutputBuffer.bufferID = id

END
	

insert into @headervalues (concatHeader, ClosureHeaderAnswerID, HeaderNoteAnswerID)
select ConcatText,ClosestAnswerParent, ClosestNoteAnswerParent
from @buffer
	
RETURN

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCNOTES_NOTE_QUESTION_ANSWER_BUILD_HEADER] TO [webuser]
GO
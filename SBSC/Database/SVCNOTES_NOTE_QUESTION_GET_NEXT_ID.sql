USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_QUESTION_GET_NEXT_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTES_NOTE_QUESTION_GET_NEXT_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_QUESTION_GET_NEXT_ID

( @userID         bigint,
  @userGroup      INT,   
  @userRank       INT,
  @clientID		  bigint,
  @pracID		  bigint,
  @NoteID         bigint, 
  @QuestionID     bigint) 
 

RETURNS bigint AS 
BEGIN
	/* Given a specific note and a questionID from that note, determine which question is the next one to be answered*/
	
	declare @next_question bigint =
	(
		select top 1 snna_nextQ.QuestionID from SvcNote_Note_Answers snna

			inner join SvcNote_Answer_Closure_UIDs snacUID on snna.AnswerID = snacUID.AnswerID
			inner join SvcNote_Hierarchy_Closure snhc on snacUID.ClosureID = snhc.Ancestor and Depth = 1
			inner join SvcNote_Question_Closure_UIDs snqcUID on snhc.Descendant = snqcUID.ClosureID
			inner join SvcNote_Note_Answers snna_nextQ 
				on snqcUID.QuestionID = snna_nextQ.QuestionID
				and snna.noteID = snna_nextQ.noteID

		where snna.QuestionID = @QuestionID and snna.noteID = @noteID

		order by snna_nextQ.id

	)

	return @next_question
END;
GO

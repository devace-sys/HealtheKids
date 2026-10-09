USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_QUESTION_GET_PREVIOUS_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTES_NOTE_QUESTION_GET_PREVIOUS_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_QUESTION_GET_PREVIOUS_ID

( @userID         bigint,
  @userGroup      INT,   
  @userRank       INT,
  @clientID		  bigint,
  @pracID		  bigint,
  @NoteID         bigint, 
  @QuestionID     bigint)  

RETURNS bigint AS 
BEGIN
	/* Given a specific note and a questionID from that note, determine which question preceded the one specified in the incoming ID */
	
	declare @previous_question bigint =
	(
		select top 1 prev_ans.QuestionID
		from SvcNote_Question_Closure_UIDs currentQ_UID
		inner join SvcNote_Hierarchy_Closure snhc 
			on currentQ_UID.ClosureID = snhc.Descendant
			and snhc.Depth = 1 /* Depth 1 helps us find the answers that are 1 link away */
		inner join SvcNote_Answer_Closure_UIDs prevAns_UID 
			on snhc.Ancestor = prevAns_UID.ClosureID
		inner join SvcNote_Note_Answers prev_ans 
			on prev_ans.AnswerID = prevAns_UID.AnswerID 
			and prev_ans.NoteID = @NoteID
	
		where currentQ_UID.QuestionID = @QuestionID
		and prev_ans.QuestionID <> @questionid
		order by prev_ans.id desc
	)

	return @previous_question
END;
GO

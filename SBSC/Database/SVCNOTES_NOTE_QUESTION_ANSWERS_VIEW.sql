USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_QUESTION_ANSWERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTES_NOTE_QUESTION_ANSWERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_QUESTION_ANSWERS_VIEW

( @userID         bigint,
  @userGroup      INT,   
  @userRank       INT,
  @clientID		  bigint,
  @pracID		  bigint,
  @NoteID         bigint, 
  @QuestionID     bigint,
  @isPracFavorite bit) 


RETURNS TABLE AS RETURN(
with Core_Note_Answers as
( 
 
 /* What is the full set of answers available for this question? */
	select snn.id as NoteID, snn.pracID, snq.Step, sna.id as AnswerID, sna.* /*TODO: Fix this to a finite column set*/, sna_head.id as AnswerHeaderID, concatHead.concatHeader as AnswerHeaderText, concatHead.ClosureHeaderAnswerID, concatHead.HeaderNoteAnswerID
	
	from SvcNote_Notes snn 
		inner join SvcNote_NoteType snnt 
			on snn.NoteTypeID = snnt.id
			and snn.id = @noteid
		inner join SvcNote_Questions snq 
			on snnt.id = snq.NoteTypeID and 
			snq.id = @questionid
		inner join SvcNote_Answers sna 
			on sna.QuestionID = snq.id 
		/* Filter down these answers: */
		/* Group restriction filter */
			
		/* TODO: If a practitioner's group falls within more than one group limiter, we need to pick a single answer to display. 
			This prevents duplicates from showing up in the answer view. */
			
		/* for the answer in SNA: Look at answers for this question that share the same answertext */
		
		cross apply (
			select COUNT(*) as GroupLimiterMatch 
			from Svcnote_Answer_GrouptypeLimiter_Groups snagtlg
			where snagtlg.groupid = snn.groupID
				and snagtlg.GroupTypeLimiter_ID = sna.grouptypelimiter	
		) gct
			
		/* Is the answer a child answer, and if so, is the parent an answer that has been provided for this specific note? */
		left outer join SvcNote_Answer_Closure_UIDs snacu_child on sna.id = snacu_child.AnswerID
		left outer join SvcNote_Hierarchy_Closure snhc on snacu_child.ClosureID = Descendant and Depth <> 0
		left outer join SvcNote_Answer_Closure_UIDs snacu_parent on snacu_parent.ClosureID = snhc.Ancestor
		left outer join SvcNote_Note_Answers snna on snna.AnswerID = snacu_parent.AnswerID and snna.noteID = @noteID
		left outer join SvcNote_Answers sna_head on snna.AnswerID = sna_head.id
		
		OUTER apply SVCNOTES_NOTE_QUESTION_ANSWER_BUILD_HEADER(@noteid, @questionID, sna.id) as concatHead
		
		


where
	1=1
	/* check parent-child relationship */
	and ((snhc.id is not null AND snna.id is not null) OR (snhc.id is null))
	and (sna.GroupTypeLimiter is null OR (sna.GroupTypeLimiter is not null and gct.GroupLimiterMatch <> 0))
	and (sna.ClientIDLimiter is null or sna.ClientIDLimiter = snn.clientID)
	and sna.Active = 1
	and (sna.PracIDFavorite is null or sna.PracIDFavorite = snn.PracID) /* We never need to show another practitioner's favorites */
)	


select * from
(	/* Get the core answer set */
	select
	/* AnswerHeaderID indicates the SvcNote_Answer that was the last header used for the row recorded in SvcNote_Note_Answers */
	/* ClosureHeaderAnswerID and AnswerHeaderText indicate the immediate parent answer that is being used for the header. These are the values to pass in when appending an answer. */
	cna.NoteID, cna.Step, cna.QuestionID, cna.AnswerID, CONVERT(bit,CASE when cna.PracIDFavorite is NULL then 0 else 1 end) as IsPracFavorite, cna.AnswerHeaderID, cna.AnswerHeaderText, cna.AnswerText, cna.AnswerInputType, prev_ans.id as StoredAnswerID, prev_ans.AnswerValue, cna.IsCustomAnswer, cna.IsFollowup, cna.AnswerRequiresFile, cna.AnswerRequiresText, cna.AnswerSequence, cna.ClosureHeaderAnswerID, cna.HeaderNoteAnswerID
	from Core_Note_Answers cna
	left outer join SvcNote_Note_Answers prev_ans on prev_ans.AnswerID = cna.AnswerID and prev_ans.NoteID = cna.NoteID and prev_ans.QuestionID = cna.QuestionID and (prev_ans.OriginatingAnswerID = cna.ClosureHeaderAnswerID or cna.ClosureHeaderAnswerID is null)

UNION
	/* The user can input their own answers, but not have them recycled for later use in future notes. These answers should still be displayed: */
	select
	snn.id as NoteID, snna.Step, snna.QuestionID, snna.AnswerID, 0 as IsUserFavorite, NULL as AnswerHeaderID, NULL as AnswerHeaderText, snna.AnswerValue as AnswerText, 0 as AnswerInputType, snna.id as StoredAnswerID, snna.AnswerValue, 1 as IsCustomAnswer, 0 as IsFollowup, 0 as AnswerRequiresFile, 0 as AnswerRequiresText, null as AnswerSequence , null as ClosureHeaderAnswerID, NULL as HeaderNoteAnswerID

	from SvcNote_Notes snn
	inner join SvcNote_Note_Answers snna on snna.NoteID = snn.id and snna.AnswerID is null and snna.QuestionID = @questionid
	where snn.id = @noteID
) as q1
    where 
            (q1.NoteID = @NoteID) 
        and ((@IsPracFavorite is null) or (q1.IsPracFavorite = @isPracFavorite))
        and 
        (
			/* Closure table has no matching parent/ no header for this question */
			q1.AnswerHeaderID is null
			OR 
			(	/* Closure header exists */
				q1.AnswerHeaderID = ClosureHeaderAnswerID
				AND
				(
					/* Is there a stored answer we can check for a parent? */
					(q1.StoredAnswerID is null)
					OR
					/* There is! Does the stored answer have a recorded parent answer? */
					(q1.HeaderNoteAnswerID is null)
					OR
					/* It does! Compare it to the parentid from the header */
					q1.HeaderNoteAnswerID = q1.HeaderNoteAnswerID
				
				)
				
			)
        
        
        )
        --(q1.AnswerHeaderID = ClosureHeaderAnswerID) or q1.AnswerHeaderID is null
        --and (q1.Parent_NoteAnswerID = HeaderNoteAnswerID) or q1.Parent_NoteAnswerID is null

)
GO

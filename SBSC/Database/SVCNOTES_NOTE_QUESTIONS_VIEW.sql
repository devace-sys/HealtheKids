USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_QUESTIONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTES_NOTE_QUESTIONS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_QUESTIONS_VIEW

( @userID         bigint,
  @userGroup      INT,   
  @userRank       INT,
  @clientID		  bigint,
  @pracID		  bigint,
  @noteID         bigint, 
  @questionID     bigint) 


RETURNS TABLE AS RETURN(

	select 
		Accessible_Questions.id, 
		Accessible_Questions.Active ,
		Accessible_Questions.NoteTypeID ,
		Accessible_Questions.QuestionSequence ,
		Accessible_Questions.QuestionText,
		Accessible_Questions.NumAllowedAnswers ,
		Accessible_Questions.[AnswersUserFavoritesAllowed] ,
		Accessible_Questions.[AnswersUserEnteredAllowed] ,
		Accessible_Questions.[AnswersFileUploadAllowed] ,
		Accessible_Questions.[AnswersFreeTextAllowed] ,
		Accessible_Questions.QuestionisOptional,
		Accessible_Questions.AnswerInputType,
		CONVERT(bit,CASE WHEN headercount.incoming_ct <> 0 then 1 else 0 END) as AnswersHaveHeaders 

	from
	(
		/* Base case: If no answers provided yet, then the answer we want is the question for this note type with no ancestors. */
		select snq.* from SvcNote_Question_Closure_UIDs snqc
		left outer join SvcNote_Hierarchy_Closure snhc on snqc.ClosureID = snhc.Descendant and snqc.ClosureID <> snhc.Ancestor
		inner join SvcNote_Questions snq on snqc.QuestionID = snq.id
		where snhc.id is null
		
		/* Extended case: If answers have been provided:				*/
		/* * What questions are exposed by the provided answers?		*/
		/* * Exclude questions that the note already has answers for.	*/
		UNION
		select snq.* from SvcNote_Note_Answers  snna
		inner join SvcNote_Answer_Closure_UIDs snacu on snacu.AnswerID = snna.AnswerID
		inner join SvcNote_Hierarchy_Closure snhc on snacu.ClosureID = snhc.Ancestor
		inner join SvcNote_Question_Closure_UIDs snaqu on snaqu.ClosureID = snhc.Descendant
		inner join SvcNote_Questions snq on snaqu.QuestionID = snq.id
		where NoteID = @noteID
		and snhc.depth = 1
	) Accessible_Questions
	
		cross apply (
		select COUNT(*) incoming_ct
		from SvcNote_Answers childsna 
		inner join SvcNote_Answer_Closure_UIDs chiclos on chiclos.AnswerID = childsna.id
		inner join SvcNote_Hierarchy_Closure hier on chiclos.ClosureID = hier.Descendant and Depth <> 0
		inner join SvcNote_Answer_Closure_UIDs parentes on parentes.ClosureID = hier.Ancestor
	) headercount
	
	
	
	where NoteTypeID = (select top 1 NotetypeID from svcnote_notes where id = @noteID)
	and (Accessible_Questions.id = @questionID or @questionID is null)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCNOTES_NOTE_QUESTIONS_VIEW] TO [webuser]
GO
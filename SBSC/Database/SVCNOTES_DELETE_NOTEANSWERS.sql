USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_DELETE_NOTEANSWERS') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_DELETE_NOTEANSWERS
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * SVCNOTES_DELETE_NOTEANSWERS */    
/**    
 * Given a NoteID and QuestionID, delete all answers that were answered on questions on or after the
 * specified question. 
 * 
 * 	@noteid bigint			What note are we working with?
 *	@questionid bigint		What question are we deleting from?
 *
 *	@headerid bigint		If this question has subheaders, what header are we deleting for? (NULLs are okay if headers don't exist or if we want to delete whole question)
 *	@headerAnswerid bigint
 * 
 *
 * 
 ***************************************************************************/     

CREATE PROCEDURE dbo.SVCNOTES_DELETE_NOTEANSWERS
(

	@noteid bigint,
	@questionid bigint,

	@headerid bigint,
	@headerAnswerid bigint
)
AS
BEGIN
	
	/* TODO: delete all applicable entries in SvcNote_Note_Answers_Files and update FILE_UPLOADS */

	declare @all_answers_to_purge bigint_tabletype

	/* Step 1 - identify answers that match this note - question - header - headeranswer */

	insert into @all_answers_to_purge
	select id from SvcNote_Note_Answers
		where NoteID = @noteid
		and QuestionID = @questionid
		and (@headerid = OriginatingAnswerID or @headerid is null)
		and (@headerAnswerid = Parent_NoteAnswerID or @headerAnswerid is null)

	/* Step 2 - Iteration */

	declare @complete bit = 0

	while @complete = 0
	BEGIN
		insert into @all_answers_to_purge
		select distinct snna_checkPurge.id
		from @all_answers_to_purge aap
		inner join SvcNote_Note_Answers snna on aap.id = snna.id
		inner join SvcNote_Answer_Closure_UIDs snacu on snna.AnswerID = snacu.AnswerID
		inner join SvcNote_Hierarchy_Closure shc on snacu.ClosureID = shc.Ancestor
		inner join SvcNote_Question_Closure_UIDs snqcu on shc.Descendant = snqcu.ClosureID
		inner join SvcNote_Note_Answers snna_checkPurge 
			on snna_checkPurge.NoteID= snna.NoteID
			and snna_checkPurge.QuestionID = snqcu.QuestionID
			and (snna_checkPurge.OriginatingAnswerID = snna.AnswerID or snna_checkPurge.OriginatingAnswerID is null or @headerid is null)
			and (snna_checkPurge.Parent_NoteAnswerID = snna.id or snna_checkPurge.Parent_NoteAnswerID is null or @headerAnswerid is null)

		where snna_checkPurge.id not in (select id from @all_answers_to_purge)

	if @@ROWCOUNT = 0
		set @complete =1
	END
	

	/* Deactivate files associated with these answers */
		
	declare @today  as datetime = getdate()
	declare @userID as bigint   = 0
	declare @recID  as bigint   = -1
     declare @recTot as int      = 0
	declare @recCtr as int      = 1
	
	declare @uploadIDs as table (
	    idx          int identity(1,1)
	  , fileUploadID bigint
	)
		
	insert into @uploadIDs 
	select fileUploadID from SvcNote_Note_Answers_Files where svcNoteNoteAnswerID in (select id from @all_answers_to_purge)

     select @userID = createdBy           from SvcNote_Notes where id = @noteid     		
     select @recTot = COUNT(fileUploadID) from @uploadIDs	
	select @recCtr = MIN(idx)            from @uploadIDs
		
	while (@recCtr <= @recTot)
	begin
	  set @recID = -1
	  select top 1 @recID = fileUploadID from @uploadIDs where idx = @recCtr
	  exec FILE_UPLOAD_CANCEL_OR_RESET @recID, @userID, @today
	  set @recCtr = @recCtr + 1
	end
		
/*
	update FILE_UPLOADS
	set active = 0
	where id in
	(select fileUploadID from SvcNote_Note_Answers_Files where svcNoteNoteAnswerID in (select id from @all_answers_to_purge))
	
*/

    /* Deactivate rest of records */

	delete from SvcNote_Note_Answers_Files 
	where svcNoteNoteAnswerID in (select id from @all_answers_to_purge)
	
	delete from SvcNote_Note_Answers
	where id in (select id from @all_answers_to_purge)
	

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].SVCNOTES_DELETE_NOTEANSWERS TO [webuser]

GO






	
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_RESET_NOTE_ANSWERS') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_RESET_NOTE_ANSWERS
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE PROCEDURE dbo.SVCNOTES_RESET_NOTE_ANSWERS (
   @userID        BIGINT
  ,@userGroup     INT  
  ,@userRank      INT 
  ,@noteID        bigint
)
AS
BEGIN

/***************************************************************************    
 * SVCNOTES_RESET_NOTE_ANSWERS */    
/**    
 * Given a NoteID, find the first question answered for that note, and purge answers for that question and all descendants. (resetting note to an unanswered state)
 * 
 * 	@noteid bigint			What note are we working with?
 *
 * 
 ***************************************************************************/     

if (@noteID is not null)
begin
      
    /* Delete answers */
    /* The first question answered for this note will be the root question - use this information to delete everything answered in this note */

    declare @rootQuestion bigint = (select top 1 snna.QuestionID from SvcNote_Note_Answers snna where snna.NoteID = @noteID order by snna.id asc)  
    exec SVCNOTES_DELETE_NOTEANSWERS @noteid, @rootQuestion, null, null  

    /* TODO: Purge service note files and file uploads */

end

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].SVCNOTES_RESET_NOTE_ANSWERS TO [webuser]

GO






	
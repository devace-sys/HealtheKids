USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_DELETE_NOTE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_DELETE_NOTE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE PROCEDURE dbo.SVCNOTES_DELETE_NOTE (
   @userID        BIGINT
  ,@userGroup     INT  
  ,@userRank      INT 
  ,@noteID        bigint
  ,@today         datetime
  ,@purge         bit
)
AS
BEGIN

/***************************************************************************    
 * SVCNOTES_DELETE_NOTE */    
/**    
 * Given a NoteID, delete the note and all answers for that note.
 * 
 * 	@noteid bigint			What note are we working with?
 *	
 *	
 *	
 * 
 *
 * 
 ***************************************************************************/     

if (@noteID is not null)
begin

  if (@purge is null) set @purge = 0
  if (@today is null) set @today = GETDATE()
  
  if (@purge = 1)
  begin
      
    /* Delete answers */
	exec SVCNOTES_RESET_NOTE_ANSWERS @userid, @usergroup, @userrank, @noteID

    /* Delete service record cross reference (if it exists) */  

    delete from SvcNote_SvcRec  where svcNoteID = @noteID

    /* Delete service note itself */

    delete from SvcNote_Notes   where id = @noteID    

    /* Update file uploads table indicateing that these files are no longer needed*/

    update FILE_UPLOADS set active = 0 where id in (select fileUploadID as [id] from SvcNote_Note_Answers_Files where noteID = @noteID)

    /* Delete service note file records (files themselves are not deleted)*/

    delete from SvcNote_Note_Answers_Files where noteID = @noteID

  end

  else if (@purge = 0)
  begin
    
    update SvcNote_Notes set active = 0, lastUpdated = @today, lastUpdatedBy = @userID where id = @noteID 

    /* Update file uploads table indicateing that these files are no longer needed */
    
    update FILE_UPLOADS set active = 0 where id in (select fileUploadID as [id] from SvcNote_Note_Answers_Files where noteID = @noteID)
    
  end
  else
  begin
    return(0)
  end

end

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].SVCNOTES_DELETE_NOTE TO [webuser]

GO






	
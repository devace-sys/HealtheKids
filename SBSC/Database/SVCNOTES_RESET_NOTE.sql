USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_RESET_NOTE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_RESET_NOTE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE PROCEDURE dbo.SVCNOTES_RESET_NOTE (
   @userID        BIGINT
  ,@userGroup     INT  
  ,@userRank      INT 
  ,@clientID      bigint
  ,@pracID        bigint 
  ,@noteID        bigint
  ,@today         datetime
)
AS
BEGIN

/***************************************************************************    
 * SVCNOTES_RESET_NOTE */    
/**    
 * Given a NoteID, reset the note to start at the first question.  This is
 * analogous to a form reset
 * 
 * @param   noteid   What note are we working with?
 * @param   today    Date and time to set the note lastUpdated column to	
 * 
 ***************************************************************************/     

if (@noteID is not null)
begin
  if (@today is null) set @today = GETDATE()
  exec SVCNOTES_RESET_NOTE_ANSWERS @userid, @usergroup, @userrank, @noteID
  update SvcNote_Notes set lastUpdated = @today, lastUpdatedBy = @userID where id = @noteID 
  
   /* Update file uploads table indicateing that these files are no longer needed*/

  update FILE_UPLOADS set active = 0 where id in (select fileUploadID as [id] from SvcNote_Note_Answers_Files where noteID = @noteID)

  /* Delete service note file records (files themselves are not deleted)*/
  
  delete from SvcNote_Note_Answers_Files where noteID = @noteID
  
end
return(0)

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].SVCNOTES_RESET_NOTE TO [webuser]

GO






	
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_DELETE_NOTE_AND_RELATED_RECORDS') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_DELETE_NOTE_AND_RELATED_RECORDS
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE PROCEDURE dbo.SVCNOTES_DELETE_NOTE_AND_RELATED_RECORDS (
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
 * SVCNOTES_DELETE_NOTE_AND_RELATED_RECORDS */    
/**    
 * Given a noteID, delete the note and all answers for that note and also
 * delete any related records
 * 
 * @param   clientID  What client id 
 * @param   noteid    What note are we working with?
 * @param   today     Update date to use
 ***************************************************************************/     
       
/*-------------------------------    
 * Look up the related service 
 * record if it exists
 *------------------------------*/    

declare @svcRecID  as bigint = 0
declare @spDetails as varchar(8000)
declare @recordID  as bigint

if (@noteID is not null)
begin
  
  if (@today is null) set @today = GETDATE()
  
  select @svcRecID = svcRecID  from SvcNote_SvcRec where clientID = @clientID and svcNoteID = @noteID

  exec SERVICE_RECORD_Delete_Core  
    @userID, 
    @userGroup, 
    @userRank, 
    'User decided to delete service note and associated service record', 
    0, 
    @clientID, 
    @svcRecID, 
    1,
    @today, 
    'The service record does not exist', 
    'You cannot delete this service record and note', 
    @spDetails OUTPUT, 
    @recordID OUTPUT
end
return(0)
 
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].SVCNOTES_DELETE_NOTE_AND_RELATED_RECORDS TO [webuser]

GO






	
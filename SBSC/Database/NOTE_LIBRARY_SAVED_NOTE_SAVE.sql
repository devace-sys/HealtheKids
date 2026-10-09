USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NOTE_LIBRARY_SAVED_NOTE_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.NOTE_LIBRARY_SAVED_NOTE_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.NOTE_LIBRARY_SAVED_NOTE_SAVE ( 
  @userID              BIGINT,    
  @userGroup           INT,    
  @userRank            INT,    
  @noteOwner           BIGINT,
  @noteNamespace       VARCHAR(500),
  @noteSource          VARCHAR(500),
  @clientID            bigint,
  @pracID              bigint,
  @patID               bigint,
  @noteText            VARCHAR(8000),
  @editDelReason       VARCHAR(7000),    
  @validateRec         BIT,    
  @saveType            INT,    
  @recID               BIGINT,
  @MsgNoRec            VARCHAR(1000),    
  @MsgNoEdit           VARCHAR(1000), 
  @MsgDupRec           VARCHAR(1000),   
  @MsgDataError        VARCHAR(1000),
  @MsgNotActive        VARCHAR(1000),     
  @spDetails           VARCHAR(8000) OUTPUT,    
  @recordID            BIGINT        OUTPUT
)    

AS
BEGIN

declare @today    as datetime = GETDATE()
declare @dupCount as int      = 0

set @spDetails = ''
set @recordID  = 0

select 
  @dupCount = COUNT(id) 
from dbo.NOTE_LIBRARY_SAVED_NOTES
where 
      
      (noteNamespace = @noteNamespace)
  and (noteSource    = @noteSource)
  and (clientID      = @clientID)
  and (pracID        = @pracID)
  and (patID         = @patID)
  and (noteText      = @noteText)
  and (active        = 1)
  
if (@dupCount = 0)
begin

  -- not a good reference for coding save sprocs; doesn't include a transaction for some reason


  insert into dbo.NOTE_LIBRARY_SAVED_NOTES (
      noteOwner
    , noteNamespace
    , noteSource
    , noteText
    , createdOn
    , createdBy
    , clientID
    , pracID
    , patID
  )
  values (
      @noteOwner
    , @noteNamespace
    , @noteSource
    , @noteText
    , @today
    , @userID
    , @clientID
    , @pracID
    , @patID
  )

  set @recordID = SCOPE_IDENTITY()
end

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[NOTE_LIBRARY_SAVED_NOTE_SAVE] TO [webuser]
GO


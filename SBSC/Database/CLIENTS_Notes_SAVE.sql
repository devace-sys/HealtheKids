USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENTS_Notes_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENTS_Notes_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.CLIENTS_Notes_SAVE ( 
    @userID              bigint
  , @userGroup           int  
  , @userRank            int    
  , @clientID            bigint /* is the selected client for the note, not necessarily the clientID of the logged in user; using Validate.reqClientID()*/
  , @topicID             bigint
  , @subject             varchar(115)
  , @noteText            varchar(max)
  , @sharedWithClient    bit
  , @validateRec         bit    
  , @saveType            int 
  , @editDelReason       varchar(500)
  , @recID               bigint
  , @MsgNoRec            VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000) 
  , @MsgDupRec           VARCHAR(1000)   
  , @MsgDataError        VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)     
  , @spDetails           VARCHAR(8000) OUTPUT
  , @recordID            BIGINT        OUTPUT
)    

AS
BEGIN

declare @today               as datetime = GETDATE()
declare @tranOpen            as bit      = 0 
declare @createdByClientUser as bit    = null
declare @recClientID         as bigint = null

set @spDetails = ''
set @recordID  = 0
set @tranOpen  = 0
set @today     = getdate()

BEGIN TRY

/*-------------------------------    
 * Set defaults and cleanup
 *------------------------------*/   

set @subject          = trim(isnull(@subject,''))
set @noteText         = trim(isnull(@noteText,''))
set @sharedWithClient = isnull(@sharedWithClient,0)

/*-------------------------------    
 * Verify required parms
 *------------------------------*/   

if (@userID      IS NULL) RAISERROR ('userID is required',         11, 1)      
if (@saveType    IS NULL) RAISERROR ('Save type required',         11, 1)    
if (@validateRec IS NULL) RAISERROR ('Validate flag required',     11, 1)    
if (@clientID    IS NULL) RAISERROR ('Client id required',         11, 1)				     
if (@topicID     IS NULL) RAISERROR ('Topic id required',          11, 1)				     
if (len(@noteText) = 0)   RAISERROR ('Conversation text required', 11, 1)				     

/*-------------------------------    
 * If this is a record edit
 *------------------------------*/   

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  set @recordID = 0

  /*-------------------------------    
   * If rec id was not passed 
   * exit with error
   *------------------------------*/    

  if (@recID IS NULL) RAISERROR ('Record id required', 11, 1)

  /*-------------------------------    
   * Find record and also prevent
   * unauthorized/unnessary edits
   *------------------------------*/    

  select top 1 
     @recordID     = isnull(cn.id,0)
   , @recClientID = cn.clientID
  from dbo.CLIENTS_Notes as cn
  where ( 
        (cn.id        = @recID)     /* Find record itself */
    and (cn.createdBy = @userID)    /* Only author can edit/delete */
    and (cn.clientID  = @clientID)  /* Enforce client partitioning (middware enforces clientid for client users */
    and (cn.active    = 1)          /* Can only edit/delete active */
  )
  
  /*-------------------------------    
   * If record not found 
   * exit with error
   *------------------------------*/    

  if (@recordID = 0) RAISERROR ('Record not found or changes to this record not allowed',  11, 1) 


  /*-------------------------------    
   * If client id changed exit
   * with error
   *------------------------------*/    

  if (@recClientID != @clientID) RAISERROR ('Client cannot be changed', 11, 1)				     
       		 
end /* is edit */

/*-------------------------------    
 * If we are validating go ahead
 * and exit
 *------------------------------*/   

if (@validateRec = 1) RETURN (0)

/*-------------------------------    
 * Otherwise proceed with 
 * creating new or editing 
 * existing record.
 *------------------------------*/   

BEGIN TRANSACTION

set @tranOpen = 1

  /*-------------------------------    
   * New
   *------------------------------*/   

  if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
  begin

    insert into dbo.CLIENTS_Notes (
        clientID
	  , topicID 
      , [subject]
      , noteText 
      , created
      , createdBy
      , sharedWithClient
      
    )
    values (
        @clientID 
	  , @topicID  
      , @subject 
      , @noteText
      , @today  
      , @userID 
      , @sharedWithClient      
    )

    set @recordID = SCOPE_IDENTITY()

  end

  /*-------------------------------    
   * Edit   
   *------------------------------*/   

  else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
  begin

    UPDATE dbo.CLIENTS_Notes
    SET
        topicID            = @topicID  
      , noteText           = @noteText
      , [subject]          = @subject
      , sharedWithClient   = @sharedWithClient
      , lastModified       = @today 
      , lastModifiedBy     = @userID
    where (id = @recID)
 
  end

  COMMIT TRANSACTION
  set @tranOpen = 0

  RETURN (0)

  END TRY
  
  BEGIN CATCH

    if (@tranOpen = 1)
    begin  
      rollback transaction
    end

    DECLARE @ErrorMessage  AS VARCHAR(4000)    
    DECLARE @ErrorSeverity AS INT    
    DECLARE @ErrorState    AS INT    
     
    SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
            @ErrorSeverity = ERROR_SEVERITY(),    
            @ErrorState    = ERROR_STATE()    

    SET @spDetails = @ErrorMessage  -- This should output the error to the browser.  Comment on production, uncomment on dev for diagnostics as needed.

    RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);

  END CATCH

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLIENTS_Notes_SAVE] TO [webuser]
GO


USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Services_Delete') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Practitioner_Patient_Scheduled_Services_Delete
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[Practitioner_Patient_Scheduled_Services_Delete] (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @clientID      bigint
  , @pracID        bigint
  , @recID         INT
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * Practitioner_Patient_Scheduled_Services_Delete */    
/**    
 * 
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    

declare @tranOpen as bit = 0

BEGIN TRY    
   
/*-------------------------------    
 * Init 
 *------------------------------*/    

set @tranOpen   = 0   
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @spDetails  = ''    
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    

IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)    
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('Record id is required',   11, 1)    
if (@clientID    is null) RAISERROR ('Client ID is required',   11, 1)
if (@pracID      is null) RAISERROR ('Prac ID is required',     11, 1)

/*-------------------------------    
 * Find record
 * Uses index
 *------------------------------*/    

set @recordID = 0

select 
  @recordID = isnull(ppss.id,0)
from dbo.Practitioner_Patient_Scheduled_Services as ppss
where ( 
      (ppss.clientID = @clientID)
  and (ppss.pracID   = @pracID)
  and (ppss.active   = 1)
  and (ppss.id       = @recID)
)

/*-------------------------------    
 * If record is not found
 * exit silently
 *------------------------------*/    

if (@recordID = 0)
begin
  return(0)
end

/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    

set @tranOpen = 1
begin transaction
   
  set @updateState = dbo.CONST_SVC_REC_STATE_DEL()    

  /*-------------------------------    
   * Deactivate
   *------------------------------*/    
  
  update dbo.Practitioner_Patient_Scheduled_Services
  set 
      active            = 0
    , lastModified      = getdate()
    , lastModifiedBy    = @userID    
  where (
        ([id] = @recordID)       
  )
  
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
commit transaction
set @tranOpen = 0
     
RETURN(0)    
END TRY    
   
BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong. Rollback any 
   * transactions and return any 
   * error messages to the caller    
   *------------------------------*/    
   
  -- Error or raise error with severity 11 to 19 will be caught here    
   
  if (@tranOpen = 1) rollback transaction
     
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  SET @ErrorMessage = @ErrorMessage
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Practitioner_Patient_Scheduled_Services_Delete] TO [webuser]
GO

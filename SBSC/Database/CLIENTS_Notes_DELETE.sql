
USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENTS_Notes_DELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENTS_Notes_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CLIENTS_Notes_DELETE] (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
  , @clientID      BIGINT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @recID         INT
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * CLIENT_NOTES_DELETE */    
/**    
 * Delete record and manages any associated records.    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @tranOpen     AS BIT    
DECLARE @today        AS DATETIME

/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    

set @recordID   = 0    
set @spDetails  = ''    

/*-------------------------------    
 * Init other vars
 *------------------------------*/    

set @tranOpen = 0
set @today      = GETDATE()    
   
BEGIN TRY    
       
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    

IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)       
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('Record ID is required',   11, 1)    
   
/*-------------------------------    
 * Find record and also prevent
 * unauthorized/unnessary deletes
 *------------------------------*/    

select top 1 
  @recordID = isnull(cn.id,0)
from dbo.CLIENTS_Notes as cn
where ( 
      (cn.id        = @recID)                              /* Find record itself */
  and (cn.createdBy = @userID)                             /* Only author can edit/delete */
  and (cn.active    = 1)                                   /* Can only edit/delete active */
  and ((@clientID is null) or (cn.clientID  = @clientID))  /* Enforce client partitioning for client users (middleware enforces client id)*/
)

/*-------------------------------    
 * If record not found get out
 *------------------------------*/    

if (@recordID = 0) RAISERROR ('Record not found or changes to this record not allowed',  11, 1) 


/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  set @tranOpen = 1    
  
  update dbo.CLIENTS_Notes
  set
      active            = 0 
    , lastModified      = @today
    , lastModifiedBy    = @userID

  where (id = @recordID)
       
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
     
COMMIT TRANSACTION    
set @tranOpen = 0    
RETURN(0)    
END TRY    
   
BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
   
  -- Error or raise error with severity 11 to 19 will be caught here    
   
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
   
  DECLARE @ErrorMessage  AS VARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLIENTS_Notes_DELETE] TO [webuser]
GO

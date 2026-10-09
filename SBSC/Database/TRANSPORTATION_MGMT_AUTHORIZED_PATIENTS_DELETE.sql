USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_DELETE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_DELETE]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @clientID      BIGINT,    
  @transMgmtID   BIGINT,
  @patID         BIGINT,
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @recID         INT,    /* Note: Not used.  @patID is used to find */             
  @MsgNoRec      VARCHAR(1000),
  @MsgNoEdit     VARCHAR(1000), 
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_DELETE */    
/**    
 ***************************************************************************/         
     
SET NOCOUNT ON    

DECLARE @TranOpen            AS BIT  
DECLARE @recCount            AS INT
DECLARE @today               as DATETIME
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in    
DECLARE @auditRecID          AS BIGINT
DECLARE @saveType            AS INT    

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @spDetails  = ''    
SET @recordID     = 0    

/*-------------------------------    
 * Init 
 *------------------------------*/    
   
SET @saveType     = dbo.CONST_SAVE_TYPE_DELETE()    
SET @today        = GETDATE()    
SET @updateState  = dbo.CONST_REC_STATE_DEL()

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',       11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',        11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',      11, 1)

/*------------------------------
 * Get recordID that coresponds to
 * @patID.  There should only be 
 * one active one.
 *------------------------------*/    

set @recordID = null     

select top 1 
  @recordID = transMgmtAuthPatID 
from dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW_CORE ( @userID
                                                       , @userGroup
                                                       , @userRank
                                                       , @clientID
                                                       , @transMgmtID
                                                       , @patID
                                                       , 1
                                                       , null)

if (@recordID is null) 
begin
  set @recordID = 0 
  return(0)
end

/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
  
  /* Remove from authorized route */
  
  update dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS   
  set 
     LAST_MODIFIED_BY    = @userID
   , LAST_MODIFIED_ON    = @today
   , ACTIVE              =  0  
  where ((TRANSPORTATION_MGMT_AUTH_PAT_ID = @recordID) and (ACTIVE = 1))
  
  /* Remove from authorized list */
  
  update dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS 
  set
     LAST_MODIFIED_BY    = @userID
   , LAST_MODIFIED_ON    = @today
   , ACTIVE              =  0    
  where ((ID = @recordID) and (ACTIVE = 1))
  
  /*-------------------------------    
   * If we reach this point    
   * everything is OK, commit our    
   * changes and exit    
   *------------------------------*/    
    
  COMMIT TRANSACTION    
  SET @TranOpen = 0    
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
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
   if (@ErrorSeverity > 11)    
     SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_DELETE] TO [webuser]
GO


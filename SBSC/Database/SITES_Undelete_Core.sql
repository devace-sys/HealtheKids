USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SITES_Undelete_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SITES_Undelete_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[SITES_Undelete_Core]    
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @clientID      INT,    
  @recID         INT,    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN    
   
/***************************************************************************    
 * SITES_Undelete_Core */    
/**    
 * Undeletes (reactivates) an existing patient expected services record    
 *    
 * @param   userID          The userid of who saved the record    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT deleting the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng service record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message for edit/delete service record    
 *                          operations when record is not found    
 * @param   MsgNoEdit       Desired error message for edit/delete service record    
 *                          operations if the service record cannot be edited or    
 *                          deleted    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @canEdit      AS BIT    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    
   
BEGIN TRY    
   

/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType    = dbo.CONST_SAVE_TYPE_REACTIVATE()
SET @updateState = dbo.CONST_REC_STATE_MOD()    
SET @recordID    = 0    
SET @spDetails   = ''    
SET @today       = GETDATE()    

/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
 
 IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * Get recordID of inactive
 * patient expected service
 *------------------------------*/    

SET @recordID = NULL

SELECT top 1
  @recordID = SITE_ID
FROM dbo.SITES_Site
WHERE (
       (1=1) 
   AND ((@clientID IS NULL) OR (SITE_CLIENT_ID = @clientID))
   AND (ACTIVE    = 0)
   AND (SITE_ID        = @recID)
)
  
/*    and ACTIVE = 0) */

/*-------------------------------    
 * We only want to reactivate if
 * the patient expected services was found and
 * they were inactive
 *------------------------------*/    

IF (@recordID IS NOT NULL)
begin      
  
  /*-------------------------------    
   * Reactivate patient expected services if
   * the patient expected services is not active
   *------------------------------*/

  UPDATE dbo.SITES_Site
  SET
    active           = 1
  , DATE_MODIFIED    = @today
  , LAST_MODIFIED_BY = @userID
  WHERE (SITE_ID = @recID)
     
   /*-------------------------------    
    * Create audit record    
    *------------------------------*/    
        
   EXEC dbo.SITES_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
 
 end
   
       
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
     
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
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SITES_Undelete_Core] TO [webuser]
GO
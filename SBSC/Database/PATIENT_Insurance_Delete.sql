USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_Insurance_Delete') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_Insurance_Delete
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PATIENT_Insurance_Delete] (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @clientID      bigint
  , @recID         bigint
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT
 )     
AS    
BEGIN    
   
/***************************************************************************    
 * PATIENT_Insurance_Delete */    
/**    
 * Deletes an existing record   
 *    
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
   
DECLARE @tranOpen     AS BIT    
DECLARE @today        AS DATETIME          -- Current date/time stamp    

/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
set @recordID   = 0 
set @spDetails  = ''
set @today      = GETDATE()       
   
BEGIN TRY    
            
BEGIN TRANSACTION    
   
  set @tranOpen = 1    
   
  exec dbo.PATIENT_Insurance_Delete_Core  
      @userID        
    , @userGroup    
    , @userRank     
    , @editDelReason
    , @validateRec  
    , @clientID     
    , @recID        
	, @today        
    , @MsgNoRec     
    , @MsgNoEdit    
    , @spDetails    OUTPUT
    , @recordID     OUTPUT
 
  /*-------------------------------    
   * If we reach this point    
   * everything is OK, commit our    
   * changes and exit    
   *------------------------------*/    
     
  COMMIT TRANSACTION    
  SET @tranOpen = 0    
  RETURN(0)    
END TRY    
   
BEGIN CATCH       
   
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
   
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  --SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PATIENT_Insurance_Delete] TO [webuser]
GO

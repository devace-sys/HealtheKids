USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE]    
 (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
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
 * CLAIM_SERVICE_NAME_XREF_AMD_XFORM_DELETE */    
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
    
DECLARE @TranOpen     AS BIT ;

SET @spDetails = '';   

BEGIN TRY    
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
 IF (@validateRec is null)  RAISERROR ('Validate flag required',  11, 1)    
 if (@recID       is null)  RAISERROR ('Record id required',      11, 1)    
 if (@userID      is null)  RAISERROR ('User id required',        11, 1)    

 -- exec [dbo].[CLAIM_SERVICE_NAME_XREF_AMD_XFORM_CAN_DELETE_VALIDATE]    
 --    @recID  
 --  , @MsgNoRec
 --  , @recordID   OUTPUT

/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
 IF (@validateRec = 1) RETURN(0)    
   
 BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * "Delete" existing entity record    
   *------------------------------*/       
  
  exec dbo.CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_CORE
	    @userID      
	  , @recID

  SET  @recordID =  @recID

  /*============================================================
   * Update cached cross ref snx data if we are not validating
   *============================================================*/  

  if (@validateRec = 0)
  begin
    exec dbo.CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED_UPDATE_CORE
  end

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

GRANT EXECUTE ON  [dbo].[CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE] TO [webuser]
GO

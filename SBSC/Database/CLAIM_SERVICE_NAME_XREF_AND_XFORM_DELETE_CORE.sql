USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_CORE]    
 (
    @userID        BIGINT
  , @recID         INT
)     
AS    
BEGIN    
   
/***************************************************************************    
 * CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_CORE */    
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
   

DECLARE @today        AS DATETIME          -- Current date/time stamp    
   
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @today = GETDATE()       
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/     
   
  /*-------------------------------    
   * "Delete" existing entity record    
   *------------------------------*/       
  
  UPDATE [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA]
  SET   active         = 0
      , lastModifiedOn = @today
	  , lastModifiedBy = @userID		
  WHERE (
        (id = @recID) /* index */
    and ((isStandard = 0) and (hasClientID = 1) and (active = 1)) /* Can only delete clones not standards */
  )
 
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
      
RETURN(0)    
 
   
   
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_CORE] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_Audit') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.INPUT_BATCHES_Audit
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[INPUT_BATCHES_Audit](@recID       BIGINT,     
                                             @loggedOn    DATETIME,  
                                             @fromStatus  SMALLINT,  
                                             @toStatus    SMALLINT,  
                                             @userID      BIGINT,    
                                             @assignedTo  SMALLINT,    
                                             @reason      VARCHAR(7000),    
                                             @recordID    BIGINT   OUTPUT)    
AS    
BEGIN    
    
/***************************************************************************    
 * INPUT_BATCHES_Audit */    
/**    
 * Creates a new entry in INPUT_BATCHES_AUDIT_LOG    
 *    
 * @param   recID           The INPUT_BATCHES record id    
 * @param   loggedOn        Date/time of the operation    
 * @param   userID          The userid of who performed an operation on the    
 *                          service record    
 * @param   saveType        What operation was performed    
 * @param   state           What state was the record left in    
 * @returns recordID        Record ID of the new audit log entry    
 ***************************************************************************/    
    
SET NOCOUNT ON    
    
INSERT INTO dbo.INPUT_BATCHES_ACTIVITY
  (Input_Batches_ID,Date_Updated,FROM_STATUS,TO_STATUS,UpdatedBy,AssignedTo,Note)
  --(recID, loggedOn, userID, saveType, state, reason)    
VALUES    
  (@recID, @loggedOn, @fromStatus, @toStatus, @userID,@assignedTo, @reason)    
      
SET @recordID = SCOPE_IDENTITY()    
    
RETURN(0)    
    
END 
GRANT EXECUTE ON  [dbo].[INPUT_BATCHES_Audit] TO [webuser]
  
GO

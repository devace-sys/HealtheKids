USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INFO_REQUEST_RESPONSE_DETAILS_Audit') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.INFO_REQUEST_RESPONSE_DETAILS_Audit
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[INFO_REQUEST_RESPONSE_DETAILS_Audit] (@recID BIGINT,     
                                             @loggedOn DATETIME,    
                                             @userID   BIGINT,    
                                             @saveType INT,    
                                             @state    SMALLINT,    
                                             @reason   VARCHAR(7000),    
                                             @recordID BIGINT   OUTPUT)    
AS    
BEGIN    
    
/***************************************************************************    
 * INFO_REQUEST_RESPONSE_DETAILS_Audit */    
/**    
 * Creates a new entry in INFO_REQUEST_RESPONSE_AUDIT_LOG    
 *    
 * @param   recID           The INFO_REQUEST_RESPONSE record id    
 * @param   loggedOn        Date/time of the operation    
 * @param   userID          The userid of who performed an operation on the    
 *                          service record    
 * @param   saveType        What operation was performed    
 * @param   state           What state was the record left in    
 * @returns recordID        Record ID of the new audit log entry    
 ***************************************************************************/    
    
SET NOCOUNT ON    
    
INSERT INTO dbo.INFO_REQUEST_RESPONSE_DETAILS_AUDIT_LOG    
  (recID, loggedOn, userID, saveType, state, reason)    
VALUES    
  (@recID, @loggedOn, @userID, @saveType, @state, @reason)    
      
SET @recordID = SCOPE_IDENTITY()    
    
RETURN(0)    
    
END 
GRANT EXECUTE ON  [dbo].[INFO_REQUEST_RESPONSE_DETAILS_Audit] TO [webuser]
  
GO

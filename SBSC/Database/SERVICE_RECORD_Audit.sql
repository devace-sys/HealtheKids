USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Audit') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Audit
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Audit](@svcRecID BIGINT,     
                                             @loggedOn DATETIME,    
                                             @userID   BIGINT,    
                                             @saveType INT,    
                                             @state    SMALLINT,    
                                             @reason   VARCHAR(7000),    
                                             @recordID BIGINT   OUTPUT)    
AS    
BEGIN    
    
/***************************************************************************    
 * SERVICE_RECORD_Audit */    
/**    
 * Creates a new entry in SERVICE_RECORDS_AUDIT_LOG    
 *    
 * @param   svcRecID        The service record id    
 * @param   loggedOn        Date/time of the operation    
 * @param   userID          The userid of who performed an operation on the    
 *                          service record    
 * @param   saveType        What operation was performed    
 * @param   state           What state was the record left in    
 * @returns recordID        Record ID of the new audit log entry    
 ***************************************************************************/    
    
SET NOCOUNT ON    
    
INSERT INTO dbo.SERVICE_RECORDS_AUDIT_LOG    
  (svcRecID, loggedOn, userID, saveType, state, reason)    
VALUES    
  (@svcRecID, @loggedOn, @userID, @saveType, @state, @reason)    
      
SET @recordID = SCOPE_IDENTITY()    
    
RETURN(0)    
    
END    
    
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENTS_Audit') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENTS_Audit
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLIENTS_Audit] (@recID BIGINT,     
                                             @loggedOn DATETIME,    
                                             @userID   BIGINT,    
                                             @saveType INT,    
                                             @state    SMALLINT,    
                                             @reason   VARCHAR(7000),    
                                             @recordID BIGINT   OUTPUT)
AS    
BEGIN    
    
/***************************************************************************    
 * CLIENTS_Audit */    
/**    
 * Creates a new entry in CLIENTS_AUDIT_LOG    
 *    
 * @param   recID                     The clients record id    
 * @param   loggedOn                  Date/time of the operation    
 * @param   userID                    The userid of who performed an operation on the    
 *                                    service record    
 * @param   saveType                  What operation was performed    
 * @param   state                     What state was the record left in    
 * @returns recordID                  Record ID of the new audit log entry    
 ***************************************************************************/    
    
SET NOCOUNT ON    

declare @claimNoPlan as bit
declare @claimNoPlanEffectiveDate as DATETIME
declare @claim_TCM as bit
declare @claim_TCMEffectiveDate as DATETIME

select top 1

@claimNoPlan = claimNoPlan
, @claimNoPlanEffectiveDate = claimNoPlanEffectiveDate
, @claim_TCM = claim_TCM
, @claim_TCMEffectiveDate = claim_TCMEffectiveDate

from dbo.CLIENTS_CLIENT

where 

(CLIENT_ID = @recID)


INSERT INTO dbo.CLIENTS_AUDIT_LOG    
  (recID, loggedOn, userID, saveType, state, claimNoPlan, claimNoPlanEffectiveDate, claim_TCM, claim_TCMEffectiveDate, reason)    
VALUES    
  (@recID, @loggedOn, @userID, @saveType, @state, @claimNoPlan, @claimNoPlanEffectiveDate, @claim_TCM, @claim_TCMEffectiveDate, @reason)    
      
SET @recordID = SCOPE_IDENTITY()    
    
RETURN(0)    
    
END 
GRANT EXECUTE ON  [dbo].[CLIENTS_Audit] TO [webuser]
  
GO

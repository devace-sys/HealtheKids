USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_Audit') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_Audit
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENT_Audit] (@patRecID BIGINT,     
                                        @loggedOn DATETIME,    
                                        @userID   BIGINT,    
                                        @saveType INT,    
                                        @state    SMALLINT,    
                                        @reason   VARCHAR(7000),  
                                        @recordID BIGINT   OUTPUT)    
AS    
BEGIN    
    
/***************************************************************************    
 * PATIENT_Audit */    
/**    
 * Creates a new entry in SERVICE_RECORDS_AUDIT_LOG    
 *    
 * @param   patRecID                          The patient record id    
 * @param   loggedOn                          Date/time of the operation    
 * @param   userID                            The userid of who performed an operation on the    
 *                                            service record    
 * @param   saveType                          What operation was performed    
 * @param   state                             What state was the record left in
 * @returns recordID                          Record ID of the new audit log entry    
 ***************************************************************************/    

declare @submitClaims as bit
declare @submitClaimsEffectiveDate as DATETIME
declare @parentConsentMCAL as bit
declare @parentConsentMCALEffectiveDate as DATETIME
declare @parentConsentOHCI as bit
declare @parentConsentOHCIEffectiveDate as DATETIME 

select top 1

@submitClaims = SUBMIT_CLAIMS
, @submitClaimsEffectiveDate = submitClaimsEffectiveDate
, @parentConsentMCAL = parentConsentMCAL
, @parentConsentMCALEffectiveDate = parentConsentMCALEffectiveDate
, @parentConsentOHCI = parentConsentOHCI
, @parentConsentOHCIEffectiveDate = parentConsentOHCIEffectiveDate

from dbo.PATIENTS_Patient

where 

(PATIENT_ID = @patrecID)   
    
SET NOCOUNT ON    
    
INSERT INTO dbo.PATIENTS_AUDIT_LOG    
  (patRecID, loggedOn, userID, saveType, state, submitClaims, submitClaimsEffectiveDate, parentConsentMCAL, parentConsentMCALEffectiveDate, parentConsentOHCI, parentConsentOHCIEffectiveDate, reason)    
VALUES    
  (@patRecID, @loggedOn, @userID, @saveType, @state, @submitClaims, @submitClaimsEffectiveDate, @parentConsentMCAL, @parentConsentMCALEffectiveDate, @parentConsentOHCI, @parentConsentOHCIEffectiveDate, @reason)    
      
SET @recordID = SCOPE_IDENTITY()    
    
RETURN(0)    
    
END    
GO

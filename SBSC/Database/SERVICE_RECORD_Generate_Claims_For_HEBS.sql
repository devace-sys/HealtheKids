USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Generate_Claims_For_HEBS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Generate_Claims_For_HEBS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Generate_Claims_For_HEBS]     
 (@userID        INT   = null,    
  @clientID      INT   = null,     
  @validateRec   BIT   = 1    
  )    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_Generate_Claims_For_HEBS */    
/**    
 * Outputs a list of claim records to send to HEBS for billing submission    
 * and updates all related Spedcare records appropriately.    
 *    
 * @param   userID          Spedcare userID recordID    
 * @param   clientID        Client's record id, null for all    
 * @param   validateRec     1 = Produces records     
 *                          0 = Produces records and updates Spedcare    
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @today    AS DATETIME    
DECLARE @TranOpen AS INT    
SET     @TranOpen = 0    
SET     @today    = GETDATE()    
    
BEGIN TRY    
    
IF @userID IS NULL RAISERROR ('You MUST provide a user id',   11, 1)    
IF @clientID = 112 RAISERROR ('Client id is a test district', 11, 1)    
    
/*-------------------------------    
 * Perform some initial cleanup    
 *------------------------------*/    
    
IF (object_id('#temp_hebs_claim_export_svc_rec_ids') IS NOT NULL)    
BEGIN    
  DROP TABLE #temp_hebs_claim_export_svc_rec_ids    
END    
    
IF (object_id('#temp_hebs_claim_export_claim_rec_ids') IS NOT NULL)    
BEGIN    
  DROP TABLE #temp_hebs_claim_export_claim_rec_ids    
END    
    
/*-------------------------------    
 * Collect all service records    
 * that can be submitted    
 * The submission criteria is    
 *   - patient is eligible    
 *   - the client is not a test client    
 *   - the patient has a bic    
 *------------------------------*/    
     
SELECT *     
INTO      #temp_hebs_claim_export_svc_rec_ids    
FROM    
  (SELECT sr.id,     
         sr.clientID,    
         sr.patID,    
         sr.dos,     
         sr.svcType,     
         sr.claimID1,     
         sr.claimID2,    
         dbo.PAT_DOS_ELIGIBILITY(    
           sr.dos,    
           peg.MEDS_CURRENT,    
           peg.CURRENT_MONTH_ELIGIBILITY,    
           peg.JAN_ELIGIBILITY_INDICATOR,    
           peg.FEB_ELIGIBILITY_INDICATOR,    
           peg.MAR_ELIGIBILITY_INDICATOR,    
           peg.APR_ELIGIBILITY_INDICATOR,    
           peg.MAY_ELIGIBILITY_INDICATOR,    
           peg.JUN_ELIGIBILITY_INDICATOR,    
           peg.JUL_ELIGIBILITY_INDICATOR,    
           peg.AUG_ELIGIBILITY_INDICATOR,    
           peg.SEP_ELIGIBILITY_INDICATOR,    
           peg.OCT_ELIGIBILITY_INDICATOR,    
           peg.NOV_ELIGIBILITY_INDICATOR,    
           peg.DEC_ELIGIBILITY_INDICATOR)        AS elgFlag,     
           LTRIM(RTRIM(ISNULL(BIC,'')))          AS BIC,     
           sr.numMins                            AS numMins     
  FROM      SERVICE_RECORDS                      AS sr    
  JOIN      PATIENTS_Patient                     AS p   ON p.PATIENT_ID   = sr.patID    
  
   join SERVICE_RECORD_CLAIMS				 as src on src.svcRecID = sr.id
   join CLAIM_Claim							 as cc on src.claimID = cc.CLAIM_ID
   join CLAIM_Procedures					 as cp on cc.PROCEDURE_ID = cp.PROCEDURE_ID and cp.PUT_IN_837 = 1
  
  
  LEFT JOIN PATIENTS_Eligibility                 AS peg ON peg.PATIENT_ID = sr.patID
                             
  WHERE  (claimID1 IS NOT NULL)                                 AND    
         (sr.state   = dbo.CONST_SVC_REC_STATE_NEW()               OR    
          sr.state   = dbo.CONST_SVC_REC_STATE_MOD())              AND    
         ((@clientID IS NULL) OR (clientID = @clientID))        AND    
         (clientID <> 112)                                   AND    --not spedcare USD
         (clientID <> 34)    
  ) AS q1    
WHERE    
  (elgFlag = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
  (len(BIC) = 14)     
    
/*-------------------------------    
 * From this list collect all of    
 * the claim records    
 *------------------------------*/    
    
SELECT q1.id AS id, q1.svcType as svcType, q1.numMins as numMins     
INTO #temp_hebs_claim_export_claim_rec_ids    
FROM    
  (SELECT claimID1 as id, svcType, numMins     
   FROM #temp_hebs_claim_export_svc_rec_ids     
   WHERE (claimID1 IS NOT NULL)    
   UNION    
   SELECT claimID2 as id, svcType, numMins      
   FROM #temp_hebs_claim_export_svc_rec_ids     
   WHERE (claimID2 IS NOT NULL)) AS q1    
    
/*-------------------------------    
 * If allowed, write changes to    
 * the database    
 *------------------------------*/    
    
IF (@validateRec = 0)    
BEGIN    
  BEGIN TRANSACTION    
    SET @TranOpen = 1    
    
    /*-------------------------------    
     * Update service record status    
  * to indicate that the service    
  * record's claims have been    
  * submitted for billing    
     *------------------------------*/    
      
     UPDATE sr     
          SET sr.state = dbo.CONST_SVC_REC_STATE_SUB()    
     FROM SERVICE_RECORDS                     AS sr    
     JOIN #temp_hebs_claim_export_svc_rec_ids AS sre ON sre.id = sr.id    
     
    /*-------------------------------    
     * Update claim records status    
  * to indicate that the claim    
  * has been submitted for billing    
     *------------------------------*/    
          
     UPDATE cr    
          SET cr.STATUS = dbo.CONST_CLAIM_STATUS_SUB_PENDING()    
     FROM CLAIM_Claim                           AS cr    
     JOIN #temp_hebs_claim_export_claim_rec_ids AS cre ON cre.id = cr.CLAIM_ID    
         
    /*-------------------------------    
     * Update service records audit    
     * log    
     *------------------------------*/    
    
     INSERT INTO dbo.SERVICE_RECORDS_AUDIT_LOG(svcRecID,    
                                               loggedOn,    
                                               userID,    
                                               state)    
     SELECT     
       id                            AS svcRecID,     
       @today                        AS loggedOn,     
       @userID                       AS userID,     
       dbo.CONST_SVC_REC_STATE_SUB() AS state     
     FROM     
       #temp_hebs_claim_export_svc_rec_ids    
         
  COMMIT TRANSACTION    
  SET @TranOpen = 0    
END    
    
/*-------------------------------    
 * Output all claim records    
 * Note: Tweak to fit    
 *------------------------------*/    
    
SELECT cr.*, cre.*      
FROM CLAIM_CLAIM                           AS cr    
JOIN #temp_hebs_claim_export_claim_rec_ids AS cre ON cre.id = cr.CLAIM_ID    
    
RETURN(1)    
    
END TRY    
    
/******************************************    
 * If we end up here something went wrong.    
 * Cancel any pending transactions and    
 * return any error messages to the caller    
 ******************************************/    
    
BEGIN CATCH    
  -- Error or raise error with severity 11 to 19 will be caught here    
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
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

use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Claims_Generate_Claims_For_Transmission') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE Claims_Generate_Claims_For_Transmission
GO


CREATE PROCEDURE Claims_Generate_Claims_For_Transmission
 (@userID        INT   = null,    
  @clientID      INT   = null,     
  @validateRec   BIT   = 1    
  )
AS
BEGIN


SET NOCOUNT ON    
    
/* TODO: This sproc is deprecated now that we're running transmission off generation-level stuff; look at dependencies to see what else uses this */
    
    
DECLARE @today    AS DATETIME    
DECLARE @TranOpen AS INT    
SET     @TranOpen = 0    
SET     @today    = GETDATE()    
    
 
    
BEGIN TRY    
    
IF @userID IS NULL RAISERROR ('You MUST provide a user id',   11, 1)    
IF @clientID = 112 RAISERROR ('Client id is a test district', 11, 1)    
    
/*-------------------------------    
 * Perform some initial cleanup    
 *
 * NB: object_id() uses current database 
 * and default schema if not explicitly implied.
 * Using 'tempdb..(temp_table_name)'
 * for detecting already-existing temporary tables
 * uses proper namespace and won't throw errors 
 * when checking in Spedmon database.
 *------------------------------*/    
    
IF (object_id('tempdb..#temp_hebs_claim_export_svc_rec_ids') IS NOT NULL)    
BEGIN    
  DROP TABLE #temp_hebs_claim_export_svc_rec_ids    
END    
    
IF (object_id('tempdb..#temp_hebs_claim_export_claim_rec_ids') IS NOT NULL)    
BEGIN    
  DROP TABLE #temp_hebs_claim_export_claim_rec_ids    
END    

select distinct CLAIM_ID into #temp_hebs_claim_export_claim_rec_ids from 		
        
 dbo.CLAIMS_TRANSMISSION_LIST_VIEW( @clientid,  dbo.CALC_OLDEST_DOS_ALLOWED(@today), @today, @today  )
    
/*-------------------------------    
 * Output all claim records with additional svc. rec. data   
 * Note: Tweak to fit    
 *------------------------------*/    
    

SELECT cre.claim_id--, cr.patient_id, cr.procedure_id, cr.practitioner_id, cr.user_id, cr.client_id, cr.status, cr.line_number, cr.service_date, cr.service_units, cr.entry_date, cr.last_updated, cr.batch_number, cr.ELIGIBILE, cr.eligibility_confirmed, cr.transmit, cr.paper_claim_number, cr.group_id, cr.site_id, cr.has_proxy, cr.reference_claim_id_1, cr.reference_claim_id_2, sr.id, sr.svctype, sr.nummins
FROM #temp_hebs_claim_export_claim_rec_ids	AS cre



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
 
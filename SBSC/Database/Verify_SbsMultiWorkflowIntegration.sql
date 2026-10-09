/*
 * Verify_SbsMultiWorkflowIntegration.sql
 *
 * Run against SPEDMON (same database SpEdCare / Workflow use for batches).
 * Confirms: batch-save proc is installed, webuser can execute it, INPUT_BATCHES
 * naming matches the SBS reference contract used by
 * SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc (File_Name = @reference + '.pdf').
 *
 * SpEdCare screen: SBSC/Site/sbs_all_svcrec_save_batch_multi_prac_pat_dos_svc.aspx
 * WebMethod: servicerecords.asmx/savesvcrecsbatchmultipracpatdossvc
 *
 * ASMX role gate (see MBA/AppFramework/Constants.cs ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC):
 *   admin, client consultant, work leader, input staff, lea input staff, lea coordinator,
 *   lea provider, cybhi coordinator — same array used for savesvcrecsbatchmultipracpatdossvc
 *   and related endpoints in servicerecords.asmx.cs.
 *
 * Note: getStoredFileWorkFlowURL uses ROLE_SBS_ALL_LEA_COORD_AND_ASSIST (batch PDF preview);
 *   if preview fails for a role that can save, check that role list separately.
 */

USE SPEDMON;
GO

SET NOCOUNT ON;

PRINT '--- 1. Stored procedure exists ---';
IF OBJECT_ID(N'dbo.SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc', N'P') IS NOT NULL
    PRINT 'OK: dbo.SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc';
ELSE
    RAISERROR('FAIL: dbo.SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc not found. Run install.sql / SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc.sql.', 16, 1);
GO

SET NOCOUNT ON;

PRINT '--- 2. EXECUTE granted to webuser (if principal exists) ---';
IF DATABASE_PRINCIPAL_ID(N'webuser') IS NOT NULL
BEGIN
    IF EXISTS (
        SELECT 1
        FROM sys.database_permissions dp
        INNER JOIN sys.objects o ON dp.major_id = o.object_id
        INNER JOIN sys.database_principals pr ON dp.grantee_principal_id = pr.principal_id
        WHERE o.object_id = OBJECT_ID(N'dbo.SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc')
          AND pr.name = N'webuser'
          AND dp.permission_name = N'EXECUTE'
          AND dp.state = N'G'
    )
        PRINT 'OK: EXECUTE on batch proc granted to webuser';
    ELSE
        PRINT 'WARN: webuser exists but no EXECUTE grant on SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc';
END
ELSE
    PRINT 'SKIP: database principal webuser not found on this database';
GO

SET NOCOUNT ON;

PRINT '--- 3. INPUT_BATCHES sample (File_Name must equal reference typed in UI + ''.pdf'') ---';
IF OBJECT_ID(N'dbo.INPUT_BATCHES', N'U') IS NOT NULL
BEGIN
    SELECT TOP 10
          ib.id
        , ib.ClientID
        , ib.File_Name
        , LEFT(ib.File_Name, LEN(ib.File_Name) - 4) AS ReferenceValueForSpEdCareUi
    FROM dbo.INPUT_BATCHES AS ib
    ORDER BY ib.id DESC;
END
ELSE
    PRINT 'WARN: dbo.INPUT_BATCHES not found';
GO

SET NOCOUNT ON;

PRINT '--- 4. Negative contract check (no INPUT_BATCHES row = proc would RAISERROR) ---';
DECLARE @badref VARCHAR(500) = N'__VERIFY_SBS_MULTI_NO_SUCH_BATCH__';
IF NOT EXISTS (
    SELECT 1
    FROM dbo.INPUT_BATCHES AS ib
    WHERE ib.File_Name = @badref + N'.pdf'
)
    PRINT 'OK: bogus reference has no INPUT_BATCHES row (matches proc guard before save)';
ELSE
    PRINT 'UNEXPECTED: test reference matched a batch row';
GO

SET NOCOUNT ON;

PRINT '--- Done ---';
GO

/*
 * --- Manual E2E (SpEdCare UI) — run in browser when environment is available ---
 *
 * 1. In Workflow / INPUT_BATCHES, pick a batch; note ClientID and File_Name (e.g. ABC123.pdf).
 * 2. Open sbs_all_svcrec_save_batch_multi_prac_pat_dos_svc.aspx (Production menu for roles with access).
 * 3. Set reference to basename only: same as File_Name without .pdf (matches proc: @reference + '.pdf').
 * 4. Select the same client as the batch row; add grid rows; Finalize / validate per your process.
 * 5. Confirm service rows created; confirm WIP save point cleared after successful finalize (uses requestresource / WIP delete in ServiceRecords.saveSvcRecsBatchMultiPracPatDosSvc).
 *
 * --- Manual negative (expect save failure) ---
 *
 * 1. Use reference that does not match any INPUT_BATCHES.File_Name (after appending .pdf).
 *    Expected SQL error text: "Reference document file not found in Input Batches"
 * 2. Or use valid reference but wrong client vs batch ClientID.
 *    Expected: "Client ID mismatch between reference file and service record"
 */

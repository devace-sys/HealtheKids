USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 * TODO: Here for cleanup
 * remove later.
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_Batch_Group_Service') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save_Batch_Group_Service
GO

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'SvcDetailsPatientGroup')
DROP TYPE SvcDetailsPatientGroup
GO


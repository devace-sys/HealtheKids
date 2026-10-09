USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 * TODO: Here for cleanup
 * remove later.
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_Batch_One_On_One') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save_Batch_One_On_One
GO

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'SvcDetailsOneOnOne')
DROP TYPE SvcDetailsOneOnOne
GO

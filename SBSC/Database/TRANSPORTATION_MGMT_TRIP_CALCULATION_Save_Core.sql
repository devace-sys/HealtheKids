USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 * TODO: Remove once no longer
 * needed for cleanup
 *------------------------------*/
                                                                      
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_TRIP_CALCULATION_Save_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_TRIP_CALCULATION_Save_Core
GO

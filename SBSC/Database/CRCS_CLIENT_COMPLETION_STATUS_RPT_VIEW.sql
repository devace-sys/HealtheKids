USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_CLIENT_COMPLETION_STATUS_RPT_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_CLIENT_COMPLETION_STATUS_RPT_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CRCS_CLIENT_COMPLETION_STATUS_RPT_VIEW] (
         @userID            BigInt    
	   , @userGroup         Int    
	   , @userRank          Int 
	   , @fiscalYearID      Bigint
	   , @recID             Bigint
)    

RETURNS TABLE

AS RETURN (

	 select
	      ROW_NUMBER() OVER (
			ORDER BY ccal.CLIENT_NAME
		  ) rowNumber
		, clientName = ccal.CLIENT_NAME
		, ccsv.crcsPracSalariesCompletedQ1
		, ccsv.crcsPracSalariesCompletedQ2
		, ccsv.crcsPracSalariesCompletedQ3
		, ccsv.crcsPracSalariesCompletedQ4
		, ccsv.crcsPracSalariesCompleted
		, ccsv.crcsOtherCostsCompleted
		, ccsv.crcsContractorCostsCompleted
		, ccsv.crcsMedEquipmentDepreciationCostsCompleted
		, ccsv.crcsTransportationPersonnelCostsCompleted
		, ccsv.crcsTransportationOtherCostsCompleted
		, ccsv.crcsTransportationEquipmentDepreciationCostsCompleted
		, ccsv.crcsTransportationCompleted
		, ccsv.crcsProgramInfoCompleted
	 from dbo.CLIENTS_Client_Active_LEA as ccal
	 cross apply [dbo].[CRCS_COMPLETION_STATUS_VIEW] (ccal.CLIENT_ID, @fiscalYearID) as ccsv
)
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_CLIENT_COMPLETION_STATUS_RPT_VIEW] TO [webuser]
GO  

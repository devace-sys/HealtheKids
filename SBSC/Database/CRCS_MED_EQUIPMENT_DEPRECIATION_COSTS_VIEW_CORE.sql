USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_VIEW_CORE] ( 
	     @clientID          Bigint 
	   , @fiscalYearID      Bigint
	   , @active            Bit
	   , @recID             Bigint   
)
     
RETURNS TABLE  

AS RETURN(

  select 
		  cdc.*
		, placedInServiceOnStr       = dbo.RPT_DATE_FMT(cdc.placedInServiceOn)
		, placedInServiceOnStrYMD    = dbo.RPT_DATE_FMT_YYYY_MM_DD(cdc.placedInServiceOn)
		, placedOutOfServiceOnStr    = dbo.RPT_DATE_FMT(cdc.placedOutOfServiceOn)
		, placedOutOfServiceOnStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(cdc.placedOutOfServiceOn)

  from dbo.CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS as cdc
  where (cdc.clientID = @clientID)
    and (cdc.fiscalYearID = @fiscalYearID)
    and ((@recID  is null) or (cdc.id     = @recID))
	and ((@active is null) or (cdc.active = @active))
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_VIEW_CORE] TO [webuser]
GO
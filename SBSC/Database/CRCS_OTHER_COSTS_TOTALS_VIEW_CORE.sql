USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_OTHER_COSTS_TOTALS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_OTHER_COSTS_TOTALS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_OTHER_COSTS_TOTALS_VIEW_CORE] ( 
	   @clientID          BigInt    
	 , @fiscalYearID      BigInt
)
     
RETURNS TABLE  

AS RETURN (
	select
		clientID     = @clientID
	  ,	fiscalYearID = @fiscalYearID
	  , materialsAndSupplies    = isnull(coc.materialsAndSupplies	, 0)
	  , nonCapitalizedEquipment = isnull(coc.nonCapitalizedEquipment, 0)
	  , travelAndConference     = isnull(coc.travelAndConference	, 0)
	  , duesAndMembership       = isnull(coc.duesAndMembership		, 0)
	  , communications          = isnull(coc.communications			, 0)
	  , otherFederalCosts		= isnull(coc.otherFederalCosts   	, 0)
	  , federalResourceCodes    = isnull(coc.federalResourceCodes   , '')
	  , cgd.displayOrder
	  , cgd.grpSvcClassNameID  
	  , grpSvcClassName = ggsvc.GROUP_SERVICE_CLASS_NAME
	from dbo.CRCS_GROUPS_DISPLAY_ORDER as cgd
	left join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as ggsvc on ggsvc.GROUP_SERVICE_CLASS_NAME_ID = cgd.grpSvcClassNameID
	left join dbo.CRCS_OTHER_COSTS_VIEW_CORE ( 
			  @clientID           
			, @fiscalYearID      
			, null             
	) as coc on coc.grpSvcClassNameID = cgd.grpSvcClassNameID
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_OTHER_COSTS_TOTALS_VIEW_CORE] TO [webuser]
GO
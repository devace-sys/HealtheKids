USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_CONTRACTOR_COSTS_TOTALS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_CONTRACTOR_COSTS_TOTALS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_CONTRACTOR_COSTS_TOTALS_VIEW_CORE] ( 
	   @clientID          BigInt    
	 , @fiscalYearID      BigInt
)
     
RETURNS TABLE  

AS RETURN (
	With otherCostsCTE as (
		select
			  grpSvcClassNameID
			, contractorCosts5800 = sum(iif(isnull(cc.contractorCosts5800, 0) <= 25000, isnull(cc.contractorCosts5800, 0), 25000))
			, contractorCosts5100 = sum(cc.contractorCosts5100) + sum(iif(cc.contractorCosts5800 > 25000, cc.contractorCosts5800 - 25000, 0))
			, federalResourceAmounts = sum(cc.federalResourceAmounts)
			, avgContractRatePerHour = avg(cc.contractRatePerHour)
			, hoursPaid = iif (isnull(avg(cc.contractRatePerHour), 0) = 0
				 , 0
				 , (
					    sum(iif(isnull(cc.contractorCosts5800, 0) <= 25000, isnull(cc.contractorCosts5800, 0), 25000))
					 + (sum(cc.contractorCosts5100)+ sum(iif(cc.contractorCosts5800 > 25000, cc.contractorCosts5800 - 25000, 0)))
				  ) / avg(cc.contractRatePerHour)
			)
		from dbo.CRCS_CONTRACTOR_COSTS_VIEW_CORE (
			  @clientID    
			, @fiscalYearID
			, null       
		) as cc
		where employeeRelationshipID = 20
		group by grpSvcClassNameID

	)

	select
		clientID     = @clientID
	  ,	fiscalYearID = @fiscalYearID
	  , cgd.displayOrder
	  , cgd.grpSvcClassNameID  
	  , grpSvcClassName        = ggsvc.GROUP_SERVICE_CLASS_NAME
	  , contractorCosts5800    = isnull(oc.contractorCosts5800, 0)
	  , contractorCosts5100    = isnull(oc.contractorCosts5100, 0)
	  , federalResourceAmounts = isnull(oc.federalResourceAmounts, 0)
	  , hoursPaid			   = isnull(oc.hoursPaid, 0)
	  , avgContractRatePerHour = isnull(oc.avgContractRatePerHour, 0)
	from dbo.CRCS_GROUPS_DISPLAY_ORDER as cgd
	left join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as ggsvc on ggsvc.GROUP_SERVICE_CLASS_NAME_ID = cgd.grpSvcClassNameID
	left join otherCostsCTE as oc on oc.grpSvcClassNameID = cgd.grpSvcClassNameID
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_CONTRACTOR_COSTS_TOTALS_VIEW_CORE] TO [webuser]
GO
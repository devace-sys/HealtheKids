USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_COMPLETION_TOTALS_RPT_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_COMPLETION_TOTALS_RPT_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_COMPLETION_TOTALS_RPT_VIEW] ( 
	     @userID            BigInt    
	   , @userGroup         Int    
	   , @userRank          Int 
	   , @clientID          BigInt 
	   , @fiscalYearID      Bigint
	   , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN (	
	with cte_salaryOtherContractorTotals as (
		select
			rowNumber = row_number() over (order by cgd.displayOrder)
		  ,	cgd.displayOrder
		  ,	grpSvcClassName = ggsvc.GROUP_SERVICE_CLASS_NAME

		  , salary1		          = cps1.salary
          , salaryExpenditures1   = cps1.salaryExpenditures         
		  , benefits1	          = cps1.benefits	
          , benefitExpenditures1  = cps1.benefitExpenditures          
		  , federalRevenues1      = cps1.federalRevenues
		  , federalResourceCodes1 = cps1.federalResourceCodes
			 
		  , salary2		          = cps2.salary
          , salaryExpenditures2   = cps2.salaryExpenditures         
		  , benefits2	          = cps2.benefits	
          , benefitExpenditures2  = cps2.benefitExpenditures           
		  , federalRevenues2      = cps2.federalRevenues
		  , federalResourceCodes2 = cps2.federalResourceCodes
			 
		  , salary3		          = cps3.salary
          , salaryExpenditures3   = cps3.salaryExpenditures         
		  , benefits3	          = cps3.benefits	
          , benefitExpenditures3  = cps3.benefitExpenditures        
		  , federalRevenues3      = cps3.federalRevenues
		  , federalResourceCodes3 = cps3.federalResourceCodes
			 
		  , salary4		          = cps4.salary
          , salaryExpenditures4   = cps4.salaryExpenditures         
		  , benefits4	          = cps4.benefits	
          , benefitExpenditures4  = cps4.benefitExpenditures            
		  , federalRevenues4      = cps4.federalRevenues
		  , federalResourceCodes4 = cps4.federalResourceCodes

		  , coc.materialsAndSupplies
		  , coc.nonCapitalizedEquipment
		  , coc.travelAndConference
		  , coc.duesAndMembership
		  , coc.communications
		  , coc.otherFederalCosts
		  , otherFederalResourceCodes = coc.federalResourceCodes

		  , ccc.contractorCosts5800
		  , ccc.contractorCosts5100
		  , ccc.federalResourceAmounts
		  , ccc.hoursPaid
		  , ccc.avgContractRatePerHour
		from dbo.CRCS_GROUPS_DISPLAY_ORDER											   as cgd
		join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES									   as ggsvc on ggsvc.GROUP_SERVICE_CLASS_NAME_ID = cgd.grpSvcClassNameID
		left join dbo.CRCS_PRAC_SALARIES_TOTALS_VIEW_CORE(@clientID, @fiscalYearID, 1) as cps1 on cps1.grpSvcClassNameID = cgd.grpSvcClassNameID
		left join dbo.CRCS_PRAC_SALARIES_TOTALS_VIEW_CORE(@clientID, @fiscalYearID, 2) as cps2 on cps2.grpSvcClassNameID = cgd.grpSvcClassNameID
		left join dbo.CRCS_PRAC_SALARIES_TOTALS_VIEW_CORE(@clientID, @fiscalYearID, 3) as cps3 on cps3.grpSvcClassNameID = cgd.grpSvcClassNameID
		left join dbo.CRCS_PRAC_SALARIES_TOTALS_VIEW_CORE(@clientID, @fiscalYearID, 4) as cps4 on cps4.grpSvcClassNameID = cgd.grpSvcClassNameID
              -- look into this one

		left join dbo.CRCS_OTHER_COSTS_TOTALS_VIEW_CORE(@clientID, @fiscalYearID)      as coc on coc.grpSvcClassNameID = cgd.grpSvcClassNameID
		left join dbo.CRCS_CONTRACTOR_COSTS_TOTALS_VIEW_CORE(@clientID, @fiscalYearID) as ccc on ccc.grpSvcClassNameID = cgd.grpSvcClassNameID
              -- look into this one
	)
	, cte_MedEqDepTotals as (
		select 
			rowNumber = row_number() over (order by med.assetID)
		    , *
		from dbo.CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_VIEW_CORE (
				 @clientID       
			   , @fiscalYearID   
			   , 1         
			   , null          
		) as med

	)
	, cte_TransPersonnel as (
		select 
			rowNumber = row_number() over (order by pers.displayOrder)
		  , *
		from dbo.CRCS_TRANSPORTATION_PERSONNEL_COSTS_VIEW_CORE (
				  @clientID       
				, @fiscalYearID   
				, 1         
				, null          
		) as pers
	)
	, cte_TransOther as (
		select 
			rowNumber = row_number() over (order by other.displayOrder)
		  , *
		from dbo.CRCS_TRANSPORTATION_OTHER_COSTS_VIEW_CORE (
              @clientID       
			, @fiscalYearID   
			, 1         
			, null                
		) as other
	)
	, cte_TransMedEqDep as (
		select 
			rowNumber = row_number() over (order by eqDep.assetID)
			, *
		from dbo.CRCS_TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_VIEW_CORE ( 
              @clientID       
			, @fiscalYearID   
			, 1         
			, null                
		) as eqDep
	)
	select 		  
	    	soc.displayOrder
		  ,	soc.grpSvcClassName
          , seperator = ''

		  , soc.salary1		          
		  , soc.benefits1
		  , soc.salaryExpenditures1	          
		  , soc.benefitExpenditures1          
		  , totalOtherCosts1 = ''
		  , soc.federalRevenues1
		  , soc.federalResourceCodes1
		  , netPersonalCosts1 = ''

		  , soc.salary2		          
		  , soc.benefits2	
		  , soc.salaryExpenditures2	          
		  , soc.benefitExpenditures2        
		  , totalOtherCosts2 = ''
		  , soc.federalRevenues2
		  , soc.federalResourceCodes2
		  , netPersonalCosts2 = ''

		  , soc.salary3		          
		  , soc.benefits3	 
		  , soc.salaryExpenditures3          
		  , soc.benefitExpenditures3        
		  , totalOtherCosts3 = ''
		  , soc.federalRevenues3
		  , soc.federalResourceCodes3
		  , netPersonalCosts3 = ''

		  , soc.salary4		          
		  , soc.benefits4	
		  , soc.salaryExpenditures4
		  , soc.benefitExpenditures4
		  , totalOtherCosts4 = ''
		  , soc.federalRevenues4
		  , soc.federalResourceCodes4
		  , netPersonalCosts4 = ''

		  , soc.materialsAndSupplies
		  , soc.nonCapitalizedEquipment
		  , soc.travelAndConference
		  , soc.duesAndMembership
		  , soc.communications
		  , soc.otherFederalCosts
		  , soc.otherFederalResourceCodes

		  , soc.contractorCosts5800
		  , soc.contractorCosts5100
		  , soc.federalResourceAmounts
		  , soc.hoursPaid
		  , soc.avgContractRatePerHour

		  , medEqAssetID                     = med.assetID
		  , medEqAssetType                   = med.assetType
		  , medEqPlacedInServiceOnStr        = med.placedInServiceOnStr
		  , medEqYearsUseful                 = med.yearsUseful
		  , medEqDepreciableCost             = med.depreciableCost
		  , medEqFedResourceOrGrant          = med.fedResourceOrGrant
		  , medEqResourceCodeAcctNum         = med.resourceCodeAcctNum
		  , medEqAnnualDepreciation          = med.annualDepreciation
		  , medEqRetiredDuringCostPeriod     = med.retiredDuringCostPeriod
		  , medEqPlacedOutOfServiceOnStr     = med.placedOutOfServiceOnStr
		  , medEqAccumulatedDepreciation     = med.accumulatedDepreciation
		  , medEqDepreciationForReportPeriod = med.depreciationForReportPeriod

		  , tPers.jobCategory
		  , tPers.totalSalaries
		  , tPers.salaryRatio
		  , tPers.totalBenefits
		  , tPers.benefitsRatio
		  , transPersonnelFedResourceOrGrant = tPers.fedResourceOrGrant
		  , tPers.federalRatio

		  , tOther.description
		  , tOther.grossCosts
		  , tOther.grossRatio
		  , tOther.expenditures
		  , tOther.expendituresRatio

		  , transMedEqAssetID                     = tMed.assetID
		  , transMedEqAssetType                   = tMed.assetType
		  , transMedEqPlacedInServiceOnStr        = tMed.placedInServiceOnStr
		  , transMedEqYearsUseful                 = tMed.yearsUseful
		  , transMedEqDepreciableCost             = tMed.depreciableCost
		  , transMedEqFedResourceOrGrant          = tMed.fedResourceOrGrant
		  , transMedEqAnnualDepreciation          = tMed.annualDepreciation
		  , transMedEqRetiredDuringCostPeriod     = tMed.retiredDuringCostPeriod
		  , transMedEqPlacedOutOfServiceOnStr     = tMed.placedOutOfServiceOnStr
		  , transMedEqAccumulatedDepreciation     = tMed.accumulatedDepreciation
		  , transMedEqDepreciationForReportPeriod = tMed.depreciationForReportPeriod
		  , transMedEqDepreciationForReportPeriodRatio = tMed.depreciationForReportPeriodRatio

	from cte_salaryOtherContractorTotals as soc
	full outer join cte_MedEqDepTotals as med    on med.rowNumber    = soc.rowNumber
	full outer join cte_TransPersonnel as tPers  on tPers.rowNumber   = soc.rowNumber
	full outer join cte_TransOther     as tOther on tOther.rowNumber = soc.rowNumber
	full outer join cte_TransMedEqDep  as tMed   on tMed.rowNumber   = soc.rowNumber



) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_COMPLETION_TOTALS_RPT_VIEW] TO [webuser]
GO
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_SALARIES_TOTALS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PRAC_SALARIES_TOTALS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_PRAC_SALARIES_TOTALS_VIEW_CORE] ( 
	   @clientID          BigInt    
	 , @fiscalYearID      BigInt
 	 , @quarterNumber	  Int
)
RETURNS TABLE  

AS RETURN (

	with cte_salariesTotals as (
		select 

    		salaryExpenditures   = sum(uc.fiscalquarterSalaryExpenditures_money)
      , benefitExpenditures  = sum(uc.fiscalquarterBenefitExpenditures_money)

			, salary               = sum(uc.salary)
			, benefits             = sum(uc.benefits)
			, federalSalary        = sum(federalSalary)
			, federalBenefits      = sum(uc.federalBenefits)
			, grpSvcClassNameIDVal = uc.grpSvcClassNameID

		from dbo.CRCS_PRAC_SALARIES_UNION_VIEW(@clientID, @fiscalYearID, null, @quarterNumber, 10) as uc
		group by uc.grpSvcClassNameID
	)
	-- this was needed in original formula, but DHCS wants each CRCS tab broken out into its own report
	-- use this if requirements change back to what they were originally	
	--, cte_otherCosts as (
	--	select
	--			  otherFederalCosts
	--			, federalResourceCodes             
	--			, grpSvcClassNameID    
	--			, grpSvcClassName      
	--	from dbo.CRCS_OTHER_COSTS_VIEW_CORE ( 
	--			  @clientID           
	--			, @fiscalYearID      
	--			, null             
	--	)		
	--)
	, cte_salaryResourceCodes as (
		select distinct
		      uc.federalSalaryResourceCode
			, uc.federalBenefitsResourceCode
			, grpSvcClassNameIDVal = uc.grpSvcClassNameID
		from dbo.CRCS_PRAC_SALARIES_UNION_VIEW(@clientID, @fiscalYearID, null, @quarterNumber, 10) as uc
	)
	, cte_federalResourceCodesUnion as (
		select 
			grpSvcClassNameID = sr.grpSvcClassNameIDVal
		  , federalResourceCode = sr.federalSalaryResourceCode
		from cte_salaryResourceCodes as sr
		union (
			select 
				grpSvcClassNameID = sr.grpSvcClassNameIDVal
			  , federalResourceCode = sr.federalBenefitsResourceCode
			from cte_salaryResourceCodes as sr
		)
		-- this was needed in original formula, but DHCS wants each CRCS tab broken out into its own report
		-- use this if requirements change back to what they were originally	
		--union (
		--	select 
		--		grpSvcClassNameID = oc.grpSvcClassNameID
		--	  , federalResourceCode = oc.federalResourceCodes
		--	from cte_otherCosts as oc
		--)
	)
	, cte_federalResourceCodes as (
		select 
			  federalResourceCodes = string_agg(fru.federalResourceCode, ' , ')
			, fru.grpSvcClassNameID
		from cte_federalResourceCodesUnion as fru
		group by fru.grpSvcClassNameID
	)
	select
		clientID     = @clientID
	  ,	fiscalYearID = @fiscalYearID
	  , cgd.displayOrder
	  , cgd.grpSvcClassNameID  
	  , grpSvcClassName = ggsvc.GROUP_SERVICE_CLASS_NAME

	  ,	salary  = isnull(tot.salary, 0)
	  , benefits = isnull(tot.benefits, 0)
 
	  ,	salaryExpenditures  = isnull(tot.salaryExpenditures, 0)
	  , benefitExpenditures = isnull(tot.benefitExpenditures, 0)    
    	
	  , federalRevenues = /*isnull(oc.otherFederalCosts, 0) + */ isnull(tot.federalSalary, 0) + isnull(tot.federalBenefits, 0) 
	  , fru.federalResourceCodes
	from dbo.CRCS_GROUPS_DISPLAY_ORDER as cgd
	--left join cte_otherCosts as oc on oc.grpSvcClassNameID = cgd.grpSvcClassNameID
	left join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as ggsvc on ggsvc.GROUP_SERVICE_CLASS_NAME_ID = cgd.grpSvcClassNameID
	left join cte_salariesTotals as tot on cgd.grpSvcClassNameID = tot.grpSvcClassNameIDVal
	left join cte_federalResourceCodes as fru on fru.grpSvcClassNameID = cgd.grpSvcClassNameID
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_PRAC_SALARIES_TOTALS_VIEW_CORE] TO [webuser]
GO
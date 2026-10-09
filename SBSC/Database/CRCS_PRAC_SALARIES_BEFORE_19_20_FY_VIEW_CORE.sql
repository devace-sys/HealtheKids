USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW_CORE
GO

/*****************************************************************************************************
* IMPORTANT
* 
* For employee relationship, we are NOT going based off "dbo.EMPLOYMENT_RELATIONSHIPS"
* Instead we have: 
*      10: Employee
*      20: Contractor
*      30: Not on TSP
*      40: Duplicate
******************************************************************************************************/

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW_CORE] ( 
	   @clientID          BigInt    
	 , @fiscalYearID      BigInt
	 , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN (

	with pracIDs as (
		select
			  pracID = clm.PRACTITIONER_ID
			, name = prp.CONCAT_NAME
			, TOTAL_AMOUNT_PAID          = sum(cca.AMOUNT_PAID)
   			, prp.employeeRelationshipID

		  from dbo.CLAIM_Claim               as clm
		  join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = clm.PRACTITIONER_ID
		  join dbo.PRACTITIONER_GROUPS       as pg  on pg.PRACTITIONER_ID  = prp.PRACTITIONER_ID
													and pg.GROUP_TYPE in (1,2)
		  join dbo.GROUP_Group               as gg  on gg.GROUP_ID = pg.GROUP_ID
		  join dbo.CLAIM_Claim_Adjudication  as cca on cca.CLAIM_ID        = clm.CLAIM_ID
		  left join dbo.COMPANY_FISCAL_YEARS as cfy on cfy.ID              = @fiscalYearID
   
		  where (
				(clm.CLIENT_ID = @clientID)
			and (clm.SERVICE_DATE between cfy.FY_START and cfy.FY_END)
			and (clm.[STATUS] = '3' /* Paid */)
			and (prp.employeeRelationshipID = 10 /* Employed */)
		  )
   
		  group by 
   
			  clm.PRACTITIONER_ID
			, prp.CONCAT_NAME
			, gg.GROUP_ID
			, gg.GROUP_NAME
			, prp.employeeRelationshipID
   
		  having
			sum(cca.AMOUNT_PAID) > 0			
	)

	select 
		  pracID                      = prids.pracID
		, clientID					  = @clientID
		, pracName                    = pr.CONCAT_NAME
		, pracTitle                   = g1.GROUP_NAME
		, employeeRelationshipID      = isnull(cps.employeeRelationshipID, 10)
 		, crcsPracticeFamilyName      = ggsvc.GROUP_SERVICE_CLASS_NAME
		, clientEmployeeID            = pr.clientEmployeeID
		, salary                      = cps.salary
		, federalSalary               = cps.federalSalary
		, federalSalaryResourceCode   = cps.federalSalaryResourceCode
		, benefits                    = cps.benefits
		, federalBenefits             = cps.federalBenefits
		, federalBenefitsResourceCode = cps.federalBenefitsResourceCode
		, grossAmount                 = FORMAT(isnull(cps.salary       , 0) + isnull(cps.benefits       , 0), 'C2')
		, grossFederalAmount          = FORMAT(isnull(cps.federalSalary, 0) + isnull(cps.federalBenefits, 0), 'C2')
		, fiscalYearID                = @fiscalYearID
  		, grpSvcClassNameID           = ggsvc.GROUP_SERVICE_CLASS_NAME_ID
		, grpSvcClassName  	          = ggsvc.GROUP_SERVICE_CLASS_NAME


    , fiscalyearSalaryExpenditures_money   =  CAST(
                                            isnull(cps.salary   ,  0)    + isnull(cps.federalSalary   ,  0)
                                            AS MONEY  -- should already be of type money; casting should be unnecessary
                                        )
    , fiscalyearBenefitExpenditures_money  =  CAST(
                                            isnull(cps.benefits ,  0)    + isnull(cps.federalBenefits ,  0)
                                            AS MONEY  -- should already be of type money; casting should be unnecessary
                                        )

	from pracIDs as prids
	join dbo.PRACTITIONER_Practitioner as pr on pr.PRACTITIONER_ID = prids.pracID
	join dbo.PRACTITIONER_GROUPS_VIEW_DISP()    as gd  on gd.PRACTITIONER_ID = pr.PRACTITIONER_ID
	join dbo.GROUP_GROUP                        as g1  on g1.GROUP_ID        = gd.GROUP_ID
	join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as ggsvcp on ggsvcp.GROUP_ID = g1.GROUP_ID  and ggsvcp.GROUP_SERVICE_CLASS_PARTITION_ID = 600
	join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as ggsvc on ggsvc.GROUP_SERVICE_CLASS_NAME_ID = ggsvcp.GROUP_SERVICE_CLASS_NAME_ID

	left join dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY as cps
	on (
		cps.pracID        = prids.pracID
	and cps.fiscalYearID  = @fiscalYearID 
	and isnull(cps.active, 1) != 0
	)
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW_CORE] TO [webuser]
GO
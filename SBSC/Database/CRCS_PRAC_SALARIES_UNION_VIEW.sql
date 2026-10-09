USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_SALARIES_UNION_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PRAC_SALARIES_UNION_VIEW
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

CREATE FUNCTION [dbo].[CRCS_PRAC_SALARIES_UNION_VIEW] (
	   @clientID			   BigInt
	 , @fiscalYearID		   BigInt
	 , @pracID                 BigInt
 	 , @quarterNumber	       Int
	 , @employeeRelationshipID Int
)

RETURNS TABLE

--

AS RETURN (

	with salariesCTE as (
		select
			    cps.salary
			  , cps.federalSalary

                          , cps.fiscalquarterSalaryExpenditures_money
                          , cps.fiscalquarterBenefitExpenditures_money

			  , cps.federalSalaryResourceCode
			  , cps.benefits
			  , cps.federalBenefits
			  , cps.federalBenefitsResourceCode
			  , cps.fiscalYearID
			  , cps.grpSvcClassNameID
			  , cps.grpSvcClassName
			  , cps.pracID
			  , cps.employeeRelationshipID

			  -- , IIF( @pracID IS NULL OR @quarterNumber IS NULL, null, cps.hoursWorkedThisQuarter)  hoursWorkedThisQuarter

		from dbo.CRCS_PRAC_SALARIES_VIEW_CORE (

			  @clientID
			, @fiscalYearID
			, @quarterNumber
			, null
		) as cps
		where (
			  (@fiscalYearID > 26)
		  and ((@employeeRelationshipID is null) or (cps.employeeRelationshipID = @employeeRelationshipID))
		  and ((@pracID is null) or (cps.pracID = @pracID))

          -- commenting this
		  -- and (cps.pracCanHaveCostsEntered = 1)

		)
	)
	, salariesBefore1920FYCTE as (
		select
			    cps2.salary
			  , cps2.federalSalary


        , cps2.fiscalyearSalaryExpenditures_money
        , cps2.fiscalyearBenefitExpenditures_money

			  , cps2.federalSalaryResourceCode
			  , cps2.benefits
			  , cps2.federalBenefits
			  , cps2.federalBenefitsResourceCode
			  , cps2.fiscalYearID
			  , cps2.grpSvcClassNameID
			  , cps2.grpSvcClassName
			  , cps2.pracID
			  , cps2.employeeRelationshipID

			  -- , null hoursWorkedThisQuarter --, hoursWorkedThisQuarter = 0

		from dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW_CORE (
			  @clientID
			, @fiscalYearID
			, null
		) as cps2
		where (
			(@fiscalYearID <= 26)
		and ((@employeeRelationshipID is null) or (cps2.employeeRelationshipID = @employeeRelationshipID))
		and ((@pracID is null) or (cps2.pracID = @pracID))
		)
	)

	select * from salariesCTE
	union all (
	select * from salariesBefore1920FYCTE
	)



)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CRCS_PRAC_SALARIES_UNION_VIEW] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_COMPLETION_STATUS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_COMPLETION_STATUS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CRCS_COMPLETION_STATUS_VIEW] (
    @clientID            BIGINT
  , @fiscalYearID        BIGINT
)

RETURNS TABLE

AS RETURN (

	 /***************************************************************************
	  * CRCS_COMPLETION_STATUS_VIEW */
	 /**
	  ***************************************************************************/
	With Salary_cte as (
	   SELECT
			crcsPracSalariesCompletedQ1 = iif(
			  (
			   not exists (

			   SELECT top 1 pracID
			   from dbo.CRCS_PRAC_SALARIES_VIEW_CORE (
				  @clientID
				, @fiscalYearID
				, 1
				, null
			   ) where (employeeRelationshipID = 10 -- employee

				    and pracCanHaveCostsEntered = 1
                    -- don't know if this should be changed
 
					and isnull(salary, 0) = 0
			   )
			   )

			   or exists (

			   SELECT top 1 ccc.id
			   from dbo.CRCS_CATEGORY_COMPLETED as ccc
			   where (ccc.clientID      = @clientID
				  and ccc.fiscalYearID  = @fiscalYearID
				  and ccc.quarterNumber = 1
				  and ccc.completed     = 1
				  and ccc.active        = 1
			   )
			   )
			   )
			   , 1, 0)

			, crcsPracSalariesCompletedQ2 = iif(
			  (
			   not exists (

			   SELECT top 1 pracID
			   from dbo.CRCS_PRAC_SALARIES_VIEW_CORE (
				  @clientID
				, @fiscalYearID
				, 2
				, null
			   ) where (employeeRelationshipID = 10 -- employee

				    and pracCanHaveCostsEntered = 1
                    -- don't know if this should be changed

					and isnull(salary, 0) = 0
			   )
			   )

			   or exists (

			   SELECT top 1 ccc.id
			   from dbo.CRCS_CATEGORY_COMPLETED as ccc
			   where (ccc.clientID      = @clientID
				  and ccc.fiscalYearID  = @fiscalYearID
				  and ccc.quarterNumber = 2
				  and ccc.completed     = 1
				  and ccc.active        = 1
			   )
			   )
			   )
			   , 1, 0)


			, crcsPracSalariesCompletedQ3 = iif(
			 (
			  not exists (

			   SELECT top 1 pracID
			   from dbo.CRCS_PRAC_SALARIES_VIEW_CORE (
				  @clientID
				, @fiscalYearID
				, 3
				, null
			   ) where (employeeRelationshipID = 10 -- employee

				    and pracCanHaveCostsEntered = 1
                    -- don't know if this should be changed

					and isnull(salary, 0) = 0
			   )
			   )

			   or exists (

			   SELECT top 1 ccc.id
			   from dbo.CRCS_CATEGORY_COMPLETED as ccc
			   where (ccc.clientID      = @clientID
				  and ccc.fiscalYearID  = @fiscalYearID
				  and ccc.quarterNumber = 3
				  and ccc.completed     = 1
				  and ccc.active        = 1
			   )
			   )
			   )
			   , 1, 0)

			, crcsPracSalariesCompletedQ4 = iif(
			  (
			   not exists (

			   SELECT top 1 pracID
			   from dbo.CRCS_PRAC_SALARIES_VIEW_CORE (
				  @clientID
				, @fiscalYearID
				, 4
				, null
			   ) where (employeeRelationshipID = 10 -- employee

				    and pracCanHaveCostsEntered = 1
                    -- don't know if  this should be changed

					and isnull(salary, 0) = 0
			   )
			   )

			   or exists (

			   SELECT top 1 ccc.id
			   from dbo.CRCS_CATEGORY_COMPLETED as ccc
			   where (ccc.clientID      = @clientID
				  and ccc.fiscalYearID  = @fiscalYearID
				  and ccc.quarterNumber = 4
				  and ccc.completed     = 1
				  and ccc.active        = 1
			   )
			   )
			   )
			   , 1, 0)
	)
	, cte_transportation_sub_tabs as (
		select
			crcsTransportationPersonnelCostsCompleted = convert(bit,
			iif(
			   (
				   SELECT
					count(ctp1.id)
				   from dbo.CRCS_TRANSPORTATION_PERSONNEL_COSTS_VIEW_CORE (@clientID, @fiscalYearID, 1, null) as ctp1
			   ) = (
				   SELECT
					count(ctp2.id)
				   from dbo.CRCS_TRANSPORTATION_PERSONNEL_COSTS_VIEW_CORE (@clientID, @fiscalYearID, 1, null) as ctpv
				   join dbo.CRCS_TRANSPORTATION_PERSONNEL_COSTS as ctp2
						on (
								 ctp2.id = ctpv.id
							 and ctp2.clientID = ctpv.clientID
							 and ctp2.fiscalYearID = ctpv.fiscalYearID
							 and (ctp2.totalSalaries > 0 or ctp2.totalBenefits > 0 or ctp2.fedResourceOrGrant > 0 or ctp2.deferred = 1)
							 and ctp2.active = 1
						)
			   )
			 , 1, 0)
		)
		, crcsTransportationOtherCostsCompleted = convert(bit,
			iif(
			   (
				   SELECT
					count(cto1.id)
				   from dbo.CRCS_TRANSPORTATION_OTHER_COSTS_VIEW_CORE (@clientID, @fiscalYearID, 1, null) as cto1
			   ) = (
				   SELECT
					count(ctov.id)
				   from dbo.CRCS_TRANSPORTATION_OTHER_COSTS_VIEW_CORE (@clientID, @fiscalYearID, 1, null) as ctov
				   where (ctov.grossCosts > 0 or ctov.expenditures > 0 or ctov.deferred = 1)
			   )
			 , 1, 0)
		)
		, crcsTransportationEquipmentDepreciationCostsCompleted = convert(bit,
			iif(
			   (exists (SELECT top 1 crd.deferred from dbo.CRCS_CATEGORY_DEFERRAL_VIEW (@clientID, @fiscalYearID, 8) as crd where crd.deferred = 1))
			   or
			   (exists (SELECT top 1 ctedcvc.id from dbo.CRCS_TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_VIEW_CORE(@clientID, @fiscalYearID, 1, null) as ctedcvc))
			 , 1, 0)
		)
	)
	, cte_transportation_tab as (
		select
		  crcsTransportationCompleted = convert(bit,
			(
				select
					iif(((q1.amtPaid <= 0)
					 or (
							 transps.crcsTransportationPersonnelCostsCompleted = 1
						 and transps.crcsTransportationOtherCostsCompleted = 1
						 and transps.crcsTransportationEquipmentDepreciationCostsCompleted = 1
					 ))
					 ,1,0)
				from
				(
				  select
					amtPaid = isnull(sum(cca.AMOUNT_PAID),0)
				  from dbo.COMPANY_FISCAL_YEARS      as cfy
				  join dbo.CLAIM_Claim               as clm  on ((clm.CLIENT_ID = @clientID)
															 and (clm.SERVICE_DATE between cfy.FY_START and cfy.FY_END)
																and ((clm.STATUS = convert(char(10),3)) /* Claim Paid */))
				  join dbo.CLAIM_Procedures          as cp   on ((cp.PROCEDURE_ID = clm.PROCEDURE_ID)
															 and (cp.SERVICE_TYPE_ID = 3) /* Transportation Service */)

				  join dbo.CLAIM_Claim_Adjudication  as cca on cca.CLAIM_ID        = clm.CLAIM_ID
				  where
					(cfy.ID = @fiscalYearID)
				) as q1
			)
		)
		from cte_transportation_sub_tabs as transps

	)
	, cte_transportation_calculated as (
		select
			  transtab.crcsTransportationCompleted
			, crcsTransportationPersonnelCostsCompleted			    = convert(bit
																			, iif(transsubtab.crcsTransportationPersonnelCostsCompleted = 1
																			  or transtab.crcsTransportationCompleted = 1, 1, 0)
																	  )
			, crcsTransportationOtherCostsCompleted				    = convert(bit
																			, iif(transsubtab.crcsTransportationOtherCostsCompleted = 1
																			  or transtab.crcsTransportationCompleted = 1, 1, 0)
																	  )
			, crcsTransportationEquipmentDepreciationCostsCompleted = convert(bit
																			, iif(transsubtab.crcsTransportationEquipmentDepreciationCostsCompleted = 1
																			  or transtab.crcsTransportationCompleted = 1, 1, 0)
																	  )
		from cte_transportation_tab as transtab
		outer apply cte_transportation_sub_tabs transsubtab
	)

	Select
		  crcsPracSalariesCompletedQ1 = convert(bit, sal.crcsPracSalariesCompletedQ1)
		, crcsPracSalariesCompletedQ2 = convert(bit, sal.crcsPracSalariesCompletedQ2)
		, crcsPracSalariesCompletedQ3 = convert(bit, sal.crcsPracSalariesCompletedQ3)
		, crcsPracSalariesCompletedQ4 = convert(bit, sal.crcsPracSalariesCompletedQ4)

		, crcsPracSalariesCompleted = convert(bit,
			iif((sal.crcsPracSalariesCompletedQ1 = 1
				and sal.crcsPracSalariesCompletedQ2 = 1
				and sal.crcsPracSalariesCompletedQ3 = 1
				and sal.crcsPracSalariesCompletedQ4 = 1
				and @fiscalYearID > 26)
				or
				(
					(
					  (

						   SELECT count(pracID)
						   from dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW_CORE (
							  @clientID
							, @fiscalYearID
							, null
						   ) where employeeRelationshipID = 10 -- employee
					   ) = (

						   SELECT count(pracID)
						   from dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY as cps

						   where cps.clientID = @clientID
						   and cps.fiscalYearID = @fiscalYearID
						   and cps.active = 1
						   and (isnull(cps.salary, 0) != 0)
						   and cps.employeeRelationshipID = 10 -- employee
					   )
					)
				and @fiscalYearID <= 26)
			, 1, 0)
		)

		, crcsOtherCostsCompleted = convert(bit,
			iif(
			   (
				   SELECT
					count(coc1.grpSvcClassNameID)
				   from dbo.CRCS_OTHER_COSTS_VIEW_CORE (@clientID, @fiscalYearID, null) as coc1
			   ) = (
				   SELECT
					count(coc2.grpSvcClassNameID)
				   from dbo.CRCS_OTHER_COSTS_VIEW_CORE (@clientID, @fiscalYearID, null) as cocv
				   join dbo.CRCS_OTHER_COSTS as coc2
						on (
								(coc2.grpSvcClassNameID = cocv.grpSvcClassNameID and coc2.clientID = @clientID and coc2.fiscalYearID = @fiscalYearID and coc2.active = 1)
							and (  (isnull(coc2.materialsAndSupplies   , 0) != 0)
								or (isnull(coc2.nonCapitalizedEquipment, 0) != 0)
								or (isnull(coc2.travelAndConference    , 0) != 0)
								or (isnull(coc2.duesAndMembership      , 0) != 0)
								or (isnull(coc2.communications         , 0) != 0)
								or (isnull(coc2.otherFederalCosts      , 0) != 0)
								or (coc2.deferred = 1)
							)
						)
			   )
			 , 1, 0)
		)
		, crcsContractorCostsCompleted = convert(bit,
			iif(
			   (
				   SELECT
					count(ccc1.pracID)
				   from dbo.CRCS_CONTRACTOR_COSTS_VIEW_CORE (@clientID, @fiscalYearID, null) as ccc1
				   where ccc1.employeeRelationshipID = 20 -- contractor
			   ) = (
				   SELECT
					count(ccc2.pracID)
				   from dbo.CRCS_CONTRACTOR_COSTS_VIEW_CORE (@clientID, @fiscalYearID, null) as cccv
				   join dbo.CRCS_CONTRACTOR_COSTS as ccc2
						on (
								(ccc2.pracID = cccv.pracID and ccc2.clientID = cccv.clientID and ccc2.fiscalYearID = cccv.fiscalYearID and ccc2.active = 1)
						)
				   where cccv.employeeRelationshipID = 20 -- contractor
			   )
			 , 1, 0)
		)
		, crcsMedEquipmentDepreciationCostsCompleted = convert(bit,
			iif(
			   (exists (SELECT top 1 crd.deferred from dbo.CRCS_CATEGORY_DEFERRAL_VIEW (@clientID, @fiscalYearID, 4) as crd where crd.deferred = 1))
			   or
			   (exists (SELECT top 1 cmedcvc.id from dbo.CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_VIEW_CORE(@clientID, @fiscalYearID, 1, null) as cmedcvc))
			 , 1, 0)
		)
		, transp.crcsTransportationCompleted
		, transp.crcsTransportationPersonnelCostsCompleted
		, transp.crcsTransportationOtherCostsCompleted
		, transp.crcsTransportationEquipmentDepreciationCostsCompleted

		, crcsProgramInfoCompleted = convert(bit,
			iif(
			   exists (Select top 1 cpi.id from dbo.CRCS_PROGRAM_INFO_VIEW_CORE (@clientID, @fiscalYearID, 1, null) as cpi
			   where (
			           cpi.contactInfoVerified = 1           and cpi.personSigningInfoVerified = 1
				   and cpi.consortiumBillingInfoVerified = 1 and cpi.programInfoVerified = 1
			    )
			   )
			, 1, 0)
		)
	from Salary_cte as sal
	outer apply cte_transportation_calculated as transp
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CRCS_COMPLETION_STATUS_VIEW] TO [webuser]
GO

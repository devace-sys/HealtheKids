USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_CONTRACTOR_COSTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_CONTRACTOR_COSTS_VIEW_CORE
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
    
CREATE FUNCTION [dbo].[CRCS_CONTRACTOR_COSTS_VIEW_CORE] ( 
	   @clientID          BigInt    
	 , @fiscalYearID      BigInt
	 , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN(
	-- this the version of the query that goes based on service records entered
	with cte_pracs as ( 

		select 
			sr.clientID
		  , sr.pracID
		  , numOfSvcRecs = count( sr.id )

      -- TODO?   , numOfSvcRecs = count(distinct sr.id )    -- ???
      --           if we modify the JOINs to get NULL / non-existing service records,
      --           then we need to change this COUNT() above to not double-count all those NULL service record IDs
      --           maybe

		from dbo.COMPANY_FISCAL_YEARS as cfy
		join dbo.SERVICE_RECORDS as sr on  ((sr.clientID = @clientID)
									   and (sr.pracID is not null)
									   and (sr.patID is not null)
									   and (sr.dos between cfy.FY_START and cfy.FY_END))
		join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = sr.pracID
		where (   
			  (cfy.id = @fiscalYearID) 
		  and (sr.state not in (99,199))        /* Exclude deleted and CIF */
		  and (prp.employeeRelationshipID = 20) /* Contractor*/
  
		)
 
		group by
		   sr.clientID
		  ,sr.pracID
	)
	-- this the version of the query that goes based on reimbursement
	-- use if DHCS changes their requirements again
	--with cte_pracs as ( 
	--  select   
	--	  pracID = clm.PRACTITIONER_ID
	--  from dbo.CLAIM_Claim               as clm
	--  join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = clm.PRACTITIONER_ID
	--  join dbo.CLAIM_Claim_Adjudication  as cca on cca.CLAIM_ID        = clm.CLAIM_ID
	--  left join dbo.COMPANY_FISCAL_YEARS as cfy on cfy.ID              = @fiscalYearID
   
	--  where (
	--		(clm.CLIENT_ID = @clientID)
	--	and (clm.SERVICE_DATE between cfy.FY_START and cfy.FY_END)
	--	and (clm.[STATUS] = '3' /* Paid */)
	--	and (prp.employeeRelationshipID = 20 /* Contractor */)
	--  )
   
	--  group by 
	--	  clm.PRACTITIONER_ID
   
	--  having
	--	sum(cca.AMOUNT_PAID) > 0
  
	--)

	, cte_union_include_removed as (
		select 
			  pracID = pc.pracID
		from cte_pracs as pc
		union -- this is to include pracs who had data entered in CRCS screen and were removed from cte_pracs for whatever reason 
		(
			select 
				pracID        = cc.pracID
			from CRCS_CONTRACTOR_COSTS as cc
			where (
				cc.clientID     = @clientID
			and cc.fiscalYearID = @fiscalYearID 
			and cc.employeeRelationshipID = 20 -- contractor
			and cc.active = 1 
			)
		)
		union -- pracs saved as "Contractor" in PRAC_SALARIES table
		(
			select 
				pracID        = cp.pracID
			from dbo.CRCS_PRAC_SALARIES_VIEW_CORE(@clientID,@fiscalYearID,null,null) as cp
			where cp.employeeRelationshipID = 20
		)
	)

  select 
		pracID                      = pr.PRACTITIONER_ID
	  , clientID					= pc.CLIENT_ID
	  , crcsPracticeFamilyName      = ggsvc.GROUP_SERVICE_CLASS_NAME
      , pracName                    = pr.CONCAT_NAME 
	  , pracTitle                   = g1.GROUP_NAME
	  , employeeRelationshipID      = isnull(ccc.employeeRelationshipID, 20)
	  , contractorCosts5800         = ccc.contractorCosts5800
	  , contractorCosts5100         = ccc.contractorCosts5100
	  , contractRatePerHour         = ccc.contractRatePerHour
	  , federalResourceAmounts      = ccc.federalResourceAmounts
	  , federalResourceCodes        = ccc.federalResourceCodes
	  , notes                       = ccc.notes
	  , fiscalYearID                = @fiscalYearID
  	  , grpSvcClassNameID           = ggsvc.GROUP_SERVICE_CLASS_NAME_ID
	  , grpSvcClassName  	        = ggsvc.GROUP_SERVICE_CLASS_NAME
  from cte_union_include_removed as uc
  join dbo.PRACTITIONER_Practitioner as pr on pr.PRACTITIONER_ID = uc.pracID
  join dbo.PRACTITIONER_GROUPS_VIEW_DISP()    as gd  on gd.PRACTITIONER_ID = pr.PRACTITIONER_ID
  join dbo.GROUP_GROUP                        as g1  on g1.GROUP_ID        = gd.GROUP_ID
  left join dbo.CRCS_CONTRACTOR_COSTS as ccc
    on  (
		ccc.pracID        = pr.PRACTITIONER_ID 
	and ccc.fiscalYearID  = @fiscalYearID
	and ((@recID is null) or (ccc.id = @recID))
	and isnull(ccc.active, 1) != 0
	)
  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as ggsvcp on ggsvcp.GROUP_ID = G1.GROUP_ID and ggsvcp.GROUP_SERVICE_CLASS_PARTITION_ID = 600
  join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as ggsvc on ggsvc.GROUP_SERVICE_CLASS_NAME_ID = ggsvcp.GROUP_SERVICE_CLASS_NAME_ID
  join dbo.PRACTITIONER_Client as pc on pc.PRACTITIONER_ID = pr.PRACTITIONER_ID
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_CONTRACTOR_COSTS_VIEW_CORE] TO [webuser]
GO
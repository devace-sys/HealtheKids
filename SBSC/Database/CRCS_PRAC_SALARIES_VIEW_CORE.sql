USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_SALARIES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PRAC_SALARIES_VIEW_CORE
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
    
CREATE FUNCTION [dbo].[CRCS_PRAC_SALARIES_VIEW_CORE] ( 
	   @clientID          BigInt    
	 , @fiscalYearID      BigInt
	 , @quarterNumber     Int
	 , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN (

with 
cte_fq_and_rmts_roster
as
(
	select  
      quarterStartDate   = QTR_START
	   , quarterEndDate     = QTR_END
	   , quarterNumber      = QTR
	   , rmtsPartRosterID   = rpr.id
	   , rpr.created
	   , rpr.createdBy

       , fq.id fq_id

	from dbo.COMPANY_FISCAL_QUARTERS   as fq 
	join 
  dbo.RMTS_PARTICIPATION_ROSTER as rpr on ((rpr.clientID = @clientID) and (rpr.quarterID = fq.ID) and (rpr.active    = 1))

	where (
		   (fq.FY_ID = @fiscalYearID)
	  and ((@quarterNumber is null) or (fq.QTR = @quarterNumber))
	)
)

,
cte_rosterParticipants as (
	select
	    --fq.rmtsPartRosterID    -- no idea why this is being called PartRosterID instead of RosterID

	  --, 

      --rp.quarterNumber                  -- fq.quarterNumber

	  --, 
    
      rp.startDateStr quarterStartDate  -- fq.quarterStartDate
	  , rp.endDateStr quarterEndDate      -- fq.quarterEndDate

                                        -- NOTE: this CTE must NOT return any results from the fq CTE

	  , rp.pracID
	  , pracParticipatedEntireQuarter    = convert(bit, iif ((convert(date, rp.startDate) = fq.quarterStartDate and convert(date, rp.endDate) = fq.quarterEndDate), 1, 0))
	  , pracRmtsParticipatedStartDateStr = rp.startDateStr								  
	  , pracRmtsParticipatedEndDateStr   = rp.endDateStr
	  , pracRmtsParticipatedNumDays      = (1 + datediff(day,rp.startDate, rp.endDate))

	  , pracCanHaveCostsEntered			 = rp.hasServiceRecords

       -- don't know if this value should be renamed to reflect updated business logic
       -- ... referring to lines 71-72 of CRCS_PRAC_SALARIES_UNION_VIEW.sql

	from cte_fq_and_rmts_roster as fq

	--cross apply dbo.RMTS_PARTICIPANTS_VIEW_CORE(@clientID, fq.rmtsPartRosterID, 1, null) as rp

  CROSS APPLY dbo.CRCS_PRACS_VIEW_CORE(@clientID, fq_id, @quarterNumber, fq.rmtsPartRosterID) rp

	where rp.employeeRelationshipID = 10 -- 10 is employee

                                -- TODO: idk why non-employees are being filtered out of this view.
                                

)

select distinct
		  pracID                      = uc.pracID
		, clientID					  = @clientID
		, pracName                    = pr.CONCAT_NAME

		--, uc.rmtsPartRosterID

		, quarterNumber               = @quarterNumber
		, uc.quarterStartDate           
		, uc.quarterEndDate             
		, uc.pracParticipatedEntireQuarter
		, uc.pracRmtsParticipatedStartDateStr
		, uc.pracRmtsParticipatedEndDateStr  
		, uc.pracRmtsParticipatedNumDays

		, pracTitle                   = g1.GROUP_NAME
 		, crcsPracticeFamilyName      = ggsvc.GROUP_SERVICE_CLASS_NAME
		, clientEmployeeID            = pr.clientEmployeeID
		, salary                      = cps.salary
		, federalSalary               = cps.federalSalary
		, federalSalaryResourceCode   = cps.federalSalaryResourceCode
		, benefits                    = cps.benefits
		, federalBenefits             = cps.federalBenefits
		, federalBenefitsResourceCode = cps.federalBenefitsResourceCode
		, employeeRelationshipID      = isnull(cps.employeeRelationshipID, 10)
		, employeeRelationshipName    = case
										when cps.employeeRelationshipID = 10 then 'Employee'
										when cps.employeeRelationshipID = 20 then 'Contractor'
										when cps.employeeRelationshipID = 30 then 'Not on TSP'
										when cps.employeeRelationshipID = 40 then 'Duplicate'
										else 'Employee'
										end

		--, hoursWorkedThisQuarter      = cps.hoursWorkedThisQuarter

		, grossAmount                 = FORMAT(isnull(cps.salary       , 0) + isnull(cps.benefits       , 0), 'C2')
		, grossFederalAmount          = FORMAT(isnull(cps.federalSalary, 0) + isnull(cps.federalBenefits, 0), 'C2')
		, fiscalYearID                = @fiscalYearID
  		, grpSvcClassNameID           = ggsvc.GROUP_SERVICE_CLASS_NAME_ID
		, grpSvcClassName  	          = ggsvc.GROUP_SERVICE_CLASS_NAME	
		, uc.pracCanHaveCostsEntered
		, isEditable                  = convert(bit, iif(ccc.completed = 1, 0, 1))

    , fiscalquarterSalaryExpenditures   =  FORMAT(
                                            isnull(cps.salary   ,  0)    + isnull(cps.federalSalary   ,  0)
                                          , 'C2'
                                        )
    , fiscalquarterBenefitExpenditures  =  FORMAT(
                                            isnull(cps.benefits ,  0)    + isnull(cps.federalBenefits ,  0)
                                          , 'C2'
                                        )

    , fiscalquarterSalaryExpenditures_money   =  CAST(
                                            isnull(cps.salary   ,  0)    + isnull(cps.federalSalary   ,  0)
                                            AS MONEY  -- should already be of type money; casting should be unnecessary
                                        )
    , fiscalquarterBenefitExpenditures_money  =  CAST(
                                            isnull(cps.benefits ,  0)    + isnull(cps.federalBenefits ,  0)
                                            AS MONEY  -- should already be of type money; casting should be unnecessary
                                        )
	
	from cte_rosterParticipants as uc

	join dbo.PRACTITIONER_Practitioner as pr on pr.PRACTITIONER_ID = uc.pracID
	join dbo.PRACTITIONER_GROUPS       as pg on pg.PRACTITIONER_ID = pr.PRACTITIONER_ID and pg.GROUP_TYPE in (1,2)
	join dbo.GROUP_GROUP               as g1 on g1.GROUP_ID  =      pg.GROUP_ID
	                       
	join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as ggsvcp on ggsvcp.GROUP_ID = g1.GROUP_ID  and ggsvcp.GROUP_SERVICE_CLASS_PARTITION_ID = 600
	join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES                   as ggsvc  on ggsvc.GROUP_SERVICE_CLASS_NAME_ID = ggsvcp.GROUP_SERVICE_CLASS_NAME_ID

       -- TODO: the ggsvc lookup is being implemented in the inner UDF, CRCS_PRACS_VIEW_CORE.  Let's consider later on removing
       -- the JOINs here to avoid hitting this table more than once


	left join dbo.CRCS_PRAC_SALARIES as cps
	on (
		cps.pracID        = uc.pracID
	and cps.quarterNumber = @quarterNumber
	and cps.fiscalYearID  = @fiscalYearID

    and isnull(cps.active, 1) != 0

	)
	left join dbo.CRCS_CATEGORY_COMPLETED as ccc
	on (
		ccc.clientID      = @clientID
	and ccc.fiscalYearID  = @fiscalYearID
	and ccc.quarterNumber = @quarterNumber
	)

) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_PRAC_SALARIES_VIEW_CORE] TO [webuser]
GO
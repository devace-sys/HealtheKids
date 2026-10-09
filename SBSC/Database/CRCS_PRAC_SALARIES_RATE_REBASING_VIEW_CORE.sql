USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_SALARIES_RATE_REBASING_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PRAC_SALARIES_RATE_REBASING_VIEW_CORE
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
    
CREATE FUNCTION [dbo].[CRCS_PRAC_SALARIES_RATE_REBASING_VIEW_CORE] ( 
	   @clientID          BigInt    
	 , @fiscalYearID      BigInt
	 , @recID             Bigint

      -- not used; figure out if it can be removed without tinkering too much in middleware
)
     
RETURNS TABLE  

AS RETURN (

  with get_orig_rmts_rosters
       -- the [CRCS_PRACS_VIEW_CORE] gets the following rmts roster, per-client, where quarterNumber = 1 for a certain FY onward
  as (
    SELECT
      r.id        orig_rosterID,
      clientID,
      r.quarterID orig_quarterID,
      cfq.QTR     orig_quarterNum
    FROM
      dbo.RMTS_PARTICIPATION_ROSTER    r
      JOIN dbo.COMPANY_FISCAL_QUARTERS cfq
        ON r.quarterID = cfq.ID
       AND r.clientID  = @clientID
       AND cfq.FY_ID = @fiscalYearID

  ),

  get_all_pracs_all_qs as (
    SELECT

      DISTINCT  pracID, pracName,
                pracTitle , reportingGroup , crcsPracticeFamilyName

    FROM get_orig_rmts_rosters orig_rosters

    CROSS APPLY [CRCS_PRACS_VIEW_CORE] (
     -- this UDF has the quarterNum != 1 logic AND the fy_id > ... logic, I don't want to reproduce it here
     
	    orig_rosters.clientID
 	 ,  orig_rosters.orig_quarterID
   ,  orig_rosters.orig_quarterNum
   ,  orig_rosters.orig_rosterID
   ) pracs
  ), 

  fourqs_per_prac as (
    SELECT 
      all_qs.*  ,

      CASE WHEN u_q1.pracID IS NOT NULL THEN ' Q1' ELSE '' END incl_in_q1 ,
      CASE WHEN u_q2.pracID IS NOT NULL THEN ',Q2' ELSE '' END incl_in_q2 ,
      CASE WHEN u_q3.pracID IS NOT NULL THEN ',Q3' ELSE '' END incl_in_q3 ,
      CASE WHEN u_q4.pracID IS NOT NULL THEN ',Q4' ELSE '' END incl_in_q4 ,

      ISNULL( u_q1.fiscalquarterSalaryExpenditures_money, 0) q1_fiscalquarterSalaryExpenditures_money  ,
      ISNULL( u_q2.fiscalquarterSalaryExpenditures_money, 0) q2_fiscalquarterSalaryExpenditures_money  ,
      ISNULL( u_q3.fiscalquarterSalaryExpenditures_money, 0) q3_fiscalquarterSalaryExpenditures_money  ,
      ISNULL( u_q4.fiscalquarterSalaryExpenditures_money, 0) q4_fiscalquarterSalaryExpenditures_money  ,

      ISNULL( u_q1.fiscalquarterBenefitExpenditures_money, 0) q1_fiscalquarterBenefitExpenditures_money  ,
      ISNULL( u_q2.fiscalquarterBenefitExpenditures_money, 0) q2_fiscalquarterBenefitExpenditures_money  ,
      ISNULL( u_q3.fiscalquarterBenefitExpenditures_money, 0) q3_fiscalquarterBenefitExpenditures_money  ,
      ISNULL( u_q4.fiscalquarterBenefitExpenditures_money, 0) q4_fiscalquarterBenefitExpenditures_money   -- ,

/*
      ISNULL( u_q1.hoursWorkedThisQuarter, 0) q1_hoursWorkedThisQuarter  ,
      ISNULL( u_q2.hoursWorkedThisQuarter, 0) q2_hoursWorkedThisQuarter  ,
      ISNULL( u_q3.hoursWorkedThisQuarter, 0) q3_hoursWorkedThisQuarter  ,
      ISNULL( u_q4.hoursWorkedThisQuarter, 0) q4_hoursWorkedThisQuarter  
*/

    FROM get_all_pracs_all_qs all_qs
    OUTER APPLY
      dbo.[CRCS_PRAC_SALARIES_UNION_VIEW] (
	      @clientID	     ,
	      @fiscalYearID	 ,
	      all_qs.pracID   ,
 	      1 , --
	      10
    ) u_q1
    OUTER APPLY
      dbo.[CRCS_PRAC_SALARIES_UNION_VIEW] (
	      @clientID	     ,
	      @fiscalYearID	 ,
	      all_qs.pracID   ,
 	      2 , --
	      10
    ) u_q2
    OUTER APPLY
      dbo.[CRCS_PRAC_SALARIES_UNION_VIEW] (
	      @clientID	     ,
	      @fiscalYearID	 ,
	      all_qs.pracID   ,
 	      3 , --
	      10
    ) u_q3
    OUTER APPLY
      dbo.[CRCS_PRAC_SALARIES_UNION_VIEW] (
	      @clientID	     ,
	      @fiscalYearID	 ,
	      all_qs.pracID   ,
 	      4 , --
	      10
    ) u_q4
  ),

  fourqs_all_totals_per_prac as (
    SELECT

      ISNULL( hrs.id, 0) id,

      fq.pracID, fq.pracName , fq.pracTitle , fq.reportingGroup , fq.crcsPracticeFamilyName ,

      SUBSTRING( incl_in_q1 + incl_in_q2 + incl_in_q3 + incl_in_q4
       , 2
       , 999 ) qs_incl ,

      q1_fiscalquarterSalaryExpenditures_money + q2_fiscalquarterSalaryExpenditures_money + 
      q3_fiscalquarterSalaryExpenditures_money + q4_fiscalquarterSalaryExpenditures_money
      SalaryExpenditures_money
      ,

      q1_fiscalquarterBenefitExpenditures_money + q2_fiscalquarterBenefitExpenditures_money +
      q3_fiscalquarterBenefitExpenditures_money + q4_fiscalquarterBenefitExpenditures_money 
      BenefitExpenditures_money
      ,

      /*
      q1_hoursWorkedThisQuarter + q2_hoursWorkedThisQuarter + q3_hoursWorkedThisQuarter +
      q4_hoursWorkedThisQuarter   */
      hoursWorked
      
    FROM  fourqs_per_prac fq

    LEFT JOIN
      [CRCS_PRAC_HOURS_FY] hrs
    ON  hrs.pracID = fq.pracID AND hrs.clientID = @clientID AND hrs.fiscalYearID = @fiscalYearID
  ),

  expenditures_per_prac as (
    SELECT
      *,
      SalaryExpenditures_money + BenefitExpenditures_money expenditures
    FROM fourqs_all_totals_per_prac
  ),

  per_hour as (
    SELECT
      * ,
      IIF ( hoursWorked = 0, CAST( expenditures as decimal), cast( expenditures as decimal ) / hoursWorked ) per_hour ,
      @clientID       clientID ,
	    @fiscalYearID   fiscalYearID  
    FROM expenditures_per_prac
  )

  SELECT * FROM per_hour

)
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_PRAC_SALARIES_RATE_REBASING_VIEW_CORE] TO [webuser]
GO
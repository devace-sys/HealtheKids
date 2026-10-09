USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_VIEW_CLAIMABLE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_VIEW_CLAIMABLE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENTS_VIEW_CLAIMABLE]    
(@clientID    as INT,    
 @startDate   as DATETIME,
 @endDate     as DATETIME,
 @minrefdate  as DATETIME 
)    
RETURNS TABLE
 
 /***************************************************************************    
  * PATIENTS_VIEW_CLAIMABLE */    
 /**    
  * Returns a list of patients who are claimable for the given clientID and
  * date range.
  *    
  * @param  clientID      Client id
  * @param  startDate     Start of month for start date
  * @param  endDate       End date (any)
  * @param  minrefday     Start of month for todays date - 11 months
  * @return               Table 
  ***************************************************************************/                         
     
AS RETURN
(
with 


/*-------------------------------
 * All active patients
 *
 * - Members of the given client
 * - active = 'Y'
 *------------------------------*/

pat_pop_all_active_cte
as
(
  select 
    pc.CLIENT_ID            as CLIENT_ID,
    pp.PATIENT_ID           as PATIENT_ID,
    pp.ACTIVE               as PATIENT_ACTIVE,
    pp.DATE_OF_BIRTH        as DOB,
    pi.IEP_IFSP_NONE        as IEP,
        
    dbo.CALC_AGE(pp.DATE_OF_BIRTH, @minrefdate)       as [Patient Age WR MinRefDate],
    DATEADD(dd, 0, DATEDIFF(dd, 0, pp.DATE_CREATED )) as DATE_CREATED,
    DATEADD(dd, 0, DATEDIFF(dd, 0, pp.LAST_UPDATED))  as LAST_UPDATED,
    DATEADD(dd, 0, DATEDIFF(dd, 0, pp.LASTPOP))       as [LASTPOP]
  
  from CLIENTS_Client                    as cc
  join PATIENTS_Client                   as pc   on  pc.CLIENT_ID    = @clientID
                                                 and pc.CLIENT_ID    = @clientID
  join PATIENTS_PATIENT                  as pp   on  pp.PATIENT_ID   = pc.PATIENT_ID
                                                 and pp.ACTIVE       = 'Y'
  join PATIENTS_IEP                      as pi   on  pi.PATIENT_ID   = pp.PATIENT_ID    
  
  where (cc.CLIENT_ID = @clientID)
)
,

/*-------------------------------
 * All active patients under 6
 *
 * - pat_pop_all_active_cte
 * - UNDER the age of 6 as of 
     minrefdate 
 * - and who have ANY last popdate
 *------------------------------*/
 
pat_pop_all_active_under_6_all_cte
as
(
  select * from pat_pop_all_active_cte 
  where 
    [Patient Age WR MinRefDate] < 6    
)
,

/*-------------------------------
 * All active patients between
 * 6 and 21
 *
 * - pat_pop_all_active_cte
 * - between the ages of 6 and 21
 *   as of minrefdate 
 * - and who have a lastpop >=
 *   minrefdate 
 *------------------------------*/
 
pat_pop_all_active_between_6_and_21_recent_cte
as
(
  select *
  from
  (
    select * from pat_pop_all_active_cte
    where 
      [Patient Age WR MinRefDate] between 6 and 21
  ) as q1
  where (q1.LASTPOP >= @minrefdate)   
)
,

/*-------------------------------
 * Patient Population
 * 
 * - pat_pop_all_active_under_6_all_cte
 * - pat_pop_all_active_between_6_and_21_recent_cte 
 * - have either an IEP or IFSP UNLESS
 *   they are a Clovis patient
 *------------------------------*/
 
pat_pop_cte
as
( 
  select *
  from
  (
    select 
      q1.*,
      [Display] = case
        when ((@clientID <> 27) and (IEP <> 'NONE')) then 1
        when ((@clientID =  27))                     then 1
      end
    from
    (
      select * from pat_pop_all_active_under_6_all_cte
      union
      select * from pat_pop_all_active_between_6_and_21_recent_cte
    ) as q1
  ) as q2
  where [Display] = 1
)
,
/*-------------------------------
 * Patients Who Are Eligible
 * 
 * All patients who are:
 *
 * - Members of the given client
 * - active = 'Y' 
 * - Have eligibility data 
 *   >= @minrefdate
 * - Have at least one elibible month
 *   in the date range provided
 *------------------------------*/

pat_elig_cte
as
(
  select distinct  
    pe.PATIENT_ID    as [PATIENT_ID],
    COUNT(pe.ELG_ID) as [Number of Eligible Months]   
  from CLIENTS_Client                  as cc
  join PATIENTS_CLIENT                 as pc on  pc.CLIENT_ID  = cc.CLIENT_ID
                                             and pc.CLIENT_ID  = @clientID
  join PATIENTS_Patient                as pp on  pp.PATIENT_ID = pc.PATIENT_ID
                                             and pp.ACTIVE     = 'Y' 
  join PATIENTS_ELIGIBILITY_NORMALIZED as pe on  pe.PATIENT_ID = pp.PATIENT_ID
                                             and pe.IS_ELIG    = 1
                                             and MONTH_DATE   >= @minrefdate 
                                             and MONTH_DATE between @startDate and @endDate
  where cc.CLIENT_ID = @clientID 
  group by pe.PATIENT_ID 
)
,

/*-------------------------------
 * Eligible Patient Population
 * 
 * All patients who are:
 *
 * - In Patient Population
 * - In Patients Who Are Eligible
 *------------------------------*/

pat_pop_elig_cte
as
(
  select 
    ppc.*,
    @minrefdate as [Min Ref Date],
    pec.[Number of Eligible Months]
  from pat_pop_cte  as ppc
  join pat_elig_cte as pec on pec.PATIENT_ID = ppc.PATIENT_ID
)

/*-------------------------------
 * Return rows
 *------------------------------*/

select * from pat_pop_elig_cte

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENTS_VIEW_CLAIMABLE] TO [webuser]
GO   

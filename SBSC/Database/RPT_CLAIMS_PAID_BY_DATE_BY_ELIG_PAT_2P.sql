USE [SPEDMON]

GO
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIMS_PAID_BY_DATE_BY_ELIG_PAT_2P') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_ELIG_PAT_2P]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_ELIG_PAT_2P]
(@clientID      BIGINT,
 @siteID        BIGINT,
 @groupID       BIGINT,
 @pracID        BIGINT,
 @patID         BIGINT,
 @startDateDOS1 DATETIME,    
 @endDateDOS1   DATETIME,      
 @startDateDOS2 DATETIME,    
 @endDateDOS2   DATETIME,     
 @minrefdate    DATETIME)
RETURNS TABLE

/***************************************************************************
 * RPT_CLAIMS_PAID_BY_DATE_BY_ELIG_PAT_2P */
/**
 * Generates two period (2P) of data for claims paid for a given:
 * 
 * - client
 * - date of service (DOS) range
 * 
 * Where services were promised (CASEMIS) but no claims paid we display
 * practitioner data with zeros for the totals
 *
 * @param  clientID      Patients client id
 * @param  siteID        Patients site id
 * @param  groupID       Group id
 * @param  pracID        Practitioner id
 * @param  startDateDOS1 Starting DOS for period 1
 * @param  endDateDOS1   Ending DOS for period 1
 * @param  startDateDOS2 Starting DOS for period 2
 * @param  endDateDOS2   Ending DOS for period 2
 * @param  minrefdate
 * @return Table
 ***************************************************************************/

AS 
RETURN
(

with

/*===============================
 * Left side
 *==============================*/

/*-------------------------------
 * Get all ELIGIBLE patients
 * within period 1
 *------------------------------*/

elig_pat_cte
as
(
  select 

    pvc.CLIENT_ID,
    pvc.PATIENT_ID
       
  from PATIENTS_VIEW_CLAIMABLE(@clientID, 
                               @startDateDOS1, 
                               @endDateDOS1, 
                               @minrefdate) as pvc

  where (1=1)  
  and ((@patID is null) or (PATIENT_ID = @patID)) 
)
,

/*-------------------------------
 * Get pat, prac combos for:
 *
 * - Claims paid for P1
 * - Claims paid for P2 
 *
 * Note: This will be used to
 * build our left side 
 * practitioner data
 *------------------------------*/

pat_prac_cte
as
(  
 
  select distinct

    [PATIENT_ID], 
    [PRACTITIONER_ID] 

  from
  (
    
    /*-------------------------------
     * All paid (elig or not) for P1
     * with CASEMIS 
     *------------------------------*/
     
    select 
      [PATIENT_ID], 
      [PRACTITIONER_ID] 
    from CLAIM_PAID_BY_DATE_PAT_PRAC_COMBOS_WITH_CASEMIS (@clientID, @startDateDOS1, @endDateDOS1, null, null)
    
    /*-------------------------------
     * Combined with
     * Note: union eliminates dups
     *------------------------------*/
    
    union   
      
    /*-------------------------------
     * All paid (elig or not) for P2
     * with CASEMIS
     *------------------------------*/

    select
      [PATIENT_ID], 
      [PRACTITIONER_ID]     
    from CLAIM_PAID_BY_DATE_PAT_PRAC_COMBOS_WITH_CASEMIS (@clientID, @startDateDOS2, @endDateDOS2, null, null)
  
  ) as q1
  
  where (1=1)
  
  /*-------------------------------
   * Prefilter pat and prac
   *------------------------------*/

  and ((@patID  is null) or (PATIENT_ID      = @patID   )) 
  and ((@pracID is null) or (PRACTITIONER_ID = @pracID  )) 
  
)
,

/*-------------------------------
 * Get pat, prac combos for:
 *
 * - ALL ELIGIBLE patients for P1
 * - Claims paid pat, prac combos
 *   for P1, CASMIS, or nothing
 * - Claims paid pat, prac combos
 *   for P2 CASEMIS, or nothing
 *------------------------------*/

elig_pat_prac_combos_p1_p2_cte
as
(
  select
    [CLIENT_ID],
    [PATIENT_ID],
    [PRACTITIONER_ID]
  from
  (
    select 
      pvc.CLIENT_ID,
      pvc.PATIENT_ID,
      ppc.PRACTITIONER_ID       
    
    from elig_pat_cte      as pvc
    left join pat_prac_cte as ppc on ppc.PATIENT_ID = pvc.PATIENT_ID
  ) as q1
  
  where (1=1)
  
  /*-------------------------------
   * Prefilter pat and prac
   *------------------------------*/

  and ((@patID  is null) or (q1.PATIENT_ID      = @patID   )) 
  and ((@pracID is null) or (q1.PRACTITIONER_ID = @pracID  )) 
)

,

/*===============================
 * Right Side
 *==============================*/

/*-------------------------------
 * Get all ELIGIBLE patient
 * and practitioner combinations 
 * for claims paid in p1 and p2 
 * CASMIS, or nothing paid in p1 and p2
 * and the details
 *------------------------------*/

claims_paid_by_pat_prac_p1_p2_cte
as
(
  select 

    q1.[CLIENT_ID],
    q1.[PATIENT_ID],
    q1.[PRACTITIONER_ID],
          
    /*-------------------------------
     * Total for patient row by prac
     * for P1
     *------------------------------*/
   
    sum(cp1.Assessments)                 as [Asmts P1], 
    sum(cp1.[Services & Transportation]) as [Svcs & Trans P1], 
    sum(cp1.TCM)                         as [TCM P1],
    sum(cp1.Total)                       as [Total P1],
  
   /*-------------------------------
    * Total for patient row by prac
    * for P2
    *------------------------------*/
   
    sum(cp2.Assessments)                 as [Asmts P2], 
    sum(cp2.[Services & Transportation]) as [Svcs & Trans P2], 
    sum(cp2.TCM)                         as [TCM P2],
    sum(cp2.Total)                       as [Total P2] 
  
  /*-------------------------------
   * Elig pat/prac combos 
   * for p1 and p2
   *------------------------------*/

  from elig_pat_prac_combos_p1_p2_cte as q1
  
  /*-------------------------------
   * Details for p1
   * for elig pat/prac combos
   *------------------------------*/

  left join RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_WITH_CASEMIS (@clientID, 
                                                              @startDateDOS1, 
                                                              @endDateDOS1, 
                                                              null,
                                                              null) as cp1 
                                                            on cp1.[PATIENT_ID]      = q1.[PATIENT_ID]
                                                           and cp1.[PRACTITIONER_ID] = q1.[PRACTITIONER_ID]
  /*-------------------------------
   * Details for p2
   * for elig pat/prac combos
   *------------------------------*/

  left join RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_WITH_CASEMIS (@clientID, 
                                                              @startDateDOS2, 
                                                              @endDateDOS2, 
                                                              null, 
                                                              null) as cp2  
                                                            on cp2.[PATIENT_ID]      = q1.[PATIENT_ID]
                                                           and cp2.[PRACTITIONER_ID] = q1.[PRACTITIONER_ID]
  
  where (1=1)
  
  /*-------------------------------
   * Prefilter pat and prac
   *------------------------------*/
  
  and ((@patID   is null) or (q1.PATIENT_ID      = @patID   )) 
  and ((@pracID  is null) or (q1.PRACTITIONER_ID = @pracID  )) 
  
  group by       
    q1.[CLIENT_ID],
    q1.[PATIENT_ID],
    q1.[PRACTITIONER_ID]  
)
,

/*-------------------------------
 * Report data
 *------------------------------*/

claims_paid_p1_p2_rpt_data_cte
as
(
  select
  
    q1.CLIENT_ID,
    q1.PATIENT_ID,
    q1.PRACTITIONER_ID,
    
    cc.CLIENT_NAME as [Client], 
    
    /*-------------------------------
     * Patient name + additional
     * patient data.
     *------------------------------*/
    
    [Patient] = 
      isnull (ppt.CONCAT_NAME , '')              
      + ' -- '       +
      + ' DOB: '    + dbo.RPT_DATE_FMT(ppt.DATE_OF_BIRTH)
      + ' ID: '     + convert(varchar(50), isnull(psc.STUDENT_ID, ''))
      + ' Site: '   + convert(varchar(50), isnull(psc.SITE_NAME,  ''))
      + ' CSIS: '   + convert(varchar(50), isnull(ppt.CSIS,       ''))
      + ' RecID: '  + convert(varchar(50), isnull(ppt.PATIENT_ID, ''))
      + ' ('        + dbo.RPT_DATE_FMT(ppt.LASTPOP) + ')'
     ,        
     
    /*-------------------------------
     * Practitioner name or
     * placeholder label for nulls
     *------------------------------*/
    
    [Practitioner] = 
      case 
        when (q1.PRACTITIONER_ID is null) then
          'No Paid Services'
        else ppr.LAST_NAME
      end,

    /*-------------------------------
     * Practitioner "super group"
     * or placeholder label for nulls
     *------------------------------*/
   
    [Discipline] =
      case 
        when (q1.PRACTITIONER_ID is null) then
          'n/a'
        else g2.GROUP_NAME
      end,    

    /*-------------------------------
     * Replace nulls with 0s
     * for totals
     *------------------------------*/
    
    isnull([Asmts P1],        0) as [Asmts P1], 
    isnull([Svcs & Trans P1], 0) as [Svcs & Trans P1], 
    isnull([TCM P1],          0) as [TCM P1],
    isnull([Total P1],        0) as [Total P1],
    
    isnull([Asmts P2],        0) as [Asmts P2], 
    isnull([Svcs & Trans P2], 0) as [Svcs & Trans P2], 
    isnull([TCM P2],          0) as [TCM P2],
    isnull([Total P2],        0) as [Total P2] 
    
  from claims_paid_by_pat_prac_p1_p2_cte as q1
    
  join CLIENTS_CLIENT                               as cc  on  cc.CLIENT_ID       = q1.CLIENT_ID
  join PATIENTS_PATIENT                             as ppt on ppt.PATIENT_ID      = q1.PATIENT_ID 
  left join PATIENTS_SITES_VIEW_CURRENT(null)       as psc on psc.PATIENT_ID      = ppt.PATIENT_ID
  left join dbo.PRACTITIONER_Practitioner           as ppr on ppr.PRACTITIONER_ID = q1.PRACTITIONER_ID
  left join PRACTITIONER_GROUPS_VIEW_DISP()         as gvd on gvd.PRACTITIONER_ID = ppr.PRACTITIONER_ID
  left join GROUP_Group                             as g1  on g1.GROUP_ID         = gvd.GROUP_ID
  left join GROUP_Group                             as g2  on g2.GROUP_ID         = g1.PARENT_GROUP_ID   
  
  where (1=1)
  
  /*-------------------------------
   * Filters
   *------------------------------*/

  --and ((@patID   is null) or (q1.PATIENT_ID      = @patID   )) 
  --and ((@pracID  is null) or (q1.PRACTITIONER_ID = @pracID  ))   
  and ((@groupID is null) or (g2.GROUP_ID        = @groupID ))   
  and ((@siteID  is null) or (psc.SITE_ID        = @siteID  ))
)
,

/*-------------------------------
 * Details
 *------------------------------*/
 
claims_paid_p1_p2_det_cte
as
(
  select 

    [Client], 
    [Patient],
    [Practitioner],    
    [Discipline],
    
    [Asmts P1],
    [Svcs & Trans P1], 
    [TCM P1],
    [Total P1],
    
    [Asmts P2],
    [Svcs & Trans P2], 
    [TCM P2],
    [Total P2],
    
    dbo.CONST_RPT_ROW_TYPE_DETAIL() as [RPT_ROW_TYPE],
    -1                              as [RPT_GROUP_ID]      
  
  from 
    claims_paid_p1_p2_rpt_data_cte
)
,

/*-------------------------------
 * Totals 
 *------------------------------*/

claims_paid_p1_p2_sum_cte
as
(
  select

    [Client],
    [Patient],
    
    null                                      as [Practitioner],    
    null                                      as [Discipline],
    
    SUM([Asmts P1])                           as [Asmts P1],
    sum([Svcs & Trans P1])                    as [Svcs & Trans P1], 
    sum([TCM P1])                             as [TCM P1],
    SUM([Total P1])                           as [Total P1],

    SUM([Asmts P2])                           as [Asmts P2],
    sum([Svcs & Trans P2])                    as [Svcs & Trans P2], 
    sum([TCM P2])                             as [TCM P2],
    SUM([Total P2])                           as [Total P2],
        
    dbo.CONST_RPT_ROW_TYPE_AGR()              as [RPT_ROW_TYPE],
    GROUPING_ID ([Client],[Patient])          as [RPT_GROUP_ID]	  
  
  from   
    claims_paid_p1_p2_rpt_data_cte
  
  group by   
  
    [Client], 
    [Patient] 
      
  with rollup
)
,

/*-------------------------------
 * Details and totals combined
 *------------------------------*/
 
claims_paid_p1_p2_det_sum_cte
as
(
  select * from claims_paid_p1_p2_det_cte
  union /* Note we are not using a union all */
  select * from claims_paid_p1_p2_sum_cte
)
,

/*-------------------------------
 * Report 
 *------------------------------*/

rpt_cte
as
(
select * from claims_paid_p1_p2_det_sum_cte  
)

select top (dbo.CONST_MAX_ROWS()) *
from rpt_cte
order by

  /*-------------------------------
   * The case statements force
   * the null values to the bottom
   * of the sort order. SQL
   * standards put nulls on the top.
   *------------------------------*/

  case when [Client]       is null then 1 else 0 end,
  [Client],
  
  case when [Patient]      is null then 1 else 0 end,
  [Patient],
    
  case when [Practitioner] is null then 1 else 0 end,
  [Practitioner],
  
  case when [Discipline]   is null then 1 else 0 end,
  [Discipline],

  [RPT_GROUP_ID]

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_ELIG_PAT_2P] TO [webuser]

GO

 


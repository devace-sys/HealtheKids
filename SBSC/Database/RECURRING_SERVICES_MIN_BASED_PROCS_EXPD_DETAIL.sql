USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_DETAIL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_DETAIL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_DETAIL]
(@clientID   as int,
 @patID      as int,
 @pracID     as int,
 @dos        as datetime,
 @svcType    as int,
 @tmtWhen    as int,
 @tmtHow     as int,
 @isOneOnOne as bit,
 @active     as bit)
 
/***************************************************************************    
 * RECURRING_SERVICES_MIN_PASED_PROCS_EXPD_DETAIL */    
/**    
 * Returns details of possible minute based services that patients in the 
 * recurring services system could receive on this day
 *
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   patID           Patient ID you wish to work with or null for all
 * @param   pracID          Practitioner ID you wish to work with or null for all
 * @param   dos             Date of service
 * @param   svcType         Type of service (excluding transportation)
 * @param   tmtWhen         When 
 * @param   tmtHow          How
 * @param   isOneOnOne      null = Ignore 
                            0    = Show all except these 
                            1    = Show just these
 * @param   active          0 = Inactive 1 = Active
 ***************************************************************************/   

RETURNS TABLE 
AS 
RETURN
(
with

/*============================================================
 * Recurring service records
 * Start with this as the base
 *============================================================*/ 

cte_rcr_svc
as
(
  select 
    *
  from RECURRING_SERVICES 
  where 
    (1=1)
    and  active = @active    
    and ((@clientID is null) or (clientID = @clientID))
    and ((@patID    is null) or (patID    = @patID))
    and  @dos between startDate and endDate
)
,

/*============================================================
 * Minute Based Services
 * To date this is just before and after school services
 *============================================================*/ 

cte_rcr_svc_tmt_min_based
as
(
  select
    q1.id,
    q1.clientID,
    q1.patID,
    q1.pracID,    
    q1.inIEP,
    
    /*-------------------------------
     * Number of minutes expected
     * will always be entry minutes
     *------------------------------*/
    
    [NumMinsExpd] = q1.EntryMins,
    
    q1.EntryMins,
    q1.SchMins,
    
    q1.SchPer0Min,
    q1.SchPer1Min,
    q1.SchPer2Min,
    q1.SchPer3Min,
    q1.SchPer4Min,
    q1.SchPer5Min,
    q1.SchPer6Min,
    q1.SchPer7Min,
    q1.SchPer8Min,
    q1.SchPer9Min,
    q1.SchPer10Min,
    
    q1.SchPass0to1Min,
    q1.SchPass1to2Min,
    q1.SchPass2to3Min,
    q1.SchPass3to4Min,
    q1.SchPass4to5Min,
    q1.SchPass5to6Min,
    q1.SchPass6to7Min,
    q1.SchPass7to8Min,
    q1.SchPass8to9Min,
    q1.SchPass9to10Min,
    
    q1.SchFirstPeriod,
    q1.SchLastPeriod,
    q1.SchNumPeriods,
    
    q1.tmtWhen,
    q1.tmtHow,
        
    q1.tmtMinsFrom,
    
    q1.calendarID,
    q1.scheduleID,
    q1.dayTypeID,
    
    q1.calendarName,
    q1.scheduleName,
    q1.dayTypeName


  from
  (
    select 

      rs.id,
      rs.clientID,
      rs.patID, 
      tm.pracID,
      tm.InIEP,
      
      /*-------------------------------
       * Number of mins for given dos
       *------------------------------*/

      [EntryMins] = 
        case datepart (dw,@dos)  
          when 1 THEN null           -- SUN
          when 2 THEN tm.numMinsMon  -- MON
          when 3 THEN tm.numMinsTue  -- TUE
          when 4 THEN tm.numMinsWed  -- WED
          when 5 THEN tm.numMinsThu  -- THU
          when 6 THEN tm.numMinsFri  -- FRI
          when 7 THEN null           -- SAT
        end,
           
      /*-------------------------------
       * Schedule minutes will always
       * be null (we dont use them)
       *------------------------------*/
      
      SchMins     = null,
      SchPer0Min  = null,
      SchPer1Min  = null,
      SchPer2Min  = null,
      SchPer3Min  = null,
      SchPer4Min  = null,
      SchPer5Min  = null,
      SchPer6Min  = null,
      SchPer7Min  = null,
      SchPer8Min  = null,
      SchPer9Min  = null,
      SchPer10Min = null,
      
      SchPass0to1Min  = null,
      SchPass1to2Min  = null,
      SchPass2to3Min  = null,
      SchPass3to4Min  = null,
      SchPass4to5Min  = null,
      SchPass5to6Min  = null,
      SchPass6to7Min  = null,
      SchPass7to8Min  = null,
      SchPass8to9Min  = null,
      SchPass9to10Min = null,
      
      SchFirstPeriod  = null,
      SchLastPeriod   = null,
      SchNumPeriods   = null,
    
      tm.tmtWhen,
      tm.tmtHow,
      
      /*-------------------------------
       * Minutes will always be from
       * entry
       *------------------------------*/
      
      tmtMinsFrom = dbo.CONST_SERVICES_TMT_EXP_MINS_FROM_ENTRY(),
      
      calsch.calendarID,
      calsch.scheduleID,
      calsch.dayTypeID,
      
      calsch.calendarName,
      calsch.scheduleName,
      calsch.dayTypeName
      
    from cte_rcr_svc                                  as rs 
    join RECURRING_SERVICES_DETAILS_SVC_MINUTE_BASED  as tm on tm.rcrSvcID = rs.id
                                                          
   /*-------------------------------
    * Compute minutes from
    * dos, calendar, bell schedule
    * Note: Only used to get data
    *------------------------------*/
  
   outer apply(
     select 
       calendarID,
       scheduleID,
       dayTypeID,
       calendarName,
       scheduleName,
       dayTypeName

     from dbo.CLIENT_ATTENDANCE_CALENDAR_SCHEDULE_DOS_DETAIL(rs.clientID, 
                                                             rs.calendarID, 
                                                             rs.scheduleID, 
                                                             @dos)  
   ) as calsch                 
  ) as q1
)
,

/*============================================================
 * Treatment Minute or Schedule Based
 * To date this is just during school services
 *============================================================*/ 

cte_rcr_svc_tmt_min_or_sch_based
as
(
  select
    q1.id,
    q1.clientID,
    q1.patID,
    q1.pracID,
    q1.InIEP,
    
    /*-------------------------------
     * Number of mins for given dos
     * either what was entered or
     * calculated
     *------------------------------*/

    [NumMinsExpd] = dbo.CALC_EXPECTED_MINUTES(q1.SchedDS, 
                                              q1.EntryMins, 
                                              q1.SchMins),
    
    q1.EntryMins,
    q1.SchMins,
        
    q1.SchPer0Min,
    q1.SchPer1Min,
    q1.SchPer2Min,
    q1.SchPer3Min,
    q1.SchPer4Min,
    q1.SchPer5Min,
    q1.SchPer6Min,
    q1.SchPer7Min,
    q1.SchPer8Min,
    q1.SchPer9Min,
    q1.SchPer10Min,
    
    q1.SchPass0to1Min,
    q1.SchPass1to2Min,
    q1.SchPass2to3Min,
    q1.SchPass3to4Min,
    q1.SchPass4to5Min,
    q1.SchPass5to6Min,
    q1.SchPass6to7Min,
    q1.SchPass7to8Min,
    q1.SchPass8to9Min,
    q1.SchPass9to10Min,
   
    q1.SchFirstPeriod,
    q1.SchLastPeriod,
    q1.SchNumPeriods,
    
    q1.tmtWhen,
    q1.tmtHow,    
    tmtMinsFrom =     
      case q1.SchedDS
        when 0 then dbo.CONST_SERVICES_TMT_EXP_MINS_FROM_ENTRY()
        when 1 then dbo.CONST_SERVICES_TMT_EXP_MINS_FROM_SCHED()
    end,
    
    q1.calendarID,
    q1.scheduleID,
    q1.dayTypeID,
    
    q1.calendarName,
    q1.scheduleName,
    q1.dayTypeName
                   
  from
  (
    select 
      rs.id,
      rs.clientID,
      rs.patID, 
      tm.pracID,
      tm.InIEP,
      
      /*-------------------------------
       * Minutes for given dos
       *------------------------------*/

      [EntryMins] = 
        case datepart (dw,@dos)  
          when 1 THEN null           -- SUN
          when 2 THEN tm.numMinsMon  -- MON
          when 3 THEN tm.numMinsTue  -- TUE
          when 4 THEN tm.numMinsWed  -- WED
          when 5 THEN tm.numMinsThu  -- THU
          when 6 THEN tm.numMinsFri  -- FRI
          when 7 THEN null           -- SAT
        end,
  
      /*-------------------------------
       * Schedule flag for given dos
       *------------------------------*/
 
     [SchedDS] = 
       case datepart (dw,@dos)  
         when 1 THEN null            -- SUN
         when 2 THEN tm.scheduleMon  -- MON
         when 3 THEN tm.scheduleTue  -- TUE
         when 4 THEN tm.scheduleWed  -- WED
         when 5 THEN tm.scheduleThu  -- THU
         when 6 THEN tm.scheduleFri  -- FRI
         when 7 THEN null            -- SAT
       end,    
      
     calsch.SchMins,
     calsch.SchPer0Min,
     calsch.SchPer1Min,
     calsch.SchPer2Min,
     calsch.SchPer3Min,
     calsch.SchPer4Min,
     calsch.SchPer5Min,
     calsch.SchPer6Min,
     calsch.SchPer7Min,
     calsch.SchPer8Min,
     calsch.SchPer9Min,
     calsch.SchPer10Min,
     
     calsch.SchPass0to1Min,
     calsch.SchPass1to2Min,
     calsch.SchPass2to3Min,
     calsch.SchPass3to4Min,
     calsch.SchPass4to5Min,
     calsch.SchPass5to6Min,
     calsch.SchPass6to7Min,
     calsch.SchPass7to8Min,
     calsch.SchPass8to9Min,
     calsch.SchPass9to10Min,
     
     calsch.SchFirstPeriod,
     calsch.SchLastPeriod,
     calsch.SchNumPeriods,
      
     tm.tmtWhen,
     tm.tmtHow,
     
     calsch.calendarID,
     calsch.scheduleID,
     calsch.dayTypeID,
     calsch.calendarName,
     calsch.scheduleName,
     calsch.dayTypeName    
  
   from cte_rcr_svc                                              as rs 
   join RECURRING_SERVICES_DETAILS_SVC_SCHEDULE_OR_MINUTE_BASED  as tm on tm.rcrSvcID = rs.id
                                                               
   /*-------------------------------
    * Compute minutes from
    * dos, calendar, bell schedule
    *------------------------------*/
  
   outer apply(
     select 
       calendarID,
       scheduleID,
       dayTypeID,
       calendarName,
       scheduleName,
       dayTypeName,       
       attendanceMin as [SchMins],
       period0Min    as [SchPer0Min],
       period1Min    as [SchPer1Min],
       period2Min    as [SchPer2Min],
       period3Min    as [SchPer3Min],
       period4Min    as [SchPer4Min],
       period5Min    as [SchPer5Min],
       period6Min    as [SchPer6Min],
       period7Min    as [SchPer7Min],
       period8Min    as [SchPer8Min],
       period9Min    as [SchPer9Min],
       period10Min   as [SchPer10Min],
       
       pass0to1Min   as [SchPass0to1Min],
       pass1to2Min   as [SchPass1to2Min],
       pass2to3Min   as [SchPass2to3Min],
       pass3to4Min   as [SchPass3to4Min],
       pass4to5Min   as [SchPass4to5Min],
       pass5to6Min   as [SchPass5to6Min],
       pass6to7Min   as [SchPass6to7Min],
       pass7to8Min   as [SchPass7to8Min],
       pass8to9Min   as [SchPass8to9Min],
       pass9to10Min  as [SchPass9to10Min],

       firstPeriod   as [SchFirstPeriod],
       lastPeriod    as [SchLastPeriod],       
       numPeriods    as [SchNumPeriods]
     
     from dbo.CLIENT_ATTENDANCE_CALENDAR_SCHEDULE_DOS_DETAIL(rs.clientID, 
                                                             rs.calendarID, 
                                                             rs.scheduleID, 
                                                             @dos)  
   ) as calsch  
  ) as q1
)
,

/*============================================================
 * Treatment Minute or Minute Schedule Based Combined
 * Pass 1
 *============================================================*/ 
 
cte_rcr_svc_tmt_combo_1
as
(
  select *
  from
  (
    select * from cte_rcr_svc_tmt_min_based
    union all
    select * from cte_rcr_svc_tmt_min_or_sch_based  
  ) as q1
  where 
   (1=1) and ((@pracID  is null) or (q1.pracID  = @pracID))  
)

,

/*============================================================
 * Treatment Minute or Minute Schedule Based Combined
 * Pass 2
 *============================================================*/ 

cte_rcr_svc_tmt_combo_2
as
(
  select 
    tdd.*,
    [NumDailyMinsExpd]
  from cte_rcr_svc_tmt_combo_1 as tdd
  cross apply
  (
    select
     sum(NumMinsExpd) as [NumDailyMinsExpd]
    from cte_rcr_svc_tmt_combo_1
    where pracID = tdd.pracID
    group by
      pracID
  ) as tdm
  where 
        (1=1)
    and ((@tmtWhen is null) or (tdd.tmtWhen = @tmtWhen))
    and ((@tmtHow  is null) or (tdd.tmtHow  = @tmtHow))
)
,

/*============================================================
 * Treatment Minute or Minute Schedule Based Combined With
 * Procedures
 *============================================================*/ 

cte_rcr_svc_tmt_procs
as
(
  select 
    q1.*,
    [CalcPlanType] = dbo.AGE_IEP_TO_PLAN_TYPE(q1.PatAge,q1.inIEP)    
  from
  (
    select 
      datename(dw,@dos) as [dosName],
      datepart(dw,@dos) as [dosDow],
      @dos              as [dos],
      tm.*, 
      prp.CONCAT_NAME   as [PracName],
      pap.CONCAT_NAME   as [PatName],
      cc.CLIENT_NAME    as [clientName], 
      pap.DATE_OF_BIRTH as [PatDOB],
      [PatAge] = dbo.CALC_AGE (pap.DATE_OF_BIRTH, @dos),      
      pg.GROUP_ID       as [PracDispGroupID],
      sv.proc_id        as [ProcID],      
      sv.svc_Type       as [SvcType],
      sv.svc            as [Svc],
      sv.plan_type      as [SvcPlanType],
      sv.svc_name       as [SvcName],
      sv.name_id        as [SvcNameID],
      dbo.RPT_DATE_FMT       (@dos)         as [SvcSlotDate],
      dbo.RPT_PROC_MOD_COMBO (sv.proc_code,
                              sv.proc_mod1,
                              sv.proc_mod2,
                              sv.proc_mod3,
                              sv.proc_mod4) as [SvcSlotProc]
                               
    from cte_rcr_svc_tmt_combo_2             as tm
    join PRACTITIONER_Practitioner           as prp on prp.PRACTITIONER_ID = tm.pracID
    join PATIENTS_PATIENT                    as pap on pap.PATIENT_ID      = tm.patID
    join CLIENTS_CLIENT                      as cc  on cc.CLIENT_ID        = tm.clientID
    join dbo.PRACTITIONER_GROUPS_VIEW_DISP() as pg  on pg.PRACTITIONER_ID  = prp.PRACTITIONER_ID
    join dbo.SERVICES_VIEW_ALL()             as sv  on sv.prac_group_id    = pg.GROUP_ID

    where 
      (1=1)
      and ((@svcType    is null) or (sv.svc_Type    = @svcType))
      and ((@isOneOnOne is null) or (sv.isOneOnOne  = @isOneOnOne))
  ) as q1
)
,

/*============================================================
 * Determines if services have been received
 *============================================================*/ 
 
cte_rcr_svc_tmt_procs_svcs_recv
as
(
  select 
    rs.*, 
    isnull([SvcRecCount],0)    as [NumSvcsRecv], 
    isnull([SvcRecMins], 0)    as [NumDailyMinsRecv],  
    isnull([ClaimsWaiting], 0) as [NumSlotClaimsWaiting],
    isnull([ClaimsSent], 0)    as [NumSlotClaimsSent]
    
  from cte_rcr_svc_tmt_procs as rs

  outer apply(
    select
      count(id)       as [SvcRecCount],
      sum(numMins)    as [SvcRecMins]   
    from dbo.SERVICE_RECORDS   
    where 
      clientID     = @clientID
      and patID    = @patID       
      and dos      = rs.dos
      and pracID   = rs.pracID
      and nameID   = rs.SvcNameID 
      and state    != dbo.CONST_SVC_REC_STATE_DEL()
      and state    != dbo.CONST_SVC_REC_STATE_CIF()
    group by
      clientID,
      dos,
      pracID,    
      patID,
      nameID
  ) as srr
  
  outer apply
  (
    select       
      COUNT(CLAIM_ID) as [ClaimsWaiting]
    from CLAIM_CLAIM as cc
    where 
      CLIENT_ID        = @clientID
      and PATIENT_ID   = @patID
      and SERVICE_DATE = rs.dos
      and PROCEDURE_ID = rs.procID
      and STATUS       = dbo.CONST_CLAIM_STATUS_NOT_SUB()
    group by
      CLIENT_ID,
      PATIENT_ID,
      SERVICE_DATE,
      PROCEDURE_ID      
  ) as crp

outer apply
  (
    select       
      COUNT(CLAIM_ID) as [ClaimsSent]
    from CLAIM_CLAIM as cc
    where 
      CLIENT_ID        = @clientID
      and PATIENT_ID   = @patID
      and SERVICE_DATE = rs.dos
      and PROCEDURE_ID = rs.procID
      and STATUS       <> dbo.CONST_CLAIM_STATUS_NOT_SUB()
    group by
      CLIENT_ID,
      PATIENT_ID,
      SERVICE_DATE,
      PROCEDURE_ID      
  ) as crs  
    
  
)
,

/*============================================================
 * Limit output to just weekdays, perform cross ref sanity
 * check
 *============================================================*/ 
 
 cte_rs_output
 as
 (
  select 
    rs.*,
    [SvcSlotName]         = [SvcSlotDate] + ' - ' + [SvcSlotProc],
    isnull(pn.NOTE,'') as pracNote    
  from cte_rcr_svc_tmt_procs_svcs_recv as rs
  left join PRACTITIONER_Note          as pn on pn.NOTE_PRACTITIONER_ID = rs.pracID
  where 
        (SvcPlanType = CalcPlanType)
    and (dosDOW in (2,3,4,5,6))
 )
 
/*============================================================
 * Output
 *============================================================*/

select * from cte_rs_output

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_DETAIL] TO [webuser]
GO

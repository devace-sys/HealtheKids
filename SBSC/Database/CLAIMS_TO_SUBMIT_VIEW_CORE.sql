USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_TO_SUBMIT_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_TO_SUBMIT_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLAIMS_TO_SUBMIT_VIEW_CORE] (
   @clientID   as bigint
 , @oldestDOS  as datetime
 , @newestDOS  as datetime
)

/***************************************************************************    
 * CLAIMS_TO_SUBMIT_VIEW_CORE */    
/**    
 * Returns a table of claims that could be submitted
 * 
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   oldestDOS       Earliest date of service to work with
 *
 ***************************************************************************/ 
      
RETURNS TABLE 
AS 
RETURN (

with
cte_p0
as
(

select 
     [CLIENT_NAME]        = clc.CLIENT_NAME
   , [PATIENT_NAME]       = pap.CONCAT_NAME
   , [PRACTITIONER_NAME]  = prp.CONCAT_NAME
   , [CLIENT_ID]          = cc.CLIENT_ID
   , [PATIENT_ID]         = cc.PATIENT_ID
   , [SERVICE_DATE]       = cc.SERVICE_DATE    
   , [SERVICE_TYPE_ID]    = cp.SERVICE_TYPE_ID
   
   , [PROC_MOD_COMBO]     = dbo.RPT_PROC_MOD_COMBO (
       cp.PROCEDURE_CODE
     , cp.PROCEDURE_MODIFIER_1
     , cp.PROCEDURE_MODIFIER_2
     , cp.PROCEDURE_MODIFIER_3
     , cp.PROCEDURE_MODIFIER_4
  )
  
  , [SERVICE_RECORD_ID]         = sr.id
  , [SERVICE_RECORD_CLAIM_ID_1] = sr.claimID1
  , [SERVICE_RECORD_CLAIM_ID_2] = sr.claimID2
  , [SERVICE_RECORD_CLAIM_ID_3] = sr.claimID3
  , [SERVICE_RECORD_CLAIM_ID_4] = sr.claimID4
  , [SERVICE_RECORD_STATE]      = sr.state
  
  , [PRACTITIONER_ID]     = cc.PRACTITIONER_ID
  , [LINE_NUMBER]         = cc.LINE_NUMBER
  , [CLAIM_ID]            = cc.CLAIM_ID  
  , [PROCEDURE_ID]        = cc.PROCEDURE_ID
  , [SERVICE_UNITS]       = cc.SERVICE_UNITS 
  , [NUM_MINS]            = sr.numMins

  , [NUM_TRIPS]      = dbo.CALC_TOTAL_TRIPS_8 ( 
     sr.trip1start
    ,sr.trip1end
    ,sr.trip2start
    ,sr.trip2end
    ,sr.trip3start
    ,sr.trip3end
    ,sr.trip4start
    ,sr.trip4end
  )               
  
  , [NUM_MILES]      = dbo.CALC_TOTAL_MILES_8 ( 
     sr.trip1start
    ,sr.trip1end
    ,sr.trip2start
    ,sr.trip2end
    ,sr.trip3start
    ,sr.trip3end
    ,sr.trip4start
    ,sr.trip4end
  )
  
  , [TRIP_1_START] = sr.trip1start
  , [TRIP_1_END]   = sr.trip1end
  
  , [TRIP_2_START] = sr.trip2start
  , [TRIP_2_END]   = sr.trip2end

  , [TRIP_3_START] = sr.trip3start
  , [TRIP_3_END]   = sr.trip3end

  , [TRIP_4_START] = sr.trip4start
  , [TRIP_4_END]   = sr.trip4end

  , [PATIENT_VALID_BIC] = case when len(ltrim(rtrim(isnull(pap.bic,'')))) = 14 then 1 else 0 end
  
  --, [PATIENT_ELIG_MONTH_DATE]      = pen.MONTH_DATE
  --, [PATIENT_ELIG]                 = pen.IS_ELIG
  
  , [PROCEDURE_UNITS_MIN]          = cp.MIN_UNITS
  , [PROCEDURE_UNITS_MAX]          = cp.MAX_UNITS
  , [PROCEDURE_UNITS_MAX_SVC]      = cp.MAX_SERVICE_UNITS
  , [PROCEDURE_UNIT_TYPE]          = cp.UNIT_TYPE
  , [PROCEDURE_SERVICE_FEE]        = cp.SERVICE_FEE

  , [CLAIM_STATUS]        = cc.STATUS
  , [CLAIM_HOLD]          = cc.HOLD
 
  , [CLAIM_PROXY_PART_OF] = case
      when (cc.HAS_PROXY = 0) AND (cc.IS_PROXY = 0) then 0
      when (cc.HAS_PROXY = 0) AND (cc.IS_PROXY = 1) then 1
      when (cc.HAS_PROXY = 1) AND (cc.IS_PROXY = 0) then 1
      when (cc.HAS_PROXY = 1) AND (cc.IS_PROXY = 1) then 1 /* Not supposed to happen */      
    end

  , [CLAIM_HAS_PROXY]      = cc.HAS_PROXY
  , [CLAIM_IS_PROXY]       = cc.IS_PROXY
  
  , [ENTERED_ON]           = cc.ENTRY_DATE
  , [ENTERED_BY_USER_ID]   = cc.[USER_ID]
  , [ENTERED_BY_USER_NAME] = u.UserName
  , [ENTERED_BY_SBSC]      = case when (m.SBSC_Employee = 1) then 1 else 0 end
  , [ENTERED_BY_CLIENT]    = case when (m.SBSC_Employee = 0) then 1 else 0 end

  , [SUBMIT_CLAIMS] = case 
      when ((isnull(pap.SUBMIT_CLAIMS,0) = 0) and (isnull(prp.SUBMIT_CLAIMS,0) = 0)) then 0 
      when ((isnull(pap.SUBMIT_CLAIMS,0) = 0) and (isnull(prp.SUBMIT_CLAIMS,0) = 1)) then 0 
      when ((isnull(pap.SUBMIT_CLAIMS,0) = 1) and (isnull(prp.SUBMIT_CLAIMS,0) = 0)) then 0 
      when ((isnull(pap.SUBMIT_CLAIMS,0) = 1) and (isnull(prp.SUBMIT_CLAIMS,0) = 1)) then 1 
  end
  
 , [ORP_REQUIRED]         = isnull(sr.orpRequired,0) /* TODO: Change this after testing */
 , [SVC_IS_ORP_COMPLIANT] = dbo.IS_ORP_COMPLIANT (  sr.orpRequired
                                                  , dbo.IS_VALID_NPI(sr.orpPracNPI)
                                                  , sr.orpValidMcalOrp)

, [WAITING_FOR_INPUT_BATCH_COMPLETE] = convert(bit, case 
    when (m.SBSC_Employee = 0) then 0 
	else case when (wfib.id is not null) then 1 else 0 end 
  end)
  


from dbo.CLAIM_Claim               as cc
join dbo.CLAIM_Procedures          as cp    on cp.PROCEDURE_ID     = cc.PROCEDURE_ID
join dbo.PATIENTS_Patient          as pap   on pap.PATIENT_ID      = cc.PATIENT_ID
join dbo.PRACTITIONER_Practitioner as prp   on prp.PRACTITIONER_ID = cc.PRACTITIONER_ID
join dbo.SERVICE_RECORD_CLAIMS     as src   on src.claimID         = cc.CLAIM_ID
join dbo.SERVICE_RECORDS           as sr    on sr.id               = src.svcRecID
join users.dbo.Users               as u     on u.userrid           = cc.USER_ID
join users.dbo.Membership          as m     on m.UserId            = u.UserId
join dbo.CLIENTS_Client            as clc   on clc.CLIENT_ID       = cc.CLIENT_ID

/* 
 * Determine if these service records are associated with an input batch and the batch is
 * not complete.  
 */

outer apply (  
  select top 1 
     ib.id
  from dbo.INPUT_BATCHES_SERVICE_RECORDS	as ibsr
  join dbo.INPUT_BATCHES				    as ib on ib.id = ibsr.inputbatchid
  where ((m.SBSC_Employee = 1) and (ibsr.svcRecID = sr.id ) and (ib.Current_status_Code != 200))
) as wfib


/* 
 * Client TCM Check
 * Note: Keep this in synch with TRANSMISSION_GENERATION_APPLY_HOLDS.sql
 */

outer apply (
	  
	select top 1 
	    ctcm.idx
	 from dbo.CLAIM_TCM_FLAG_HISTORY_VIEW ( 1, @clientID) as ctcm
     where (
           (cp.SERVICE_TYPE_ID = dbo.CONST_SERVICES_TCM())
       and (cc.ENTRY_DATE between ctcm.entryStartDate and ctcm.entryEndDate)
       and (cc.SERVICE_DATE >= ctcm.effectiveDate)	
	   and (ctcm.claimTCM  = 0)
   )
) as clientTCMCheck

/* 
 * Prac TCM Check
 * Note: Keep this in synch with TRANSMISSION_GENERATION_APPLY_HOLDS.sql
 */

outer apply (	  
	select top 1 
	    ctcm.idx
	 from dbo.CLAIM_TCM_FLAG_HISTORY_VIEW ( 2, cc.PRACTITIONER_ID) as ctcm
     where (
           (cp.SERVICE_TYPE_ID = dbo.CONST_SERVICES_TCM())
       and (cc.ENTRY_DATE between ctcm.entryStartDate and ctcm.entryEndDate)
       and (cc.SERVICE_DATE >= ctcm.effectiveDate)
	   and (ctcm.claimTCM  = 0)
   )
) as pracTCMCheck

where (
      (1=1)
  and (cc.CLIENT_ID = @clientID)
  and (cc.SERVICE_DATE between @oldestDOS and @newestDOS)
  and (cc.STATUS  = '1') /* Not submitted, replaced with char to eliminate implicit conversion */
  --and (cc.STATUS  = dbo.CONST_CLAIM_STATUS_NOT_SUB())
  --and (sr.state  != dbo.CONST_SVC_REC_STATE_DEL())
  and (sr.state  != dbo.CONST_SVC_REC_STATE_SUB())
  and (sr.state  != dbo.CONST_SVC_REC_STATE_CIF())
  and (sr.patAbsent = 0)
  and (cp.PUT_IN_837        =  1)
  and (cp.CPT_PROCEDURE     =  1)
  and (pap.SUBMIT_CLAIMS    =  1)
  and (prp.SUBMIT_CLAIMS    =  1)
  and (clientTCMCheck.idx is null) /* No TCM hold for client */
  and (pracTCMCheck.idx   is null) /* No TCM hold for practitioner */
  and (clc.LEA              =  1)
)
)
,

/*###########################################################################
  # Exclude service records associated with incomplete input batches.
  # Note: We don't want to return the computation we use to determine this
  # hence the explicit column inclusion.
  ###########################################################################*/    

cte_p1
as
(
  select 
      [CLIENT_NAME]       
    , [PATIENT_NAME]       
    , [PRACTITIONER_NAME]  
    , [CLIENT_ID]          
    , [PATIENT_ID]         
    , [SERVICE_DATE]       
    , [SERVICE_TYPE_ID]       
    , [PROC_MOD_COMBO]       
    , [SERVICE_RECORD_ID]         
    , [SERVICE_RECORD_CLAIM_ID_1] 
    , [SERVICE_RECORD_CLAIM_ID_2] 
    , [SERVICE_RECORD_CLAIM_ID_3] 
    , [SERVICE_RECORD_CLAIM_ID_4] 
    , [SERVICE_RECORD_STATE]  
    , [PRACTITIONER_ID]
    , [LINE_NUMBER]  
    , [CLAIM_ID]     
    , [PROCEDURE_ID] 
    , [SERVICE_UNITS]
    , [NUM_MINS]     
    , [NUM_TRIPS]      
    , [NUM_MILES]    
    , [TRIP_1_START] 
    , [TRIP_1_END]     
    , [TRIP_2_START] 
    , [TRIP_2_END]   
    , [TRIP_3_START] 
    , [TRIP_3_END]   
    , [TRIP_4_START] 
    , [TRIP_4_END]   
    , [PATIENT_VALID_BIC]   
    , [PROCEDURE_UNITS_MIN] 
    , [PROCEDURE_UNITS_MAX] 
    , [PROCEDURE_UNITS_MAX_SVC]
    , [PROCEDURE_UNIT_TYPE]    
    , [PROCEDURE_SERVICE_FEE]  
    , [CLAIM_STATUS]        
    , [CLAIM_HOLD]           
    , [CLAIM_PROXY_PART_OF] 
    , [CLAIM_HAS_PROXY]     
    , [CLAIM_IS_PROXY]      
    , [ENTERED_ON]          
    , [ENTERED_BY_USER_ID]  
    , [ENTERED_BY_USER_NAME]
    , [ENTERED_BY_SBSC]   
    , [ENTERED_BY_CLIENT] 
    , [SUBMIT_CLAIMS] 
    , [ORP_REQUIRED] 
    , [SVC_IS_ORP_COMPLIANT]                                                       
 from cte_p0
 where (WAITING_FOR_INPUT_BATCH_COMPLETE = 0)
)
,

/*###########################################################################
  # Journal 
  # Not limited to groups that require service records to be held because
  # journal is HS only and HA and LVN are required to have svcs held until 
  # approved.
  ###########################################################################*/    

cte_p2
as
(
select
    sr.*        
  , [JOURNAL_ASSOC]    = convert(bit, case ((isnull(srj.[JOURNAL_ID],-1))) when -1 then 0 else 1 end)
  , srj.*
 from cte_p1 as sr
 
 outer apply (

   select top 1
     [JOURNAL_ID]       = journalID 
   , [JOURNAL_STATE_OK] = convert(bit,case when (numJournalSvcs = numJournalSvcsOK) then 1 else 0 end)

   from (
     select top 1
       journalID
     , count(journalSvcRecID) AS numJournalSvcs
     , sum(journalSvcStateOK) AS numJournalSvcsOK
     from (
       select
         journalID
       , journalSvcRecID
       , journalSvcStateOK = case when (journalCompleted = 1) then
                               case when (approvalSystem = 1) then
                                 case when (reqPracSupApproval = 1) then
                                   pracSupApproval
                                 else 1 end /* If no approval needed then automatic OK*/                                
                               else 1 end /* If no approval system them automatic OK */
                             else 0 end /* If journal is not completed, not OK */
       from (
         select
           journalID          = sj.id
         , journalCompleted   = sj.completed
         , journalSvcRecID    = sjsr2.svcRecID
         , approvalSystem     = isnull(sro.approvalSystem,0)
         , reqPracSupApproval = case when (sra.id IS NULL) then 0 else 1 end
         , pracSupApproval    = isnull(sra.approved,0)
         from (
           select top 1 * FROM dbo.SvcJournal_Service_Records AS q0 WHERE q0.svcRecID = sr.[SERVICE_RECORD_ID]           
         ) AS sjsr1                        
         JOIN      dbo.SvcJournals                      AS sj    ON sj.id           = sjsr1.journalID
         JOIN      dbo.SvcJournal_Service_Records       AS sjsr2 ON sjsr2.journalID = sj.id
         LEFT JOIN dbo.SERVICE_RECORDS_APPROVAL_OPTIONS AS sro   ON sro.clientID    = sj.clientID
         LEFT JOIN dbo.SERVICE_RECORDS_APPROVAL         AS sra   ON sra.svcRecID    = sjsr2.svcRecID        
         WHERE (sjsr1.svcRecID = sr.[SERVICE_RECORD_ID])
         ) AS q1
       ) AS q2
       GROUP BY journalID
     ) AS q3
 ) AS srj  
)
,

/*###########################################################################
  # Service Record Approval
  # Limited to groups that require service records to be held
  ###########################################################################*/    

cte_p3
as
(

  select
      sr.* 
    , [SVC_REC_APPROVAL_ASSOC]  = convert(bit, case ((isnull(sra.[SVC_REC_APPROVAL_ID] ,-1))) when -1 then 0 else 1 end)
    , sra.*
  from cte_p2 as sr

  outer apply (

    select top 1
  
      [SVC_REC_APPROVAL_SYSTEM] = svcRecApprovalSystem
    , [SVC_REC_APPROVAL_ID]     = svcRecApprovalID 
    , [SVC_REC_APPROVAL_OK]     = case when (svcRecApprovalSystem = 1) then
                                    case when (reqPracSupApproval = 1) then pracSupApproval else 1 end
                                  else 1 end
    from (
      select top 1
        svcRecApprovalSystem = approvalSystem
      , svcRecApprovalID   = q1.id
      , reqPracSupApproval = case when (q1.id IS NULL) then 0 else 1 end
      , pracSupApproval    = isnull(q1.approved,0)
     from (
       select top 1
         ra.*
       , isnull(ao.approvalSystem,0) AS approvalSystem
       from      dbo.SERVICE_RECORDS_APPROVAL                 as ra
	   join      dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR as dss on dss.SUPERVISED_GROUP_ID = ra.groupID
	   left join dbo.SERVICE_RECORDS_APPROVAL_OPTIONS         as ao  on ao.clientID = ra.clientID
       
	   where (
			 (ra.svcRecID = sr.[SERVICE_RECORD_ID]) 
		 and (ra.active = 1)
		 and (dss.holdServiceRecordsUntilApproved = 1) 
	   )
       ) as q1
     ) as q2  
  ) as sra
)
,

/*###########################################################################
  # ORP Compliance
  ###########################################################################*/    

cte_p4
as
(  

  select 
    
     p3.*
    ,NUM_OF_SAME_PROC_MOD_COMBO_NON_ORP_COMPLIANT_SVCS = isnull(orp.NUM_OF_MATCHING_NON_ORP_COMPLIANT_SVCS,0)
    
  from cte_p3 as p3
  
  outer apply (             
 
       select
         NUM_OF_MATCHING_NON_ORP_COMPLIANT_SVCS = count (q2.id)
       from
       (
         select distinct
           q1.id       
         from
         (
            select                    
              svcIsOrpCompliant = dbo.IS_ORP_COMPLIANT ( sr.orpRequired
                                                       , dbo.IS_VALID_NPI(sr.orpPracNPI)
                                                       , sr.orpValidMcalOrp)
            , sr.id
   
        from dbo.SERVICE_RECORDS       as sr
        join dbo.SERVICE_RECORD_CLAIMS as src on src.svcRecID    = sr.id
        join dbo.CLAIM_Claim           as cc  on cc.CLAIM_ID     = src.claimID   
        where (
                (sr.clientID  = @clientID)
            and (sr.dos       = p3.[SERVICE_DATE])            
            and (sr.patID     = p3.[PATIENT_ID])            
            and (sr.svcType   = dbo.CONST_SERVICES_TREATMENT())
            and (sr.state    != dbo.CONST_SVC_REC_STATE_DEL())
            and (sr.state    != dbo.CONST_SVC_REC_STATE_SUB())
            and (sr.state    != dbo.CONST_SVC_REC_STATE_CIF())
            and (cc.PROCEDURE_ID = p3.[PROCEDURE_ID]))
        ) as q1
        where (q1.svcIsOrpCompliant = 0)      
      ) as q2     
  ) as orp  
)
,
cte_p5
as
(
  select    
    *
  , [WAITING_FOR_JOURNAL]           = case when ([JOURNAL_ASSOC]  = 0) then 0 else
                                        case when ([JOURNAL_STATE_OK] = 1 ) then 0 else 1 end
                                      end

  , [WAITING_FOR_SVC_REC_APPROVAL]  = case when ([SVC_REC_APPROVAL_ASSOC] = 0) then 0 else
                                        case when ([SVC_REC_APPROVAL_OK]  = 1) then 0 else 1 end
                                      end

  , [WAITING_FOR_VALID_ORP]         = case when ([ORP_REQUIRED] = 0) then 0 else
                                        case when (NUM_OF_SAME_PROC_MOD_COMBO_NON_ORP_COMPLIANT_SVCS = 0) then 0 else 1 end
                                      end
from cte_p4
)

select * from cte_p5

)
GO





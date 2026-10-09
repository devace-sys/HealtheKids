USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_FOR_CLIENT') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_FOR_CLIENT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE dbo.UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_FOR_CLIENT
(
  @clientID as bigint
)
AS    

BEGIN     
    
/***************************************************************************    
 * UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_FOR_CLIENT */    
/**    
 * 
 ***************************************************************************/         

SET NOCOUNT ON        

declare @today                  as datetime
declare @oldestDOS              as datetime 
declare @rmtsStartsOn           as datetime = dbo.CONST_RMTS_PARTICIPATION_REQUIRED_START_DATE()
declare @dSupStartsOn           as datetime = dbo.CONST_DIRECT_SUPERVISION_REQUIRED_START_DATE()
declare @msg                    as nvarchar(1000)
declare @clientIDFound          as bigint
declare @forSpaID               as bigint   = 1

BEGIN TRY

/*#####################################################################################################################*/

set @msg           = N''
set @clientIDFound = null

select top 1 
    @clientIDFound = clc.CLIENT_ID
  , @msg            = N'Updating claims currently held data for ' + clc.CLIENT_NAME
from dbo.CLIENTS_Client_Active_LEA as clc
where (clc.CLIENT_ID = @clientID)

if (@clientIDFound is null)
begin
  RAISERROR ('Updating claims currently held data could not find active client', 0, 1) WITH NOWAIT 
  return(0)
end

RAISERROR (@msg, 0, 1) WITH NOWAIT 

/*#####################################################################################################################*/

/*============================================================
 * Setup date ranges
 *============================================================*/  

RAISERROR ('Calculating oldest date of service', 0, 1) WITH NOWAIT 
set @today     = getdate()
set @oldestDOS = dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,@today))

/*#####################################################################################################################*/

/*============================================================
 * Remove old data
 *============================================================*/  

RAISERROR ('Removing old detail data', 0, 1) WITH NOWAIT 
delete from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA
where (CLIENT_ID = @clientID)

/*#####################################################################################################################*/

RAISERROR ('Searching for claims that may have not been put in an 837 yet', 0, 1) WITH NOWAIT 

RAISERROR ('Retroactive claims', 0, 1) WITH NOWAIT 

/*============================================================
 * Get new detail data for retroactive claims (for SPA)
 *============================================================*/  

insert into dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA
select distinct
    HELD                     = 0
  , HOLD_CODE                = 0
  , RECOMMENDED_ACTION_CODE  = 0
  , ADDITIONAL_INFORMATION   = N''
  
  , JOURNAL_ID               = null
  , SVC_REC_ID               = sr.id 
  , SVC_REC_APPROVAL_ID      = null
  , cc.CLAIM_ID
  , CLAIM_REFERENCE_CLAIM_1_ID = cc.REFERENCE_CLAIM_ID_1

  , CLIENT_ID                 = sr.clientID
  , CLIENT_NAME               = clc.CLIENT_NAME
  , CLIENT_LAST_TX_DATE_TIME  = clc.LAST_TRANSMISSION_DATETIME
  , CLIENT_LAST_TX_DAYS_AGO   = null
  , CLIENT_LAST_TX_GEN_ID     = clc.LAST_TRANSMISSION_GENERATION_ID
  , CLIENT_CLAIM_NO_PLAN      = isnull(clc.CLIENT_CLAIM_NO_PLAN,1)
  , CLIENT_CLAIM_TCM          = isnull(clc.CLIENT_CLAIM_TCM,1)	
  , CLIENT_HOLD_WORK_FOR_DAYS = clc.HOLD_CLIENT_WORK_FOR_DAYS
  
  , REP_ID     = clc.REP_ID    
  , REP_NAME   = clc.REP_NAME
  , REP_EMAIL  = clc.REP_EMAIL
	  
  , PAT_ID     = sr.patID
  , PAT_NAME   = pap.CONCAT_NAME
  , PAT_BIC    = trim(isnull(pap.BIC,N''))
  , PAT_CSIS   = trim(isnull(pap.CSIS,''))
  , PAT_DOB    = pap.DATE_OF_BIRTH
  , PAT_SUBMIT_CLAIMS        = isnull(pap.SUBMIT_CLAIMS,1)
  , PAT_MCAL_PARENT_CONSENT  = (isnull(pap.parentConsentMCAL,isnull(clc.CLIENT_PARENT_CONSENT_AGREEMENT,1)))
  , PAT_ACTIVE               = dbo.YN_TO_BIT(pap.ACTIVE)

  , PRAC_ID               = sr.pracID
  , PRAC_NAME             = prp.CONCAT_NAME
  , PRAC_ACTIVE           = prp.ACTIVE
  , PRAC_SUBMIT_CLAIMS    = isnull(prp.SUBMIT_CLAIMS,1) 
  , PRAC_CLAIM_TCM        = isnull(prp.CLAIM_TCM,1)

  , PRAC_GROUP_FAMILY_ID   = gf.GROUP_SERVICE_CLASS_NAME_ID
  , PRAC_GROUP_FAMILY_NAME = gf.GROUP_SERVICE_CLASS_NAME
  , PRAC_GROUP_ID          = sr.groupID
  , PRAC_GROUP_NAME        = gf.GROUP_NAME  

  , SVC_DOS                = sr.dos
  , SVC_DOS_MONTH_YEAR     = null
  , SVC_DOS_AGE_IN_DAYS    = null
  , SVC_DOS_USE_OR_LOSE    = null

  , SVC_TYPE_ID            = sr.svcType
  , SVC_IS_IEP             = sr.isIFSPorIEP
  , SVC_TYPE_NAME          = cpst.SERVICE_TYPE_NAME
  , SVC_ORP_REQ            = isnull(sr.orpRequired,0)
  , SVC_ORP_DOC_ID         = isnull(sr.orpDocID,0)
  , SVC_ORP_PRAC_ID        = isnull(sr.orpPracID,0)
  , SVC_ORP_PRAC_NPI       = trim(isnull(sr.orpPracNPI,''))
  , SVC_ORP_PRAC_VALID     = isnull(sr.orpValidMcalOrp,0)
  , SVC_ENTERED_BY_PCAL    = m.SBSC_Employee
  , SVC_CREATED_MODIFIED   = coalesce (sr.lastmodified,sr.created)
  , SVC_ENTRY_TYPE_ID      = sr.entryType
  , SVC_ENTRY_TYPE_NAME    = sret.Name
  , SVC_ENTERED_DAYS_AGO   = null
  , SVC_ENTERED_DAYS_AGO_TX_DATE = null
  , SVC_UNITS              = cc.SERVICE_UNITS

  , cp.PROCEDURE_ID
  , cp.PROCEDURE_NAME
  , PROCEDURE_CODE_MOD_COMBO   = dbo.RPT_PROC_MOD_COMBO(cp.PROCEDURE_CODE, cp.PROCEDURE_MODIFIER_1, cp.PROCEDURE_MODIFIER_2, cp.PROCEDURE_MODIFIER_3, cp.PROCEDURE_MODIFIER_4)
  , PROCEDURE_IS_Q             = convert(bit,case when (cp.PROCEDURE_CODE like 'Q%') then 1 else 0 end)
  , PROCEDURE_PUT_IN_837       = cp.PUT_IN_837
  , PROCEDURE_CLIENT_NOT_CLAIM = null
  
  , CLAIM_HOLD                 = cc.HOLD
  , CLAIM_STATUS               = cc.STATUS
  , CLAIM_HAS_PROXY            = cc.HAS_PROXY
  , CLAIM_IS_PROXY             = cc.IS_PROXY
  , CLAIM_LINE_NUMBER          = cc.LINE_NUMBER
  , TRANS_MATCH_SVC_REC_ID     = null  
  , EST_AMT = rc.estReimburse
  , LAST_TX_HOLD_REASON        = null
  , LAST_UPDATED               = @today  
  , rmtsCompliant              = 1 /* Assume compliant unless proven otherwise */
  , supervisionCompliant       = 1 /* Assume compliant unless proven otherwise */
  , claimSource                = 2 /* Retro from SPA */
  , clientAuthorizedNonCurrent = rc.authorized
  , ffpQualified               = pap.ffpQualified
  , isLeaBopEligible           = dbo.IS_PATIENT_POSSIBLY_LEA_BOP_ELIG (pap.BIC, pap.ffpQualified) 
  , cprCertCompliant           = 1 /* We are not going to be submitting these claims so this is just for compatibility*/
  , acesCertCompliant          = 1 /* We are not going to be submitting these claims so this is just for compatibility*/

from dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SERVICE_RECORD_CLAIMS_POSSIBLE_VIEW_CORE (
    @forSpaID
  , @clientID
  , null) as rc

join dbo.CLIENTS_Client_Active_LEA      as clc  on clc.CLIENT_ID    = rc.clientID
join dbo.CLAIM_Claim                    as cc   on cc.CLAIM_ID      = rc.claimID											   
join dbo.CLAIM_Procedures               as cp   on cp.PROCEDURE_ID  = cc.PROCEDURE_ID  
join dbo.SERVICE_RECORD_CLAIMS          as src  on src.claimID      = cc.CLAIM_ID
join dbo.SERVICE_RECORDS                as sr   on  sr.id           = src.svcRecID
join dbo.SERVICE_RECORD_ENTRY_TYPES     as sret on sret.ID          = sr.entryType
join dbo.CLAIM_Procedures_Service_Types as cpst on cpst.SERVICE_TYPE_ID = sr.svcType

join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as gf on gf.GROUP_SERVICE_CLASS_PARTITION_ID = 100
                                                                and gf.GROUP_ID = sr.groupID
join dbo.PATIENTS_Patient               as pap on pap.PATIENT_ID      = sr.patID
join dbo.PRACTITIONER_Practitioner      as prp on prp.PRACTITIONER_ID = sr.pracID
join users.dbo.Users                    as u   on u.userrid           = sr.userID
join users.dbo.Membership               as m   on m.UserId            = u.UserId

where ( 
   (cc.STATUS in ('1','12'))
)

/*#####################################################################################################################*/

/*============================================================
 * Get new detail data for current claims
 *============================================================*/  

RAISERROR ('Current claims', 0, 1) WITH NOWAIT 

insert into dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA

select

    HELD                     = 0
  , HOLD_CODE                = 0
  , RECOMMENDED_ACTION_CODE  = 0
  , ADDITIONAL_INFORMATION   = N''
  
  , JOURNAL_ID               = null
  , SVC_REC_ID               = sr.id 
  , SVC_REC_APPROVAL_ID      = null
  , cc.CLAIM_ID
  , CLAIM_REFERENCE_CLAIM_1_ID = cc.REFERENCE_CLAIM_ID_1

  , CLIENT_ID                 = sr.clientID
  , CLIENT_NAME               = clc.CLIENT_NAME
  , CLIENT_LAST_TX_DATE_TIME  = clc.LAST_TRANSMISSION_DATETIME
  , CLIENT_LAST_TX_DAYS_AGO   = null
  , CLIENT_LAST_TX_GEN_ID     = clc.LAST_TRANSMISSION_GENERATION_ID
  , CLIENT_CLAIM_NO_PLAN      = isnull(clc.CLIENT_CLAIM_NO_PLAN,1)
  , CLIENT_CLAIM_TCM          = isnull(clc.CLIENT_CLAIM_TCM,1)	
  , CLIENT_HOLD_WORK_FOR_DAYS = clc.HOLD_CLIENT_WORK_FOR_DAYS
  
  , REP_ID     = clc.REP_ID    
  , REP_NAME   = clc.REP_NAME
  , REP_EMAIL  = clc.REP_EMAIL
	  
  , PAT_ID     = sr.patID
  , PAT_NAME   = pap.CONCAT_NAME
  , PAT_BIC    = trim(isnull(pap.BIC,N''))
  , PAT_CSIS   = trim(isnull(pap.CSIS,''))
  , PAT_DOB    = pap.DATE_OF_BIRTH
  , PAT_SUBMIT_CLAIMS        = isnull(pap.SUBMIT_CLAIMS,1)
  , PAT_MCAL_PARENT_CONSENT  = (isnull(pap.parentConsentMCAL,isnull(clc.CLIENT_PARENT_CONSENT_AGREEMENT,1)))
  , PAT_ACTIVE               = dbo.YN_TO_BIT(pap.ACTIVE)

  , PRAC_ID               = sr.pracID
  , PRAC_NAME             = prp.CONCAT_NAME
  , PRAC_ACTIVE           = prp.ACTIVE
  , PRAC_SUBMIT_CLAIMS    = isnull(prp.SUBMIT_CLAIMS,1) 
  , PRAC_CLAIM_TCM        = isnull(prp.CLAIM_TCM,1)

  , PRAC_GROUP_FAMILY_ID   = gf.GROUP_SERVICE_CLASS_NAME_ID
  , PRAC_GROUP_FAMILY_NAME = gf.GROUP_SERVICE_CLASS_NAME
  , PRAC_GROUP_ID          = sr.groupID
  , PRAC_GROUP_NAME        = gf.GROUP_NAME  

  , SVC_DOS                = sr.dos
  , SVC_DOS_MONTH_YEAR     = null
  , SVC_DOS_AGE_IN_DAYS    = null
  , SVC_DOS_USE_OR_LOSE    = null

  , SVC_TYPE_ID            = sr.svcType
  , SVC_IS_IEP             = sr.isIFSPorIEP
  , SVC_TYPE_NAME          = cpst.SERVICE_TYPE_NAME
  , SVC_ORP_REQ            = isnull(sr.orpRequired,0)
  , SVC_ORP_DOC_ID         = isnull(sr.orpDocID,0)
  , SVC_ORP_PRAC_ID        = isnull(sr.orpPracID,0)
  , SVC_ORP_PRAC_NPI       = trim(isnull(sr.orpPracNPI,''))
  , SVC_ORP_PRAC_VALID     = isnull(sr.orpValidMcalOrp,0)
  , SVC_ENTERED_BY_PCAL    = m.SBSC_Employee
  , SVC_CREATED_MODIFIED   = coalesce (sr.lastmodified,sr.created)
  , SVC_ENTRY_TYPE_ID      = sr.entryType
  , SVC_ENTRY_TYPE_NAME    = sret.Name
  , SVC_ENTERED_DAYS_AGO   = null
  , SVC_ENTERED_DAYS_AGO_TX_DATE = null
  , SVC_UNITS              = cc.SERVICE_UNITS

  , cp.PROCEDURE_ID
  , cp.PROCEDURE_NAME
  , PROCEDURE_CODE_MOD_COMBO   = dbo.RPT_PROC_MOD_COMBO(cp.PROCEDURE_CODE, cp.PROCEDURE_MODIFIER_1, cp.PROCEDURE_MODIFIER_2, cp.PROCEDURE_MODIFIER_3, cp.PROCEDURE_MODIFIER_4)
  , PROCEDURE_IS_Q             = convert(bit,case when (cp.PROCEDURE_CODE like 'Q%') then 1 else 0 end)
  , PROCEDURE_PUT_IN_837       = cp.PUT_IN_837
  , PROCEDURE_CLIENT_NOT_CLAIM = null
  
  , CLAIM_HOLD                 = cc.HOLD
  , CLAIM_STATUS               = cc.STATUS
  , CLAIM_HAS_PROXY            = cc.HAS_PROXY
  , CLAIM_IS_PROXY             = cc.IS_PROXY
  , CLAIM_LINE_NUMBER          = cc.LINE_NUMBER
  , TRANS_MATCH_SVC_REC_ID     = null  
    
  , EST_AMT = dbo.CALC_REIMBURSE_ESTIMATE (  sr.svcType      
                                           , cc.SERVICE_UNITS
                                           , clc.TCM_RATE
                                           , cp.MIN_UNITS
                                           , cp.MAX_UNITS
                                           , cp.SERVICE_FEE
                                           , cp.TCM_LOW_RATE
                                           , cp.TCM_MEDIUM_RATE
                                           , cp.TCM_HIGH_RATE )

  , LAST_TX_HOLD_REASON        = null
  , LAST_UPDATED               = @today  
  , rmtsCompliant              = 1 /* Assume compliant unless proven otherwise */
  , supervisionCompliant       = 1 /* Assume compliant unless proven otherwise */
  , claimSource                = 1 /* Current */
  , clientAuthorizedNonCurrent = null
  , ffpQualified               = pap.ffpQualified
  , isLeaBopEligible           = dbo.IS_PATIENT_POSSIBLY_LEA_BOP_ELIG (pap.BIC, pap.ffpQualified) 
  , cprCertCompliant           = 1 /* Assume compliant unless proven otherwise */
  , acesCertCompliant          = 1 /* Assume compliant for all cases until proven otherwise */

from dbo.CLIENTS_Client_Active_LEA      as clc
join dbo.CLAIM_Claim                    as cc   on cc.CLIENT_ID     = clc.CLIENT_ID											   
join dbo.CLAIM_Procedures               as cp   on cp.PROCEDURE_ID  = cc.PROCEDURE_ID  
join dbo.SERVICE_RECORD_CLAIMS          as src  on src.claimID      = cc.CLAIM_ID
join dbo.SERVICE_RECORDS                as sr   on  sr.id           = src.svcRecID
join dbo.SERVICE_RECORD_ENTRY_TYPES     as sret on sret.ID          = sr.entryType
join dbo.CLAIM_Procedures_Service_Types as cpst on cpst.SERVICE_TYPE_ID = sr.svcType

join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as gf on gf.GROUP_SERVICE_CLASS_PARTITION_ID = 100
                                                                and gf.GROUP_ID = sr.groupID
join dbo.PATIENTS_Patient               as pap on pap.PATIENT_ID      = sr.patID
join dbo.PRACTITIONER_Practitioner      as prp on prp.PRACTITIONER_ID = sr.pracID
join users.dbo.Users                    as u   on u.userrid           = sr.userID
join users.dbo.Membership               as m   on m.UserId            = u.UserId

where ( 
        (clc.CLIENT_ID = @clientID)
   and  (cc.SERVICE_DATE between @oldestDOS and @today)
   and  (cp.SERVICE_TYPE_ID in (1,2,3,4)) 
   and  (cc.STATUS in ('1','12'))
)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Remove proxied claims that have been sent', 0, 1) WITH NOWAIT 

delete t1
from  dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as t1
join  dbo.CLAIM_Claim                                  as rc1 on rc1.CLAIM_ID = t1.CLAIM_REFERENCE_CLAIM_1_ID
where (
      (t1.CLIENT_ID = @clientID)
  and (t1.CLAIM_HAS_PROXY = 1) 
  and (rc1.IS_PROXY = 1) 
  and (rc1.STATUS != '1')
)

/*#####################################################################################################################*/

/*============================================================
 * Update service ages
 *============================================================*/  

RAISERROR ('Updating svc ages and other date related stats', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set

    SVC_DOS_MONTH_YEAR           = dbo.DATE_START(SVC_DOS,3)
  , SVC_DOS_AGE_IN_DAYS          = DATEDIFF(day,SVC_DOS,@today)
  , SVC_DOS_USE_OR_LOSE          = dbo.CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM(SVC_DOS,@today)
  , SVC_ENTERED_DAYS_AGO         = datediff(day,SVC_CREATED_MODIFIED,@today)
  , CLIENT_LAST_TX_DAYS_AGO      = datediff(day,CLIENT_LAST_TX_DATE_TIME,@today)
  , SVC_ENTERED_DAYS_AGO_TX_DATE = datediff(day,SVC_CREATED_MODIFIED,CLIENT_LAST_TX_DATE_TIME)

where (CLIENT_ID = @clientID)

/*#####################################################################################################################*/

/*============================================================
 * Get associated records
 *============================================================*/  

RAISERROR ('Get associated records', 0, 1) WITH NOWAIT 

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Retrive last transmission hold reason', 0, 1) WITH NOWAIT 

update t1 
  set t1.LAST_TX_HOLD_REASON = t2.holdReason
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA                             as t1
join dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD as t2 on t2.GenerationID = t1.CLIENT_LAST_TX_GEN_ID 
                                                  and t2.ClaimID = t1.CLAIM_ID
where (CLIENT_ID = @clientID)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Get active journal assocations', 0, 1) WITH NOWAIT 

update t1 
  set JOURNAL_ID = sj.id
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA  as t1
join dbo.SvcJournal_Service_Records          as sjsr on sjsr.svcRecID = t1.SVC_REC_ID
join dbo.SvcJournals                         as sj on sj.id = sjsr.journalID
where ((t1.CLIENT_ID = @clientID) and (sj.active = 1))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Get active service record approval associations', 0, 1) WITH NOWAIT

/* Note: Limited to groups that require service records to be held */

update t1 
  set SVC_REC_APPROVAL_ID  = sra.id
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA  as t1
join dbo.SERVICE_RECORDS_APPROVAL                      as sra on sra.svcRecID = t1.SVC_REC_ID
join dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR      as dss on dss.SUPERVISED_GROUP_ID = sra.groupID
where ((t1.CLIENT_ID = @clientID) and (sra.active = 1) and (dss.holdServiceRecordsUntilApproved = 1))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Get journals that are waiting for complete sra', 0, 1) WITH NOWAIT 

declare @journalsWaitingForCompleteSRA as table (
  JOURNAL_ID bigint
)

insert into @journalsWaitingForCompleteSRA
select distinct t1.JOURNAL_ID
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA  as t1
join dbo.SERVICE_RECORDS_APPROVAL            as sra on sra.id = t1.SVC_REC_APPROVAL_ID
where (
     (t1.CLIENT_ID = @clientID)
  and
     (((sra.reviewed = 0) and (sra.approved is null)) 
  or ((sra.reviewed = 1) and (sra.approved = 0)))
)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Searching for matching services for transportation', 0, 1) WITH NOWAIT 

update t1
  set t1.TRANS_MATCH_SVC_REC_ID = t2.NON_TRANS_SVC_REC_ID
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA                   as t1
join dbo.CLAIM_HOLD_CURRENT_TRANS_SVC_NON_TRANS_SVC_MATCHES as t2 on t2.SVC_REC_ID = t1.SVC_REC_ID
where ((t1.CLIENT_ID = @clientID) and (t1.SVC_TYPE_ID = dbo.CONST_SERVICES_TRANSPORT()))

/*--------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Searching for client approved transportation records', 0, 1) WITH NOWAIT 

update t1
  set t1.TRANS_MATCH_SVC_REC_ID = tmsrr.SVC_REC_ID
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as t1
join dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEWED as tmsrr on tmsrr.CLIENT_ID = t1.CLIENT_ID
                                                               and tmsrr.PATIENT_ID = t1.PAT_ID
                                                               and tmsrr.SVC_REC_ID = t1.SVC_REC_ID
where ((t1.CLIENT_ID = @clientID) and (t1.SVC_TYPE_ID = dbo.CONST_SERVICES_TRANSPORT()) and (t1.TRANS_MATCH_SVC_REC_ID is null))

/*--------------------------------------------------------------------------------------------------------------------*/
 
RAISERROR ('Getting common claim hold data for RMTS and Supervision' , 0, 1) WITH NOWAIT 

declare @commonClaimHoldData as table (
   ClaimID bigint
 , HoldData varchar(max)
unique clustered (ClaimID)
)
  
insert into @commonClaimHoldData
select 
   pws.CLAIM_ID
 , HoldData = dbo.HOLD_CLAIM_GET_COMMON_CLAIM_DATA(pws.CLAIM_ID)
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as pws 
where (pws.CLIENT_ID = @clientID)
 
/*--------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Getting all possible RMTS participants' , 0, 1) WITH NOWAIT 
  
declare @rmtsParticipantsPossibleCsvStr as varchar(max)
 
select 
   @rmtsParticipantsPossibleCsvStr = STRING_AGG (convert(varchar(max), ppvc.id),',')  
from dbo.RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE(@clientID) as ppvc

/*--------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Update RMTS participation compliance state', 0, 1) WITH NOWAIT 
 
update chc
set
    chc.rmtsCompliant = 0
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as chc
join @commonClaimHoldData                             as cchd on cchd.ClaimID = chc.CLAIM_ID
cross apply (
   select top 1 
	  rmts1.REASON   
   from dbo.RMTS_HOLD_CLAIM(@clientID,@rmtsStartsOn,@rmtsParticipantsPossibleCsvStr,cchd.HoldData) as rmts1 
   where (rmts1.HOLD = 1)
) as rmts2
where (chc.CLIENT_ID = @clientID)

/*--------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Update supervision compliance state', 0, 1) WITH NOWAIT 

update chc
set    
   chc.supervisionCompliant = 0
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as chc
join @commonClaimHoldData                             as cchd on cchd.ClaimID = chc.CLAIM_ID
cross apply (
  select top 1      
    dsup1.REASON 
 from dbo.PRAC_DIRECT_SUPERVISION_HOLD_CLAIM (@dSupStartsOn,cchd.HoldData) as dsup1 
 where (dsup1.HOLD = 1)
) as dsup2
where (chc.CLIENT_ID = @clientID)

/*--------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Update CPR certification required state', 0, 1) WITH NOWAIT 

update chc
set    
   chc.cprCertCompliant = 0
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as chc
join @commonClaimHoldData                             as cchd on cchd.ClaimID = chc.CLAIM_ID
cross apply (
  select top 1      
    dsup1.REASON 
 from dbo.PRAC_CPR_CERT_REQUIRED_HOLD_CLAIM (cchd.HoldData) as dsup1 
 where (dsup1.HOLD = 1)
) as dsup2
where (chc.CLIENT_ID = @clientID)

/*--------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Update ACES certification required state', 0, 1) WITH NOWAIT 

update chc
set    
   chc.acesCertCompliant = 0
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as chc
join @commonClaimHoldData                             as cchd on cchd.ClaimID = chc.CLAIM_ID
cross apply (
  select top 1      
    dsup1.REASON 
 from dbo.PRAC_ACES_CERT_REQUIRED_HOLD_CLAIM (cchd.HoldData) as dsup1 
 where (dsup1.HOLD = 1)
) as dsup2
where (chc.CLIENT_ID = @clientID)

/*#####################################################################################################################*/

/*============================================================
 * Determine hold reasons and initial recommended action codes
 *============================================================*/  

RAISERROR ('Determining hold reasons and initial recommended action codes', 0, 1) WITH NOWAIT 

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Client has not authorized processing of retroactive claim', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 50, RECOMMENDED_ACTION_CODE = 50 /* Authorize the claim processing */
where (
      (CLIENT_ID = @clientID) 
  and (HELD = 0) 
  and (claimSource = 2) 
  and (isnull(clientAuthorizedNonCurrent,0) = 0) /* Defered or not decided*/
)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('No BIC or invalid BIC', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 100, RECOMMENDED_ACTION_CODE = 0 /* Nothing initial */
where ((CLIENT_ID = @clientID) and (HELD = 0) and (len(PAT_BIC) != 14))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Patient is not LEA BOP eligible', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 150, RECOMMENDED_ACTION_CODE = 0 /* Nothing initial */
where ((CLIENT_ID = @clientID) and (HELD = 0) and (isLeaBopEligible = 0))


/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Zero unit claims', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
  set HELD = 1, HOLD_CODE = 200, RECOMMENDED_ACTION_CODE = 0 /* Nothing initial */
where ((CLIENT_ID = @clientID) and (HELD = 0) and (SVC_UNITS = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Procedure not billable', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
  set HELD = 1, HOLD_CODE = 300, RECOMMENDED_ACTION_CODE = 0 /* Nothing initial */
where ((CLIENT_ID = @clientID) and (HELD = 0) and ((PROCEDURE_PUT_IN_837 = 0) or (PROCEDURE_IS_Q = 1)))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Practitioner set to not claim', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 400,  RECOMMENDED_ACTION_CODE = 400 
where ((CLIENT_ID = @clientID) and (HELD = 0) and (PRAC_SUBMIT_CLAIMS = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Practitioner set to not claim TCM', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 500, RECOMMENDED_ACTION_CODE = 500 
where ((CLIENT_ID = @clientID) and (HELD = 0) and (SVC_TYPE_ID = dbo.CONST_SERVICES_TCM()) and (PRAC_CLAIM_TCM = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Client set to not claim TCM', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 600,  RECOMMENDED_ACTION_CODE = 600 
where ((CLIENT_ID = @clientID) and (HELD = 0) and (SVC_TYPE_ID = dbo.CONST_SERVICES_TCM()) and (CLIENT_CLAIM_TCM = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Client set to not claim procedure', 0, 1) WITH NOWAIT 

update t1 
  set t1.HELD = 1, t1.HOLD_CODE = 700, RECOMMENDED_ACTION_CODE = 700       
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA    as t1
join dbo.TRANSMISSION_HOLDS_CLIENT_PROCEDURE as t2 on t2.CLIENT_ID = t1.CLIENT_ID and t2.PROCEDURE_ID = t1.PROCEDURE_ID
join dbo.CLAIM_Procedures                    as cp on cp.PROCEDURE_ID = t2.PROCEDURE_ID
where ((t1.CLIENT_ID = @clientID) and (t1.HELD = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Client set to not claim non iep', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 800, RECOMMENDED_ACTION_CODE = 800 
where ((CLIENT_ID = @clientID) and (HELD = 0) and (SVC_IS_IEP = 0) and (CLIENT_CLAIM_NO_PLAN = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Patient set to not claim', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 900, RECOMMENDED_ACTION_CODE = 900
where ((CLIENT_ID = @clientID) and (HELD = 0) and (PAT_SUBMIT_CLAIMS = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('RMTS participation required', 0, 1) WITH NOWAIT 
 
update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 910, RECOMMENDED_ACTION_CODE = 910
where ((CLIENT_ID = @clientID) and (HELD = 0) and (rmtsCompliant = 0))

/*---------------------------------------------------------------------------------------------------------------------*/
 
RAISERROR ('Supervision required', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 920, RECOMMENDED_ACTION_CODE = 920
where ((CLIENT_ID = @clientID) and (HELD = 0) and (supervisionCompliant = 0))

/*---------------------------------------------------------------------------------------------------------------------*/
 
RAISERROR ('CPR certification required', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 930, RECOMMENDED_ACTION_CODE = 930
where ((CLIENT_ID = @clientID) and (HELD = 0) and (cprCertCompliant = 0))

/*---------------------------------------------------------------------------------------------------------------------*/
 
RAISERROR ('ACES certification required', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 940, RECOMMENDED_ACTION_CODE = 940
where ((CLIENT_ID = @clientID) and (HELD = 0) and (acesCertCompliant = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Patient set to not claim iep service due to parents not giving consent', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 1000, RECOMMENDED_ACTION_CODE = 1000
where ((CLIENT_ID = @clientID) and (HELD = 0) and (SVC_IS_IEP = 1) and (PAT_MCAL_PARENT_CONSENT = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Transportation with no matching services', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
set HELD = 1, HOLD_CODE = 1100, RECOMMENDED_ACTION_CODE = 1100
where ((CLIENT_ID = @clientID) and (HELD = 0) and (SVC_TYPE_ID = dbo.CONST_SERVICES_TRANSPORT()) and (TRANS_MATCH_SVC_REC_ID is null))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Pre 7/1/2018 speech treatment ORP required but not in SpEdCare', 0, 1) WITH NOWAIT 

update t1
  set t1.HELD = 1, t1.HOLD_CODE = 1200, RECOMMENDED_ACTION_CODE = 1200
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as t1
where (
	  (t1.CLIENT_ID = @clientID)
  and (t1.HELD = 0) 
  and (t1.SVC_DOS < dbo.CONST_ORP_DOCUMENTATION_FOR_TREATMENT_REQUIRED_START_DATE())
  and (t1.SVC_TYPE_ID = dbo.CONST_SERVICES_TREATMENT())
  and (t1.PRAC_GROUP_FAMILY_ID = 9)
  and (not exists (select top 1 pbs.ID from dbo.CLIENT_PBS_DOCUMENTATION as pbs where (pbs.CLIENT_ID = t1.CLIENT_ID) and (pbs.ACTIVE = 1) and (t1.SVC_DOS between pbs.START_DATE and pbs.END_DATE)))
)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Health service with no order or prescription selected', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
  set HELD = 1, HOLD_CODE = 1300, RECOMMENDED_ACTION_CODE = 1300
where ((CLIENT_ID = @clientID) and (HELD = 0) and (SVC_ORP_REQ = 1) and (SVC_ORP_DOC_ID = 0) and (PRAC_GROUP_FAMILY_ID = 3))
	      
/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Could not automatch order or prescription', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
  set HELD = 1, HOLD_CODE = 1400, RECOMMENDED_ACTION_CODE = 1400
where ((CLIENT_ID = @clientID) and (HELD = 0) and (SVC_ORP_REQ = 1) and (SVC_ORP_DOC_ID = 0) and (PRAC_GROUP_FAMILY_ID != 3))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Order or prescription selected has no ORP professional association', 0, 1) WITH NOWAIT 

update t1
  set HELD = 1, HOLD_CODE = 1500, RECOMMENDED_ACTION_CODE = 1525, ADDITIONAL_INFORMATION = 'No authorization status history at all for any date of service'
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as t1
outer apply (
  select top 1 
    t2.* 
  from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_CORE (null, null, null, t1.CLIENT_ID, t1.SVC_ORP_DOC_ID, null, null, null) as t2
) as t3
where (
      (t1.CLIENT_ID = @clientID)
  and (t1.HELD = 0)
  and (t1.SVC_ORP_REQ = 1)
  and (t1.SVC_ORP_DOC_ID != 0)
  and (t1.SVC_ORP_PRAC_ID = 0)
  and (t3.id is null) /* No status confirm records at all for any dos */
)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Order or prescription selected is currently declined via eauth', 0, 1) WITH NOWAIT 

update t1
set HELD = 1
  , HOLD_CODE = 1510
  , RECOMMENDED_ACTION_CODE = 1510
  , ADDITIONAL_INFORMATION = '[Service Authorization Request ID ] : ' 
	                          + convert(varchar(255),sar.id) 
							  + ' [As Of] : ' 
							  + dbo.RPT_DATE_FMT(sar.lastModified)

from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as t1
join dbo.SERVICE_AUTHORIZATION_REQUESTS               as sar on ((sar.clientID = t1.CLIENT_ID)
                                                         and (sar.closed = 0)
										                 and (sar.active = 1)
										                 and (sar.currentResponseCode       = 4000)
										                 and (sar.svcAuthorizationRequestTypeID in (1,2))
                                                         and (sar.orpDocID                  = t1.SVC_ORP_DOC_ID)
										                 and (sar.reqSvcAuthFromSelectionID = 20))
where (
      (t1.CLIENT_ID = @clientID)
  and (t1.HELD = 0)
  and (t1.SVC_ORP_REQ = 1)
  and (t1.SVC_ORP_DOC_ID != 0)
  and (t1.SVC_ORP_PRAC_ID = 0)
)


/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Order or prescription selected is currently waiting for approval via eauth', 0, 1) WITH NOWAIT 

update t1
  set HELD = 1
     , HOLD_CODE = 1520
	 , RECOMMENDED_ACTION_CODE = 1520
	 , ADDITIONAL_INFORMATION = '[Service Authorization Request ID ] : ' 
	                          + convert(varchar(255),sar.id) 
							  + ' [As Of] : ' 
							  + dbo.RPT_DATE_FMT(sar.created)

from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as t1
join dbo.SERVICE_AUTHORIZATION_REQUESTS               as sar on ((sar.clientID = t1.CLIENT_ID)
                                                         and (sar.closed = 0)
										                 and (sar.active = 1)
										                 and (sar.currentResponseCode       = 2000)
										                 and (sar.svcAuthorizationRequestTypeID in (1,2))
                                                         and (sar.orpDocID                  = t1.SVC_ORP_DOC_ID)
										                 and (sar.reqSvcAuthFromSelectionID = 20))
where (
      (t1.CLIENT_ID = @clientID)
  and (t1.HELD = 0)
  and (t1.SVC_ORP_REQ = 1)
  and (t1.SVC_ORP_DOC_ID != 0)
  and (t1.SVC_ORP_PRAC_ID = 0)
)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Order or prescription selected currently had previous auth but it is currently expired', 0, 1) WITH NOWAIT 

update t1
    set HELD = 1
  , HOLD_CODE = 1530
  , RECOMMENDED_ACTION_CODE = 1530
  , ADDITIONAL_INFORMATION = t3.lastApprovalExpirationMessage
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as t1
cross apply (
  select top 1 
    t2.lastApprovalExpirationMessage 
  from dbo.ORP_DOCUMENTS_DATA_CORE(t1.CLIENT_ID,null,null,null,null,t1.SVC_ORP_DOC_ID,null) as t2
  where 
    (t2.lastApprovalExpirationState = 3)
) as t3

where (
      (t1.CLIENT_ID = @clientID)
  and (t1.HELD = 0)
  and (t1.SVC_ORP_REQ = 1)
  and (t1.SVC_ORP_DOC_ID != 0)
  and (t1.SVC_ORP_PRAC_ID = 0)
)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Order or prescription selected has no current approval for dos', 0, 1) WITH NOWAIT 

update t1
  set HELD = 1, HOLD_CODE = 1540, RECOMMENDED_ACTION_CODE = 1540
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as t1
where (
      (t1.CLIENT_ID = @clientID)
  and (t1.HELD = 0)
  and (t1.SVC_ORP_REQ = 1)
  and (t1.SVC_ORP_DOC_ID != 0)
  and (t1.SVC_ORP_PRAC_ID = 0)
)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Order or prescription selected has ORP professional but ORP professional has no NPI', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
  set HELD = 1, HOLD_CODE = 1600, RECOMMENDED_ACTION_CODE = 1600
where ((CLIENT_ID = @clientID) and (HELD = 0) and (SVC_ORP_REQ = 1) and (SVC_ORP_DOC_ID != 0) and (SVC_ORP_PRAC_ID != 0) and (len(SVC_ORP_PRAC_NPI) = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Order or prescription selected has ORP professional but ORP professional NPI is not mcal approved', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
  set HELD = 1, HOLD_CODE = 1700, RECOMMENDED_ACTION_CODE = 1700 
where ((CLIENT_ID = @clientID) and (HELD = 0) and (SVC_ORP_REQ = 1) and (SVC_ORP_DOC_ID != 0) and (SVC_ORP_PRAC_ID != 0) and (len(SVC_ORP_PRAC_NPI) != 0) and (SVC_ORP_PRAC_VALID = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Services waiting for reopened journal to be closed', 0, 1) WITH NOWAIT 

update t1 
  set HELD = 1, HOLD_CODE = 1800, RECOMMENDED_ACTION_CODE = 1800
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA  as t1
join dbo.SvcJournals                       as sj on sj.id = t1.JOURNAL_ID
where ((t1.CLIENT_ID = @clientID) and (t1.HELD = 0) and (sj.completed = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Services waiting for approval by supervising practitioner', 0, 1) WITH NOWAIT 

update t1 
  set HELD = 1, HOLD_CODE = 1900, RECOMMENDED_ACTION_CODE = 1900
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA  as t1
join dbo.SERVICE_RECORDS_APPROVAL as sra on sra.id = t1.SVC_REC_APPROVAL_ID 
where ((t1.CLIENT_ID = @clientID) and (t1.HELD = 0) and (sra.reviewed = 0) and (sra.active = 1))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Services held by supervising practitioner and waiting for correction by rendering practitioner', 0, 1) WITH NOWAIT 

update t1 
  set HELD = 1, HOLD_CODE = 2000, RECOMMENDED_ACTION_CODE = 2000
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA  as t1
join dbo.SERVICE_RECORDS_APPROVAL as sra on sra.id = t1.SVC_REC_APPROVAL_ID 
where ((t1.CLIENT_ID = @clientID) and (t1.HELD = 0) and (sra.reviewed = 1) and (sra.approved = 0) and (sra.active = 1))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Services otherwise not held for previous hold reasons but tied to journal that has services held so it cannot go yet', 0, 1) WITH NOWAIT 

update t1 
  set HELD = 1, HOLD_CODE = 2100, RECOMMENDED_ACTION_CODE = 2100
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA  as t1
join @journalsWaitingForCompleteSRA as t2 on t2.JOURNAL_ID = t1.JOURNAL_ID
where ((t1.CLIENT_ID = @clientID)
  and (t1.HELD = 0))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Service entered by pcal but batch is not complete', 0, 1) WITH NOWAIT 

update t1 
  set t1.HELD = 1, t1.HOLD_CODE = 2200, RECOMMENDED_ACTION_CODE = 10000
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA                             as t1
join dbo.INPUT_BATCHES_SERVICE_RECORDS as ibsr on ibsr.svcRecID = t1.SVC_REC_ID
join dbo.INPUT_BATCHES                 as ib   on ib.id          = ibsr.inputBatchID
where ((CLIENT_ID = @clientID) and (t1.HELD = 0) and (t1.SVC_ENTERED_BY_PCAL = 1) and (ib.Current_status_Code != 200))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Service entered by pcal but not yet transmitted', 0, 1) WITH NOWAIT 

update t1 
  set t1.HELD = 1, t1.HOLD_CODE = 10000, RECOMMENDED_ACTION_CODE = 10000
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA                             as t1
join dbo.INPUT_BATCHES_SERVICE_RECORDS as ibsr on ibsr.svcRecID = t1.SVC_REC_ID
join dbo.INPUT_BATCHES                 as ib   on ib.id          = ibsr.inputBatchID
where ((CLIENT_ID = @clientID) and (t1.HELD = 0) and (t1.SVC_ENTERED_BY_PCAL = 1) and (ib.Current_status_Code = 200) and (ib.Current_Status_Date >= t1.CLIENT_LAST_TX_DATE_TIME))


/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Service entered by client but held for x days', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
  set HELD = 1, HOLD_CODE = 10100, RECOMMENDED_ACTION_CODE = 10000
where (
    (CLIENT_ID = @clientID)
and (HELD = 0) 
and (SVC_ENTERED_BY_PCAL = 0) 
and (SVC_ENTERED_DAYS_AGO <= CLIENT_HOLD_WORK_FOR_DAYS)
)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Service entered by client but held for x days on day of last tx', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
  set HELD = 1, HOLD_CODE = 10200, RECOMMENDED_ACTION_CODE = 10000
where (
    (CLIENT_ID = @clientID)
and (HELD = 0) 
and (SVC_ENTERED_BY_PCAL = 0) 
and (SVC_CREATED_MODIFIED >= CLIENT_LAST_TX_DATE_TIME)
)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('More specific holds or additional holds in tranmission routine that are not covered by prescan', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
  set HELD = 1, HOLD_CODE = 9999, RECOMMENDED_ACTION_CODE = 9999
where ((CLIENT_ID = @clientID) and (HELD = 0) and (LAST_TX_HOLD_REASON is not null))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Whatever is left', 0, 1) WITH NOWAIT 

update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA 
  set HELD = 1, HOLD_CODE = 0, RECOMMENDED_ACTION_CODE = 10000
where ((CLIENT_ID = @clientID) and (HELD = 0) and (LAST_TX_HOLD_REASON is null))

/*#####################################################################################################################*/

/*============================================================
 * Determine detailed recommendations and additional info
 *============================================================*/  

RAISERROR ('Determining more specific recommended action codes and additional information', 0, 1) WITH NOWAIT 

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Speech services missing covering PBS', 0, 1) WITH NOWAIT 

update cch 
set
  RECOMMENDED_ACTION_CODE = 1425
, ADDITIONAL_INFORMATION =  ''
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as cch
where ((cch.CLIENT_ID = @clientID) and (cch.HOLD_CODE in (1200,1400) and (cch.PRAC_GROUP_FAMILY_ID = 9)))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Non health and non speech services that cannot automatch because of overlapping active', 0, 1) WITH NOWAIT

update cch 
set
  RECOMMENDED_ACTION_CODE = 1435
, ADDITIONAL_INFORMATION =  'Overlapping orders, prescriptions, and special authorization documents that apply to this practitioner & patient : ' + char(13) + char(10) + trim(isnull(orpDocs.orpDocumentSelections,''))
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as cch
cross apply (
    select orpDocumentSelections = 
	  stuff((select char(13) + char(10) + ods.orpDocumentSelection
	from
	(
	  select
	    orpDocumentSelection = 
	    + '* ' 
		+ od.name
		+ ' [Effective] : ' 
	    + dbo.RPT_DATE_FMT(od.startDate)
	    + ' - '
	    + dbo.RPT_DATE_FMT(od.endDate)
	    + ' [Ordered By] : '
		+ isnull(od.orpPracName,'')
		+ ' [NPI] : '
		+ isnull(od.orpPracNpiNumber,'')
		+ ' [ORP Document Record ID] : ' 
		+ convert(varchar(50),od.id)			    
    
	  from dbo.ORP_DOCUMENTS_VIEW_CORE (  null
	                                    , null
										, null
	                                    , cch.CLIENT_ID
                                        , cch.PRAC_GROUP_FAMILY_ID
                                        , cch.PAT_ID
			     	  				    , cch.SVC_DOS
                                        , null
										, null
										, 1
										, null
										 ) as od
      ) as ods	
      FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')
) as orpDocs
where ((cch.CLIENT_ID = @clientID) and (cch.HOLD_CODE = 1400) and (cch.PRAC_GROUP_FAMILY_ID not in (3,9)) and (orpDocs.orpDocumentSelections is not null))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Non health and non speech services that cannot automatch', 0, 1) WITH NOWAIT

update cch 
set
  RECOMMENDED_ACTION_CODE = 1450
, ADDITIONAL_INFORMATION =  'Orders, prescriptions, and special authorization documents that apply to this practitioner & patient : ' + char(13) + char(10) + trim(isnull(orpDocs.orpDocumentSelections,''))
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as cch

outer apply (
    select orpDocumentSelections = 
	  stuff((select char(13) + char(10) + ods.orpDocumentSelection
	from
	(
	  select
	    orpDocumentSelection = 
	    + '* ' 
		+ od.name
		+ ' [Effective] : ' 
	    + dbo.RPT_DATE_FMT(od.startDate)
	    + ' - '
	    + dbo.RPT_DATE_FMT(od.endDate)
	    + ' [Ordered By] : '
		+ isnull(od.orpPracName,'')
		+ ' [NPI] : '
		+ isnull(od.orpPracNpiNumber,'')
		+ ' [Active] : ' 
	    + dbo.BIT_TO_YN(od.active)
    
	  from dbo.ORP_DOCUMENTS_VIEW_CORE (  null
	                                    , null
										, null
	                                    , cch.CLIENT_ID
                                        , cch.PRAC_GROUP_FAMILY_ID
                                        , cch.PAT_ID
			     	  				    , null
                                        , null
										, null
										, null
										, null
										 ) as od
      ) as ods	
      FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')
) as orpDocs
where ((cch.CLIENT_ID = @clientID) and (cch.HOLD_CODE = 1400) and (cch.RECOMMENDED_ACTION_CODE != 1435) and (cch.PRAC_GROUP_FAMILY_ID not in (3,9)))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Journal entries missing ORP docuuments', 0, 1) WITH NOWAIT 
 
update cch
  
  set ADDITIONAL_INFORMATION = 'The following journal entries need an order or prescription selected : '
                            + char(13) + char(10)  
                            + jes.jEntries
    , RECOMMENDED_ACTION_CODE = 1350
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as cch

cross apply
(
  select jEntries = 
	  stuff((select char(13) + char(10) + je.jEntry	
  from
  (
    select top (dbo.CONST_MAX_ROWS())
      jEntry = 
  	    '* '
	  + dbo.RPT_TIME_FMT(sjee.entryStartTime,0)
      + ' - ' 
	  + dbo.RPT_TIME_FMT(sjee.entryEndTime,0)
	  + ' :: ' 
      + prp.CONCAT_NAME
      + ' ('
	  + gg.GROUP_NAME
	  + ') '
      + ' :: ' 
      + sjet.eventLabel  

    from dbo.SvcJournals                 as sj
    join dbo.SvcJournal_Event_Entries    as sjee on sjee.journalID      = sj.id
    join dbo.SvcJournal_Event_Types      as sjet on sjet.id             = sjee.eventType
    join dbo.PRACTITIONER_Practitioner   as prp  on prp.PRACTITIONER_ID = sjee.pracID
    join dbo.PRACTITIONER_GROUPS         as pg   on pg.PRACTITIONER_ID  = prp.PRACTITIONER_ID
    join dbo.GROUP_Group                 as gg   on gg.GROUP_ID         = pg.GROUP_ID

    where (
          (sj.id       = cch.JOURNAL_ID)
      and (sjee.active = 1)
	  and (sjee.pracID = cch.PRAC_ID)
	  and (sjet.reqORP = 1)
      and (gg.GROUP_TYPE in (1,2))
      and (isnull(sjee.orpDocID,0) = 0)  
    )
	order by sjee.entryStartTime
  ) as je
  FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')
) as jes

where (
      (cch.CLIENT_ID = @clientID)
  and (cch.HOLD_CODE = 1300) 
  and (cch.SVC_ENTRY_TYPE_ID = 10)
  and (cch.JOURNAL_ID is not null) 

)

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Mising ORP professional', 0, 1) WITH NOWAIT 

--update cch 
--set
--  RECOMMENDED_ACTION_CODE = 1525
--, ADDITIONAL_INFORMATION =  trim(isnull(orpDoc.orpDocumentSelection,''))
--from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as cch

--cross apply (
--	  select top 1 
--	    orpDocumentSelection = 
--	    + '* ' 
--		+ od.name
--	    + ' [Ordered By] : '
--		+ isnull(od.orpPracName,'')
--		+ ' [NPI] : '
--		+ isnull(od.orpPracNpiNumber,'')
--		+ ' [Active] : ' 
--	    + dbo.BIT_TO_YN(od.active)
    
--	  from dbo.ORP_DOCUMENTS_VIEW_CORE (  null
--	                                    , null
--										, null
--	                                    , cch.CLIENT_ID
--                                        , null
--                                        , cch.PAT_ID
--			     	  				    , null
--                                        , null
--										, null
--										, null
--										, cch.SVC_ORP_DOC_ID
--										 ) as od

--) as orpDoc

--where ((cch.CLIENT_ID = @clientID)  and (cch.HOLD_CODE = 1500))
 

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Mising NPI', 0, 1) WITH NOWAIT 

update cch 
set
  RECOMMENDED_ACTION_CODE = 1625
, ADDITIONAL_INFORMATION = ' Client Name : ' 
+ cch.CLIENT_NAME +
+ ' Practitioner Last Name : ' 
+ orp.LAST_NAME 
+ ' Practitioner First Name : ' 
+ orp.FIRST_NAME 
+ ' Practitioner ID :' 
+ convert(nvarchar(50),orp.PRACTITIONER_ID)

from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as cch
join dbo.PRACTITIONER_Practitioner        as orp on orp.PRACTITIONER_ID = cch.SVC_ORP_PRAC_ID

where ((cch.CLIENT_ID = @clientID)
  and (cch.HOLD_CODE = 1600))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Mising NPI Validation', 0, 1) WITH NOWAIT 

update cch 
set
  RECOMMENDED_ACTION_CODE = 1725
, ADDITIONAL_INFORMATION = ' Client Name : ' 
+ cch.CLIENT_NAME +
+ ' Practitioner Last Name : ' 
+ orp.LAST_NAME 
+ ' Practitioner First Name : ' 
+ orp.FIRST_NAME 
+ ' NPI : '
+ isnull(orp.npiNumber,'')
+ ' Practitioner ID :' 
+ convert(nvarchar(50),orp.PRACTITIONER_ID)

from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as cch
join dbo.PRACTITIONER_Practitioner        as orp on orp.PRACTITIONER_ID = cch.SVC_ORP_PRAC_ID

where ((cch.CLIENT_ID = @clientID)
  and (cch.HOLD_CODE = 1700))

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Reason was not accounted for in this scan but we have a last transmission reason', 0, 1) WITH NOWAIT 

update cch 
set
  ADDITIONAL_INFORMATION = LAST_TX_HOLD_REASON
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as cch
where ((cch.CLIENT_ID = @clientID)
  and (cch.RECOMMENDED_ACTION_CODE = 9999))

/*#####################################################################################################################*/
 
/*============================================================
 * Reorg index to help out next caller
 *============================================================*/  

RAISERROR ('Reorganizing index for detail data', 0, 1) WITH NOWAIT 
ALTER INDEX [CLIENT_ID_IDX] ON [dbo].[CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA] REORGANIZE  WITH ( LOB_COMPACTION = ON )

/*#####################################################################################################################*/

/*============================================================
 * Cleanup old actionable report data
 *============================================================*/  

RAISERROR ('Removing old actional report data', 0, 1) WITH NOWAIT 

RAISERROR ('Truncating table', 0, 1) WITH NOWAIT 

delete from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA
where CLIENT_ID = @clientID

/*#####################################################################################################################*/

/*============================================================
 * Generate new actionable report data
 *============================================================*/  

RAISERROR ('Generating new actional report data', 0, 1) WITH NOWAIT 

insert into dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA
select 
    cch.REP_ID
  , cch.REP_NAME
  , cch.REP_EMAIL
  , cch.CLIENT_ID
  , cch.CLIENT_NAME
  , cch.SVC_DOS_MONTH_YEAR
  , cch.SVC_DOS_USE_OR_LOSE
  , cch.PAT_ID
  , cch.PAT_NAME
  , cch.PAT_BIC
  , cch.PAT_CSIS
  , cch.PAT_DOB
  , cch.PRAC_GROUP_FAMILY_ID
  , cch.PRAC_GROUP_FAMILY_NAME
  , cch.PRAC_ID
  , cch.PRAC_NAME
  , cch.PRAC_GROUP_ID
  , cch.PRAC_GROUP_NAME
  , cch.SVC_TYPE_ID
  , cch.SVC_TYPE_NAME
  , cch.HOLD_CODE
  , cch.RECOMMENDED_ACTION_CODE
  , cch.ADDITIONAL_INFORMATION
  , cch.LAST_UPDATED
  , NUM_CLAIMS    = count (cch.CLAIM_ID)
  , TOT_EST_AMT   = SUM(cch.EST_AMT) 
  , SVC_DOS_START = Min(cch.SVC_DOS)
  , SVC_DOS_END   = Max(cch.SVC_DOS)
  , REFERENCED_ENTITY_ID = CASE 
								-- order id
								WHEN cch.HOLD_CODE in (select holdCode from dbo.PLR_CLASSIFICATION_CLAIM_HOLD_CODES where code = 100) THEN 
									min(cch.SVC_ORP_DOC_ID)

								-- orp practitioner id
								WHEN cch.HOLD_CODE in (select holdCode from dbo.PLR_CLASSIFICATION_CLAIM_HOLD_CODES where code = 200) THEN 
									min(cch.SVC_ORP_PRAC_ID)	

								-- rmts quarter id
								WHEN cch.HOLD_CODE in (select holdCode from dbo.PLR_CLASSIFICATION_CLAIM_HOLD_CODES where code = 400) THEN 
									(select top 1 id from dbo.[RMTS_PARTICIPATION_ROSTER_VIEW] (
											null         
										  , null      
										  , null      
										  , @clientID      
										  , 1        
										  , null   
									  ) where min(cch.SVC_DOS) between startDate and endDate
									)
							
								ELSE null
						   END
  , PLR_ID_STRING = dbo.BUILD_PLR_ID_STRING(
						   cch.CLIENT_ID         
						 , cch.PAT_ID            
						 , cch.PRAC_ID           
						 , cch.PRAC_GROUP_ID      
						 , cch.PRAC_GROUP_FAMILY_ID
						 , cch.SVC_TYPE_ID        
						 , cch.HOLD_CODE         
						 , Min(cch.SVC_DOS)     
						 , Max(cch.SVC_DOS)
					)

from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA   as cch

where (cch.RECOMMENDED_ACTION_CODE not in (0,10000))
  and (CLIENT_ID = @clientID)

group by
    cch.REP_ID
  , cch.REP_NAME
  , cch.REP_EMAIL
  , cch.CLIENT_ID
  , cch.CLIENT_NAME
  , cch.SVC_DOS_MONTH_YEAR
  , cch.SVC_DOS_USE_OR_LOSE
  , cch.PAT_ID
  , cch.PAT_NAME
  , cch.PAT_BIC
  , PAT_CSIS
  , cch.PAT_DOB
  , cch.PRAC_GROUP_FAMILY_ID
  , cch.PRAC_GROUP_FAMILY_NAME
  , cch.PRAC_ID
  , cch.PRAC_NAME
  , cch.PRAC_GROUP_ID
  , cch.PRAC_GROUP_NAME
  , cch.SVC_TYPE_ID
  , cch.SVC_TYPE_NAME
  , cch.HOLD_CODE
  , cch.RECOMMENDED_ACTION_CODE
  , cch.ADDITIONAL_INFORMATION
  , cch.LAST_UPDATED


/*#####################################################################################################################*/

/*============================================================
 * Done
 *============================================================*/  

RAISERROR ('Done', 0, 1) WITH NOWAIT 

RETURN(0)    
END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
         
  -- Error or raise error with severity 11 to 19 will be caught here          
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_FOR_CLIENT] TO [webuser]
GO

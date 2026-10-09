use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_DENIED_CLAIMS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_DENIED_CLAIMS_VIEW_CORE
GO

/*---------------------------------------------------------------------------------------------------------*/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CYBHI_DENIED_CLAIMS_VIEW_CORE (
    @clientID        bigint
  , @canAutoResubmit bit
)

RETURNS 
TABLE
AS
RETURN
(

with 
cte_p1
as
(
  select top 1
      q1.todayDateOnly
    , oldestDosNormallyAllowed = dateadd(day,1,(EOMONTH(dateadd(month,-13,q1.todayDateOnly))))
  from (select top 1 todayDateOnly = convert(date,getdate())) as q1
)
,
cte_p2
as
(
  select 
    clms.* 
  from cte_p1 as p1

  cross apply (

    select 
        cc.clientID
	  , src.svcRecID	  
      , src.claimID 
	  , cc.dos  
	  , cc.patID
	  , cc.renderingPracID
	  , cc.orpPracID
	  , cc.claimingPracID
	  , cc.procedureID
	  , cc.claimLineNum
	  , procModCombo   = dbo.RPT_PROC_MOD_COMBO(cp.PROCEDURE_CODE, cp.PROCEDURE_MODIFIER_1, cp.PROCEDURE_MODIFIER_2, cp.PROCEDURE_MODIFIER_3, cp.PROCEDURE_MODIFIER_4)
	  , diagCode       = cp.ICD_10_DIAGNOSIS_CODE
	  , cybhiSvcNameID = cp.CYBHI_NAME
	  , cc.numOfSubmissions	  
      , oldestDosAllowed = iif((clc.cybhiTpaApprovedOn >= p1.oldestDosNormallyAllowed), clc.cybhiTpaApprovedOn, p1.oldestDosNormallyAllowed)

    from dbo.CYBHI_CLAIMS                as cc
    join dbo.CYBHI_SERVICE_RECORD_CLAIMS as src on src.claimID     = cc.id
    join dbo.CLIENTS_Client              as clc on clc.CLIENT_ID   = cc.clientID
    join dbo.CLAIM_Procedures            as cp  on cp.PROCEDURE_ID = cc.procedureID
    join dbo.SERVICE_RECORDS             as sr  on sr.id           = src.svcRecID	

	where ( 
          (1=1)
	  and ((@clientID is null) or (cc.clientID = @clientID))
	  and (cc.txStatusCode = 4)            
	  and (cc.active       = 1)
	  and (sr.[state] not in (99,199))
    )
  ) as clms
)
,
cte_p3
as
(
  select 
      p2.* 
    , claimIsAgedOut = iif((p2.dos >= p2.oldestDosAllowed),0,1)
	, cra1.checkDate
	, cra1.postingID
	, cra1.postingDate
	, postedDaysAfterRemitAdvice = datediff(day,cra1.checkDate, cra1.postingDate)

  from cte_p2 as p2

  /* Get most recent posting related to this claimID */

  cross apply (

    select top 1	  
	
	    ccp1.checkDate      	  
	  , postingID   = ccp1.id	 
	  , postingDate = convert(date,ccp1.created)
    
	from dbo.CYBHI_CLAIM_POSTING_CLAIM_RECORD_ADJUDICATION  as cra1 
    join dbo.CYBHI_CLAIM_POSTINGS                           as ccp1 on ccp1.id = cra1.postingID
    where (
          ((cra1.claimID = p2.claimID))	
	  and (cra1.active = 1) and (ccp1.active = 1)
    )
    order by 
      ccp1.checkDate desc
  
  ) as cra1
)
,
cte_p4
as
(
  select 
      p3.*
    , sra2.* 
  from cte_p3 as p3
  
  /* Get svc rec adjudication related to this postingID and svcRec */

  cross apply (

    select top 1 
         sra1.ccn	  
	   , sra1.referenceID
    from dbo.CYBHI_CLAIM_POSTING_SERVICE_RECORD_ADJUDICATION as sra1
    where (
          ((sra1.svcRecID  = p3.svcRecID))
      and ((sra1.postingID = p3.postingID) and (sra1.active = 1))
    )
  
  ) as sra2
)
,
cte_p5
as
(
  select 
      p4.* 
    , reasonCode = isnull(carc2.reasonCode,'')
	, reasonText = isnull(carc2.reasonText,'')
	, remarkCode = isnull(rarc2.remarkCode,'')
	, remarkText = isnull(rarc2.remarkText,'')
  from cte_p4 as p4
  
  outer apply (

    select 
        reasonCode   = trim(carc1.adjustmentGroupCode) + ':' + trim(carc1.adjustmentReasonCode) 
      , reasonText = cdc.DETAIL_TEXT

	from dbo.CYBHI_CLAIM_POSTING_CLAIM_RECORD_ADJUDICATION_ADJUSTMENTS as carc1  
	join dbo.CLAIM_DETAIL_CODES                                        as cdc on ((cdc.CODE_VALUE = carc1.adjustmentReasonCode) and (cdc.IS_ARC_CARC = 1))

    where (
	      ((carc1.claimID  = p4.claimID)) 
      and (carc1.postingID = p4.postingID) 
	  and (carc1.active = 1)
	)

  ) as carc2

  outer apply (

    select 
	    remarkCode = trim(rarc1.codeListQualifierCode) + ':' + trim(rarc1.industryCode) 
	  , remarkText = cdc.DETAIL_TEXT
	from dbo.CYBHI_CLAIM_POSTING_CLAIM_RECORD_HEALTH_CARE_REMARK_CODES as rarc1
	join dbo.CLAIM_DETAIL_CODES                                        as cdc on ((cdc.CODE_VALUE = rarc1.industryCode) and (cdc.IS_HCRC_RARC = 1))
  
    where (
	      ((rarc1.claimID  = p4.claimID)) 
      and (rarc1.postingID = p4.postingID) 
	  and (rarc1.active    = 1)
	)
  
  ) as rarc2
)
,
cte_p6
as
(
  select
      p5.*
  
    , reasonCodeIndicatesNoAutoResubmission = convert(bit,(iif ((p5.reasonCode in (
  
        'CO:18'  /* Duplicate claim/service */
      , 'PR:29'  /* Timed out*/
      , 'PR:27'  /* Coverage terminated */
      , 'CO:45'  /* Fee schedule max reached*/
      , 'CO:140' /* Patient/Insured health identification number and name do not match */
      , 'CO:4'   /* The procedure code is inconsistent with the modifier used or a required modifier is missing. Note: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.*/
      , 'CO:B7'  /* This provider was not certified/eligible to be paid for this procedure/service on this date of service. Note: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.*/
      , 'CO:B15' /* This service/procedure requires that a qualifying service/procedure be received and covered. The qualifying other service/procedure has not been received/adjudicated. Note: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.*/
      , 'CO:16'  /* Claim/service lacks information which is needed for adjudication. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)*/
      , ''       /* No code (should never happen) */
  
      -- Add to list as needed

    )),1,0)))

    , remarkCodeIndicatesNoAutoResubmission = convert(bit,(iif ((p5.remarkCode in (
        'HE:MA113'  /* Incomplete/invalid taxpayer identification number (TIN) submitted by you per the Internal Revenue Service. Your claims cannot be processed without your correct TIN, and you may not bill the patient pending correction of your TIN. There are no appeal rights for unprocessable claims, but you may resubmit this claim after you have notified this office of your correct TIN. */
      , 'HE:N433'  /* Resubmit this claim using only your National Provider Identifier (NPI) */

      -- Add to list as needed

    )),1,0)))
  
    , ctc.transmissionID
    , claimTransmissionID = ctc.id
    , transmissionDate    = convert(date,ct.created)
  
  from cte_p5                              as p5
  join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as ctc on ctc.referenceID = p5.referenceID
  join dbo.CYBHI_CLAIM_TRANSMISSIONS       as ct  on ct.id           = ctc.transmissionID
  
  where (
        ((ctc.svcRecID = p5.svcRecID))
	and (ctc.active = 1)
	and (ct.active  = 1)
  )
)
,
cte_p7
as
(
  select 
      p6.* 
    , remitAdviceIssuedDaysAfterTransmission = datediff(day,p6.transmissionDate, p6.checkDate)
    , canAutoResubmit = convert(bit,(case 
        when (p6.claimIsAgedOut                        = 1) then 0
        when (p6.reasonCodeIndicatesNoAutoResubmission = 1) then 0
        when (p6.remarkCodeIndicatesNoAutoResubmission = 1) then 0
        else 1 
      end))
  from cte_p6 as p6
)
select  
  p7.*
from cte_p7 as p7
where ( 
      (1=1)
  and ((@canAutoResubmit is null) or (p7.canAutoResubmit = @canAutoResubmit))
)

)
GO

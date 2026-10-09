USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIMS_TRANSMITTED_AND_POSTED_CORE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CLAIMS_TRANSMITTED_AND_POSTED_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION  [dbo].[RPT_CLAIMS_TRANSMITTED_AND_POSTED_CORE] (
  @clientID         bigint 
)

RETURNS TABLE AS
RETURN
(

select top (dbo.CONST_MAX_ROWS())

      clm.CLAIM_ID
	, [IS_PROXY_CLAIM]      = clm.IS_PROXY
    , [PAT_ID]              = clm.PATIENT_ID
	, [PAT_INITIALS]        = dbo.RPT_NAME_TO_INITIALS(  pap.FIRST_NAME, pap.LAST_NAME)
	, [PRC_INITIALS]        = case when (clm.IS_PROXY = 1) 
                                then pproxy.PROXY_CHILD_PRACS 
						      else dbo.RPT_NAME_TO_INITIALS( prp.FIRST_NAME, prp.LAST_NAME)
						      end	
	, [SVC_DATE]            = clm.SERVICE_DATE    
	, [SVC_NAME]            = coalesce(sniep.NAME,snnoplan.NAME)
	, [SVC_CLASS_NAME]      = gg.GROUP_SERVICE_CLASS_NAME
	, [SVC_TYPE]            = st.SERVICE_TYPE_NAME
    , [SVC_SUB_TYPE]        = sst.SERVICE_TYPE_NAME	
	, [SVC_PROC_MOD_COMBO]  = dbo.RPT_PROC_MOD_COMBO (  cp.PROCEDURE_CODE
	                                                  , cp.PROCEDURE_MODIFIER_1
								    				  , cp.PROCEDURE_MODIFIER_2
									  			      , cp.PROCEDURE_MODIFIER_3
												      , cp.PROCEDURE_MODIFIER_4 )	
	, [SVC_UNITS]           = clm.SERVICE_UNITS
	
	, [DATE_SUBMITTED]      = txrx.Created_At
	, [AMOUNT_SUBMITTED]    = txrx.Amount_Transmitted
    , [TRANSMISSION_ID]     = txrx.transmission_id

	, [TRANSMISSION_RECORD_CLAIM_ID_TX] = txrx.TRC_ID_TRANSMISION
	, [TRANSMISSION_RECORD_CLAIM_ID_RX] = txrx.TRC_ID_POSTING
	, [POSTING_ID]                      = txrx.POSTING_ID
	, [POSTING_DATE]                    = txrx.POSTING_DATE
	, [ADJUDICATION_ID]                 = txrx.ADJUDICATION_ID
	, [REMIT_LN]                        = txrx.LN    
	, [REMIT_STATUS]                    = txrx.STATUS
    , [DATE_REMITTED]                   = txrx.DATE_ADJUDICATED
    , [CCN]                             = txrx.CCN
    , [AMOUNT_REMITTED]                 = txrx.AMOUNT_PAID
    , [FI_PERCENTAGE_CA]                = txrx.FI_PERCENT_CA 
    , [CHECK_DATE]                      = txrx.CHECK_DATE
	, [CHECK_NUMBER]                    = txrx.CHECK_NUMBER
	, [CHECK_AMOUNT]                    = txrx.CHECK_AMOUNT

from dbo.CLAIM_Claim                    as clm 
join dbo.CLAIM_Procedures               as cp  on cp.PROCEDURE_ID     = clm.PROCEDURE_ID
join dbo.CLAIM_Procedures_Service_Types as st  on st.SERVICE_TYPE_ID  = cp.SERVICE_TYPE_ID

join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as gg on gg.GROUP_ID = clm.GROUP_ID
                                                                and gg.GROUP_SERVICE_CLASS_PARTITION_ID = 100

join dbo.PATIENTS_PATIENT               as pap on pap.PATIENT_ID      = clm.PATIENT_ID
join dbo.PRACTITIONER_Practitioner      as prp on prp.PRACTITIONER_ID = clm.PRACTITIONER_ID

left join dbo.CLAIM_IEPandIFSPNames   as sniep    on sniep.IEP_IFSP_NAME_ID   = cp.IEP_IFSP_NAME
left join dbo.CLAIM_NoPlanNames       as snnoplan on snnoplan.NO_PLAN_NAME_ID = cp.NO_PLAN_NAME

outer apply (
  select * from dbo.CLAIM_Procedures_Service_Types as cpst
  where cpst.SERVICE_TYPE_ID = cp.SERVICE_SUB_TYPE_1_ID
) as sst

outer apply (
  select 
    PROXY_CHILD_PRACS = TRIM (STRING_AGG ( dbo.RPT_NAME_TO_INITIALS ( pp.FIRST_NAME, pp.LAST_NAME),' '))
  from dbo.CLAIM_Claim               as cc 
  join dbo.PRACTITIONER_Practitioner as pp on pp.PRACTITIONER_ID = cc.PRACTITIONER_ID
  where (clm.IS_PROXY = 1)	    
    and (cc.HAS_PROXY = 1) 
	and (cc.REFERENCE_CLAIM_ID_1 = clm.CLAIM_ID)
) as pproxy

cross apply (
  select      
	 [LN] = DENSE_RANK() OVER(PARTITION BY trc.CLAIM_ID, tr.transmission_id ORDER BY trc.trc_ID, cca.CCN, cca.ADJUDICATION_ID)   
   , trc.transmission_id
   , TRC_ID_TRANSMISION = trc.trc_ID
   , tr.Created_At
   , trc.Amount_Transmitted
   , cca.DATE_ADJUDICATED
   , cca.CCN
   , cca.AMOUNT_PAID
   , TRC_ID_POSTING = cca.TRANSMISSION_RECORD_CLAIM_ID
   , cca.ADJUDICATION_ID
   , cca.POSTING_ID
   , FI_PERCENT_CA = cca.EDSPERCENT
   , ccp.CHECK_DATE
   , ccp.CHECK_NUMBER
   , ccp.CHECK_AMOUNT
   , ccp.POSTING_DATE
   , [STATUS] = case when (cca.AMOUNT_PAID = 0) then 'Denial'
                     when (cca.AMOUNT_PAID > 0) then 'Paid'
					 when (cca.AMOUNT_PAID < 0) then 'Payment Reversal'
					 else 'Pending or Unknown' end
  
  from      dbo.TRANSMISSION_RECORD_CLAIMS_ALL as trc  
  join      dbo.TRANSMISSION_RECORDS_ALL       as tr  on  tr.Transmission_ID = trc.transmission_id
  
  left join dbo.CLAIM_Claim_Adjudication   as cca on  cca.CLAIM_ID = trc.claim_id
                                                  and cca.TRANSMISSION_RECORD_CLAIM_ID = trc.trc_ID
  left join dbo.CLAIM_Claim_Posting        as ccp on ccp.POSTING_ID = cca.POSTING_ID
  where (
        (trc.CLAIM_ID = clm.CLAIM_ID)     
  )
			    
) as txrx

where ((clm.CLIENT_ID = @clientID))

order by 
    clm.CLAIM_ID
  , txrx.LN


)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_CLAIMS_TRANSMITTED_AND_POSTED_CORE] TO [webuser]
GO   



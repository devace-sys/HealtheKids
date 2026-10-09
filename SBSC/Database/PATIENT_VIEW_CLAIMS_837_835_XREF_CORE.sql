USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_CLAIMS_837_835_XREF_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_CLAIMS_837_835_XREF_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_CLAIMS_837_835_XREF_CORE] ( @bic varchar(255) )
RETURNS 
TABLE
AS
RETURN
(
  select 

	
	  clm.PATIENT_ID
	, clm.CLAIM_ID
	, CLAIM_STATUS                   = clm.STATUS
	, BIC_USED_FOR_CLAIM             = i835_02.[patient_bic_(2100_0300_NM1_109)]
    , CLAIM_TRACKING_ID              = i835_02.[claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]
    , CLAIM_PAYER_CONTROL_NUMBER     = i835_02.[claim_control_number_(2100_0100_CLP_CLP07)]
    , CLAIM_PAYER_SERVICE_DATE       = i835_02.[statement_from_date_(2100_0500_DTM_DTM02)]
	, CLAIM_PAYER_RECEIVED_DATE      = i835_02.[claim_received_date_(2100_0500_DTM_DTM02)]
   	, CLAIM_PAYER_ADJUDICATED_DATE   = i835_01.[check_issue_or_eft_effective_date_(BPR_0200_BPR16)]
    , CLAIM_PAYER_STATUS_CODE        = i835_02.[claim_status_code_(2100_0100_CLP_CLP02)]
	, CLAIM_PAYER_ADJUDICATED_AMOUNT = i835_02.[claim_amount_paid_(2100_0100_CLP_CLP05)]
	, CLAIM_PAYER_PAID_CLAIM         = convert(bit,(case when (i835_02.[claim_status_code_(2100_0100_CLP_CLP02)] in ('1','2','3','22')) then 1 else 0 end))
	, CLAIM_PAYER_DENIED_CLAIM       = convert(bit,(case when (i835_02.[claim_status_code_(2100_0100_CLP_CLP02)] = '4') then 1 else 0 end))
  from dbo.[Import_From_837]                                                                as i837  
  join dbo.CLAIM_Claim                                                                      as clm on clm.CLAIM_ID = i837.claim_id
  join dbo.[Import_From_835_DS_002_Claim_Level_Claim_Payment_Info_Patient_Name_Claim_Dates] as i835_02 on i835_02.[claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)] = i837.[claim_info_claim_submitter_claim_tracking_id (2300 1300 CLM CLM01)]
  join dbo.[Import_From_835_DS_001_Checks]                                                  as i835_01 on  i835_01.file_id           = i835_02.file_id
                                                                                                       and i835_01.tx_control_number = i835_02.tx_control_number
  where (i835_02.[patient_bic_(2100_0300_NM1_109)] = @bic)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_CLAIMS_837_835_XREF_CORE] TO [webuser]
GO   

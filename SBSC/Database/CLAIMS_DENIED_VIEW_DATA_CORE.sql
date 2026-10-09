USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_DENIED_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_DENIED_VIEW_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIMS_DENIED_VIEW_DATA_CORE] (
     @clientID          BIGINT
   , @oldestDOS         DATETIME
   , @today             DATETIME
   , @claimID           BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * CLAIMS_DENIED_VIEW_DATA_CORE */    
 /**    
  * Returns core denial data
  * Requires @clientID, @oldestDOS
  * Relies on [IDX_CLIENT_SVCDATE] index on [dbo].[CLAIM_Claim]
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
 
with

/*###########################################################################
  # Base
  # Note: Columns are in same order as IDX_CLIENT_SVCDATE index
  ###########################################################################*/  

cte_base
as
(
   select 
     cc.CLIENT_ID
   , cc.SERVICE_DATE
   , cc.CLAIM_ID
   , cc.PATIENT_ID
   , cc.PROCEDURE_ID
   , cc.PRACTITIONER_ID
   , cc.GROUP_ID
   , cc.SERVICE_UNITS
   , cc.ENTRY_DATE
   , cc.STATUS
   , cc.ORP_PRACTITIONER_ID
   , cc.HAS_PROXY
   , cc.IS_PROXY
   , cc.HOLD      
  
  from dbo.CLAIM_Claim as cc
	                                         
  where (
         (cc.CLIENT_ID     = @clientID)
    and  (cc.SERVICE_DATE between @oldestDOS and @today)
	and  ((@claimID is null) or (cc.CLAIM_ID = @claimID))
	and  ((cc.STATUS = dbo.CONST_CLAIM_STATUS_SUB_REJECT()) or (cc.STATUS = dbo.CONST_CLAIM_STATUS_RECV_PROXY_DENIED()))
   )
)
,

/*###########################################################################
  # Stand Alone Claims
  ###########################################################################*/  

cte_stand_alone_denied_claims
as
(
  select cc.* from cte_base as cc where ((cc.IS_PROXY  = 0) and (cc.HAS_PROXY = 0))
)
,

/*###########################################################################
  # Proxy Claims
  ###########################################################################*/  

cte_proxy_denied_claims
as
(
  select cc.* from cte_base as cc where ((cc.IS_PROXY  = 1) and (cc.HAS_PROXY = 0))
)
,

/*###########################################################################
  # Combined
  ###########################################################################*/  

cte_denied_claims_combined
as
(
  select * from cte_stand_alone_denied_claims
  union
  select * from cte_proxy_denied_claims
)
,

/*###########################################################################
  # Output Pass 1
  ###########################################################################*/  

cte_output_p1
as
(
  select 
  
     cc.*
   
   , gd.GROUP_SERVICE_CLASS_NAME_ID
   , gd.GROUP_SERVICE_CLASS_NAME
   , gd.GROUP_NAME   
   , cp.IEP_IFSP_NAME
   , cp.NO_PLAN_NAME
   , cp.SERVICE_TYPE_ID
   , cp.SERVICE_SUB_TYPE_1_ID
   , cp.PROCEDURE_NAME
   , cp.PROCEDURE_CODE
   , cp.PROCEDURE_MODIFIER_1
   , cp.PROCEDURE_MODIFIER_2
   , cp.PROCEDURE_MODIFIER_3
   , cp.PROCEDURE_MODIFIER_4
   
   , PROC_MOD_COMBO =  dbo.RPT_PROC_MOD_COMBO (   cp.PROCEDURE_CODE
                                               , cp.PROCEDURE_MODIFIER_1
                                               , cp.PROCEDURE_MODIFIER_2
                                               , cp.PROCEDURE_MODIFIER_3
                                               , cp.PROCEDURE_MODIFIER_4 )

   , cca.ADJUDICATION_ID
   , cca.DATE_ADJUDICATED
   , cca.AMOUNT_PAID  
   , cca.CCN
   , cca.POSTING_ID
   , cca.PROXY_DISBURSED
   , cca.TRANSMISSION_RECORD_CLAIM_ID   
         
   , ccad.CCAD_ID
   , cdg.GROUP_CODE
   , cdg.GROUP_DETAIL   
   , cdc.CODE_VALUE
   , cdc.DETAIL_TEXT
   , pap.DHCS_LAST_NAME
   , pap.DHCS_FIRST_NAME
   , pap.LAST_NAME
   , pap.FIRST_NAME
   , pap.DATE_OF_BIRTH
   , pap.SEX
   , BIC = trim(isnull(pap.BIC,''))
   , pap.CSIS
   , ADJUDICATION_RANK = DENSE_RANK() over (partition by cc.CLIENT_ID, cc.CLAIM_ID order by cca.DATE_ADJUDICATED desc, cca.ADJUDICATION_ID desc)
   , SERVICE_DATE_ONLY = convert(date,SERVICE_DATE)
   , PATIENT_POSSIBLY_LEA_BOP_ELIG = dbo.IS_PATIENT_POSSIBLY_LEA_BOP_ELIG(pap.BIC,pap.ffpQualified)
  from cte_denied_claims_combined           as cc 
 
  join dbo.CLAIM_Procedures                 as cp   on cp.PROCEDURE_ID      = cc.PROCEDURE_ID
  join dbo.CLAIM_Claim_Adjudication         as cca  on cca.CLAIM_ID         = cc.CLAIM_ID
  join dbo.CLAIM_CLAIM_ADJUDICATION_DETAILS as ccad on ccad.ADJUDICATION_ID = cca.ADJUDICATION_ID
  join dbo.CLAIM_DETAIL_CODES               as cdc  on cdc.CODE_ID          = ccad.DETAIL_CODE_ID
  join dbo.CLAIM_DETAIL_GROUPS              as cdg  on cdg.GROUP_ID         = ccad.DETAIL_GROUP_ID
  join dbo.PATIENTS_Patient                 as pap  on pap.PATIENT_ID       = cc.PATIENT_ID
  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as gd on  gd.GROUP_SERVICE_CLASS_PARTITION_ID = 100
                                                                        and gd.GROUP_ID = cc.GROUP_ID
)
,

/*###########################################################################
  # Output Pass 2
  ###########################################################################*/  

cte_output_p2
as
(
  select 
      op1.*
	, SVC_REC_ID    = src.svcRecID	
	, PLAN_TYPE_ID  = sr.planType
	, IS_IFSP_IEP   = sr.isIFSPorIEP
	, CLAIM_PURPOSE = src.purpose		
	, DETAIL_RANK = DENSE_RANK() over (partition by CLIENT_ID, CLAIM_ID order by DATE_ADJUDICATED desc, ADJUDICATION_ID desc, CCAD_ID asc) 	
	, USE_OR_LOSE = dbo.CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM(SERVICE_DATE,@today)    
	, PAT_BIC_LEN_OK = convert(bit,case when len(BIC) = 14 then 1 else 0 end)
    
	, CLASS_SVC_IS_SUB_STATE = convert (bit, (case 
	   when ((sr.state = 20)) then 1 
	  else 0 end))


	, CLASS_NON_PROXY_HELD = convert (bit, (case 
	   when ((HAS_PROXY = 0) and (IS_PROXY = 0) and (HOLD = 1)) then 1 
	  else 0 end))

	, CLASS_PREV_PAID   = convert (bit, (case 
	    when ((GROUP_CODE = 'CO') and (CODE_VALUE = 'B13')) then 1 /* Previously paid. Payment for this claim/service may have been provided in a previous payment. */
        when ((GROUP_CODE = 'HE') and (CODE_VALUE = 'M86')) then 1 /* Service denied because payment already made for same/similar procedure within set time frame. */
	  else 0 end))
    
	, CLASS_PAT_UNKNOWN = convert (bit, (case 
	    when ((GROUP_CODE = 'CO') and (CODE_VALUE = '31')) then 1  /* Patient cannot be identified as our insured. */      
	  else 0 end))

	, CLASS_PAT_NOT_ELIG = convert (bit, (case 
	    when ((GROUP_CODE = 'HE') and (CODE_VALUE = 'N30'))  then 1 /* Patient ineligible for this service. */
		when ((GROUP_CODE = 'CO') and (CODE_VALUE = '177'))  then 1 /* Patient has not met the required eligibility requirements. */        
	  else 0 end))

    , CLASS_IFSP_LIMITS_REACHED = convert (bit, (case when sr.planType = 1 then
	    case
		  when ((GROUP_CODE = 'CO') and (CODE_VALUE = '119'))  then 1 /* Benefit maximum for this time period or occurrence has been reached. */
          when ((GROUP_CODE = 'HE') and (CODE_VALUE = 'N362')) then 1 /* The number of Days or Units of Service exceeds our acceptable maximum. */
	    else 0 end
	  else 0 end))

	, CLASS_IEP_LIMITS_REACHED = convert (bit, (case when sr.planType = 2 then
	    case
		  when ((GROUP_CODE = 'CO') and (CODE_VALUE = '119'))  then 1 /* Benefit maximum for this time period or occurrence has been reached. */
          when ((GROUP_CODE = 'HE') and (CODE_VALUE = 'N362')) then 1 /* The number of Days or Units of Service exceeds our acceptable maximum. */
	    else 0 end
	  else 0 end))

	, CLASS_IEP_IFSP_NON_ASSMT_LIMITS_REACHED = convert (bit, (case when sr.planType in (1,2) and (SERVICE_TYPE_ID != 1) then
	    case
		  when ((GROUP_CODE = 'CO') and (CODE_VALUE = '119'))  then 1 /* Benefit maximum for this time period or occurrence has been reached. */
          when ((GROUP_CODE = 'HE') and (CODE_VALUE = 'N362')) then 1 /* The number of Days or Units of Service exceeds our acceptable maximum. */
	    else 0 end
	  else 0 end))

	, CLASS_NO_PLAN_LIMITS_REACHED = convert (bit, (case when sr.planType = 3 then
	    case
		  when ((GROUP_CODE = 'CO') and (CODE_VALUE = '119'))  then 1 /* Benefit maximum for this time period or occurrence has been reached. */
          when ((GROUP_CODE = 'HE') and (CODE_VALUE = 'N362')) then 1 /* The number of Days or Units of Service exceeds our acceptable maximum. */
	    else 0 end
	  else 0 end))

  from cte_output_p1             as op1
  join dbo.SERVICE_RECORD_CLAIMS as src on src.claimID = op1.CLAIM_ID
  join dbo.SERVICE_RECORDS       as sr  on sr.id       = src.svcRecID
)

/*###########################################################################
  # Output 
  # Note: 
  # At this layer there will be multiple adjudication and multiple adjudication
  # detail records for some claims
  ###########################################################################*/  

select 
  *   
from cte_output_p2

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_DENIED_VIEW_DATA_CORE] TO [webuser]
GO  

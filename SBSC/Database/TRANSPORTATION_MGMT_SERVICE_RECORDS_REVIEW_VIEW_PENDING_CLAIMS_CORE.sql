USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_PENDING_CLAIMS_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_PENDING_CLAIMS_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_PENDING_CLAIMS_CORE] (
    @clientID          BIGINT
   ,@oldestDOS         DATETIME
)
      
returns table     
as    
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_CLAIMS_CORE */    
/**    
 * Returns list of claim ids associated with transporation service records
 * that have been reviewed and held or approved via the transportation
 * management service record review screen and not submitted or adjudicated.
 ***************************************************************************/     
    
return 
(        

with
cte_trans_claims_man_reviewed
as
(
  select 
      cc.CLAIM_ID
    , cc.HAS_PROXY
	, cc.IS_PROXY
	, cc.REFERENCE_CLAIM_ID_1
	, cc.STATUS 
	, cc.HOLD

  from dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEWED as srr
  join dbo.SERVICE_RECORDS                              as sr  on sr.id        = srr.SVC_REC_ID
  join dbo.SERVICE_RECORD_CLAIMS                        as src on src.svcRecID = sr.id
  join dbo.CLAIM_CLAIM                                  as cc  on cc.CLAIM_ID  = src.claimID  
  where ( 
        (srr.CLIENT_ID  = @clientID)
    and (srr.OK_TO_BILL = 1)
	and (sr.dos >= @oldestDOS)
	and (sr.svcType = dbo.CONST_SERVICES_TRANSPORT())
	and (sr.state  != dbo.CONST_SVC_REC_STATE_CIF())
    and (sr.state  != dbo.CONST_SVC_REC_STATE_DEL())
	/* Note: Unfortunatley we cannot simply search for status submitted because of how the proxy system
	 handles transportation claims. */
	and (cc.STATUS != dbo.CONST_CLAIM_STATUS_SUB_PAID())
	and (cc.STATUS != dbo.CONST_CLAIM_STATUS_SUB_REJECT())
  )
)  
,
/* Stand alone transportation claims */
cte_trans_claims_man_reviewed_not_proxy
as
(
  select      
	tc.CLAIM_ID
  from cte_trans_claims_man_reviewed as tc  
  where (
        (tc.HAS_PROXY = 0) 
    and (tc.IS_PROXY = 0) 
    and (tc.STATUS = dbo.CONST_CLAIM_STATUS_NOT_SUB())
	and (tc.HOLD = 0)
  )
)
,
/* Proxy transportation claims */
cte_trans_claims_man_reviewed_proxy
as
(
  select distinct
	cc2.CLAIM_ID
  from cte_trans_claims_man_reviewed as tc
  join dbo.CLAIM_CLAIM as cc2 on cc2.CLAIM_ID = tc.REFERENCE_CLAIM_ID_1
  where (
        (tc.HAS_PROXY = 1) 
	and (tc.IS_PROXY = 0) 
	and (cc2.HAS_PROXY = 0)
	and (cc2.IS_PROXY = 1)
	and (cc2.STATUS = dbo.CONST_CLAIM_STATUS_NOT_SUB()) 
	and (cc2.HOLD = 0)
  )
)
,
cte_combo
as
(
    select CLAIM_ID from cte_trans_claims_man_reviewed_not_proxy
    union
    select CLAIM_ID from cte_trans_claims_man_reviewed_proxy
)
select distinct CLAIM_ID from cte_combo
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_PENDING_CLAIMS_CORE] TO [webuser]
GO
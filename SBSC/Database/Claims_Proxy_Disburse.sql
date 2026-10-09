use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Claims_Proxy_Disburse') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE Claims_Proxy_Disburse
GO


CREATE PROCEDURE Claims_Proxy_Disburse

AS
BEGIN


/* Proxy disbursal consists of taking adjudicated proxy claims and distributing the payment between the associated actual claims. */

declare @proxy_payment_data table (proxy_claim bigint,proxy_adj bigint,orig_claim bigint, 

			proxy_payment decimal(18,2), original_unit_total bigint, distribution_factor decimal(18,2), 
			
			adjusted_original_payment decimal(18,2), pay_difference decimal(18,2), adjusted_amount decimal(18,2))

declare @proxy_disburse_data as table (
    CHILD_CLAIM_ID    bigint
  , DISBURSE_FACTOR   decimal(18,2)
  unique clustered (CHILD_CLAIM_ID)
)

/* Get disburse factors */
insert into @proxy_disburse_data
select 
    CHILD_CLAIM_ID
  , DISBURSE_FACTOR 
from dbo.CLAIMS_PROXY_DISBURSE_VIEW_CORE()


insert into @proxy_payment_data (proxy_claim, proxy_adj, orig_claim)
select proxy_claim.CLAIM_ID, proxy_adj.ADJUDICATION_ID, original_claim.CLAIM_ID
from 
	CLAIM_Claim proxy_claim
	inner join CLAIM_Claim_Adjudication proxy_adj 
		on proxy_claim.CLAIM_ID = proxy_adj.CLAIM_ID
		and proxy_claim.IS_PROXY = 1
		and proxy_adj.PROXY_DISBURSED = 0
	inner join CLAIM_Claim original_claim on original_claim.HAS_PROXY = 1 and original_claim.REFERENCE_CLAIM_ID_1 = proxy_claim.CLAIM_ID


/* get amount paid for each proxy claim */

update @proxy_payment_data 

set proxy_payment = proxy_info.AMOUNT_PAID

from
(
 select proxy_adj.CLAIM_ID, proxy_adj.ADJUDICATION_ID, proxy_adj.AMOUNT_PAID

from 
	CLAIM_Claim proxy_claim
	inner join CLAIM_Claim_Adjudication proxy_adj 
		on proxy_claim.CLAIM_ID = proxy_adj.CLAIM_ID
		and proxy_claim.IS_PROXY = 1
		and proxy_adj.PROXY_DISBURSED = 0
) proxy_info
where proxy_info.CLAIM_ID = proxy_claim
	and proxy_info.ADJUDICATION_ID = proxy_adj



/* get full sum of service units from ORIGINAL claims. The proxies should cap at 32, which means we can't depend on them for accurate percentages. */

update @proxy_payment_data

set original_unit_total = proxy_info.orig_units
from
(
select proxy_adj.CLAIM_ID, proxy_adj.ADJUDICATION_ID, SUM(original_claim.service_units) as orig_units

from 
	CLAIM_Claim proxy_claim
	inner join CLAIM_Claim_Adjudication proxy_adj 
		on proxy_claim.CLAIM_ID = proxy_adj.CLAIM_ID
		and proxy_claim.IS_PROXY = 1
		and proxy_adj.PROXY_DISBURSED = 0
	inner join CLAIM_Claim original_claim on original_claim.HAS_PROXY = 1 and original_claim.REFERENCE_CLAIM_ID_1 = proxy_claim.CLAIM_ID
	group by proxy_adj.CLAIM_ID, proxy_adj.ADJUDICATION_ID
) proxy_info
where proxy_info.CLAIM_ID = proxy_claim

/* Get distribution factor */

update @proxy_payment_data

  set distribution_factor = pdd.DISBURSE_FACTOR

from       @proxy_payment_data      as ppd
inner join dbo.CLAIM_Claim          as cc  on cc.CLAIM_ID        = ppd.orig_claim
inner join @proxy_disburse_data     as pdd on pdd.CHILD_CLAIM_ID = cc.CLAIM_ID

/* Calculate adjusted amount_paid for each of the original claims */

update @proxy_payment_data
set adjusted_original_payment = proxy_payment*distribution_factor

/* Compare the sum of the new amount_paid values with the original proxy amount_paid, and mark if they are different  */
/* Figure out the amount to be adjusted (up or down) */
/* There's a potential for a disbursal's division to not total up to the full amount of the original disbursal,
	thanks to things like rounding errors. */
	
/* So, for each adjudication:

	The adjudication is paid at amount A.
	
	That amount is disbursed to original claims O(1-n) using formula d(n)*O(n) = p(n), 
	where d is the appropriate distribution factor for claim n, and p is the payment going to original claim n
	
	in order to check that amounts are consistent, we backcheck that A = sum(p()) for each individual adjudication
*/

update @proxy_payment_data
set pay_difference = pay_delta
from
(
	select ppd.proxy_claim as PROXY, ppd.proxy_adj as ADJ, (total_original -  proxy_payment) as pay_delta
	from @proxy_payment_data ppd
	cross apply (select SUM(adjusted_original_payment) total_original from @proxy_payment_data inner_total where inner_total.proxy_claim = ppd.proxy_claim and inner_total.proxy_adj = ppd.proxy_adj) iside_total
) q
where q.PROXY = proxy_claim and q.ADJ = proxy_adj


/* In the event that A <> sum(p), we want to find a value t s.t. t = A - sum(p).
	Then, add t to one specific payment to an original claim to allow A = sum(p(1-(n-1)) + p(n) + t, balancing everything out.*/

/* Do the actual adjustment on ONE claim per proxy. use a partitioned ROW_number()? */
/* The adjusted amount is dumped back into the adjusted_original_payment column */


update @proxy_payment_data
set adjusted_amount = adjusted_original_payment - round_output.pay_difference
from
(
select * from
(
select  orig_claim as round_original, proxy_adj as adj, pay_difference, ROW_NUMBER()over (partition by proxy_claim, proxy_adj order by proxy_claim, proxy_adj) round_order from @proxy_payment_data
where pay_difference <> 0
) round_priority where round_priority.round_order =1
)round_output

where round_output.round_original = orig_claim and adj = proxy_adj


update @proxy_payment_data
set adjusted_original_payment = adjusted_amount where adjusted_amount is not null



BEGIN TRANSACTION

INSERT INTO CLAIM_Claim_Adjudication
	(CLAIM_ID, TRANSMISSION_RECORD_CLAIM_ID, DATE_ADJUDICATED, AMOUNT_PAID, CCN, DENIAL_CODE, RAD_1, RAD_2, RAD_3, RAD_4, RAD_5, DENIAL_ID, EDSPERCENT, POSTING_ID)
select orig_claim, cca.TRANSMISSION_RECORD_CLAIM_ID, cca.DATE_ADJUDICATED, adjusted_original_payment, cca.CCN, cca.DENIAL_CODE, cca.RAD_1, cca.RAD_2, cca.RAD_3, cca.RAD_4, cca.RAD_5, cca.DENIAL_ID, cca.EDSPERCENT, cca.POSTING_ID
from @proxy_payment_data ppd
inner join CLAIM_Claim_Adjudication cca on ppd.proxy_adj = cca.ADJUDICATION_ID

print 'closing claims'

/* update original claim status */
update CLAIM_Claim
set STATUS = pick.STATUS
from 
(
select ppd.orig_claim, cc_proxy.STATUS
from
@proxy_payment_data ppd
inner join CLAIM_Claim cc on ppd.orig_claim = cc.CLAIM_ID
inner join CLAIM_Claim cc_proxy on cc.REFERENCE_CLAIM_ID_1 = cc_proxy.CLAIM_ID and cc_proxy.IS_PROXY =1 and cc_proxy.CLAIM_ID in (select proxy_claim from @proxy_payment_data)
) pick
where orig_claim = CLAIM_ID

/* Update proxy claim status */


update CLAIM_Claim
set STATUS = CASE when STATUS = dbo.CONST_CLAIM_STATUS_SUB_PAID() then [dbo].[CONST_CLAIM_STATUS_RECV_PROXY_PAID]()
					WHEN STATUS = dbo.CONST_CLAIM_STATUS_SUB_REJECT() THEN [dbo].[CONST_CLAIM_STATUS_RECV_PROXY_DENIED]() END
where CLAIM_ID in (select proxy_claim from @proxy_payment_data)

/* update the adjudication records for the proxies to indicate they've been processed. */

update CLAIM_Claim_Adjudication
set PROXY_DISBURSED = 1
where  ADJUDICATION_ID in (select proxy_adj from @proxy_payment_data ppd)


select ppd.proxy_claim, ppd.proxy_adj, ppd.orig_claim, c_prox.STATUS, cca_prox.AMOUNT_PAID, cca_prox.PROXY_DISBURSED, c_orig.STATUS, cca_orig.* from @proxy_payment_data ppd
inner join CLAIM_Claim c_prox on ppd.proxy_claim = c_prox.CLAIM_ID
inner join CLAIM_Claim_Adjudication cca_prox on cca_prox.ADJUDICATION_ID = ppd.proxy_adj
inner join CLAIM_Claim c_orig on ppd.orig_claim = c_orig.CLAIM_ID

inner join CLAIM_Claim_Adjudication cca_orig on c_orig.CLAIM_ID = cca_orig.CLAIM_ID
order by ppd.proxy_claim
COMMIT TRANSACTION


END
GO
 
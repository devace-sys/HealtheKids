USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_HOWMUCH_CALCULATE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_HOWMUCH_CALCULATE
GO

/*-------------------------------
 * Object Definitions
 *------------------------------*/

CREATE FUNCTION [dbo].CLAIMS_HOWMUCH_CALCULATE
(@claimList bigint_TABLETYPE READONLY)
returns table as
RETURN 
(
/* given a list of claimIDs, calculate monetary amounts and overview summaries */
with claimData as
(
	select cl.id as claim_ID 
	, dbo.CLAIMS_AMOUNT_CALC(cl.id) as claimBillAmount
	
	from @claimList cl
)

select
	--tr.Transmission_ID,
	--tr.Created_At, 
	client.CLIENT_ID,
	client.CLIENT_NAME,
	client.ShortName,
	client.CLIENT_CDS,
	client.NPI,
	client.TAX_ID,
	
	COUNT (cl.CLAIM_ID)													as 'Total Number of Claims', 
	SUM(cl.claimBillAmount)												as 'Total Dollar Amount'  ,
	
	count (case when num_adj = 0 then 1 end)							as '# of Claims Submitted',
	SUM(case when num_adj = 0 then cl.claimBillAmount else 0 end)		as 'Amount Submitted'  ,
	
	count (case when num_adj <> 0 then 1 end)							as 'Claims Resubmits',
	SUM(case when num_adj <> 0 then cl.claimBillAmount else 0 end)		as 'Amounts Resubmitted',
	
	
	Trunc_RevShare.RevenueSharingCategoryLEA,
	
	client.WhenToInvoice,
	client.InvoiceRate
	
from
	claimData										as cl
	inner join dbo.CLAIM_Claim							as join_claims
		on join_claims.CLAIM_ID = cl.claim_id
	inner join dbo.CLIENTS_Client						as client 
		on join_claims.CLIENT_ID = client.CLIENT_ID
	
	cross apply 
	(
	  select RevenueSharingCategoryLEA = 
	  case 
	    when (client.RevenueSharingCategoryLEACurrent is null)          then N'**'
		when( client.RevenueSharingCategoryLEACurrent not like 'LEA-%') then N'**'
	    else trim(client.RevenueSharingCategoryLEACurrent)
	  end
	) as Trunc_RevShare
	
	outer apply (
		select 
			COUNT(*) as num_adj 
		from 
			dbo.CLAIM_Claim_Adjudication	as cca 
		where 
			cca.CLAIM_ID = cl.claim_id 
			and DATE_ADJUDICATED <= GETDATE()
	)												as adj_count
	
	
group by
	--tr.Transmission_ID,
	--tr.Created_At, 
	client.CLIENT_ID,
	client.CLIENT_NAME,
	client.ShortName,
	client.CLIENT_CDS,
	client.NPI,
	client.TAX_ID,
	Trunc_RevShare.RevenueSharingCategoryLEA,
	client.WhenToInvoice,
	client.InvoiceRate
	
)

GO
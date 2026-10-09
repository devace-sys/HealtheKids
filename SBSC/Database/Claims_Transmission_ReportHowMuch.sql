use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Claims_Transmission_ReportHowMuch') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.Claims_Transmission_ReportHowMuch
GO


CREATE PROCEDURE dbo.Claims_Transmission_ReportHowMuch

AS
BEGIN


	/****************************************

		Claims_Transmission_ReportHowMuch
		
		In order to determine which clients 
		should be transmitted in an 837 file,
		
		a HOWMUCH query is needed to inform 
		on which clients have eligible claims,
		how many claims there are, as well as 
		the total amount billable for those claims.


	*****************************************/
	declare @generationID bigint
	
	exec TRANSMISSION_GENERATION_HOWMUCH @generationID OUTPUT

	select 
		CONVERT(varchar(max),cc.CLIENT_ID) + ',' as CLIENT_ID, 
		CASE 
		when exists (select 1 from CLIENTS_Client cc where cc.CLIENT_ID = client.CLIENT_ID and FIRST_CHECK is null)
			then '*** FIRST TRANSMISSION *** ' + client.CLIENT_NAME
		else client.CLIENT_NAME
		END as CLIENT_NAME, 
		COUNT (cc.CLAIM_ID) as 'Number of claims', 
		SUM(claim_amount) as 'Total Dollar amount',
		NPI,
		TAX_ID,
		EIN,
		APPROVED_837,
		APPROVED_835,
		ca.CLIENT_ID as HAS_ADDRESS
		
		
	from dbo.TRANSMISSION_GENERATION_RELEASEABLE_CLAIMS(@generationID)					as gen_trans
		inner join dbo.CLAIM_Claim														as cc 
			on gen_trans.ClaimID= cc.CLAIM_ID
		inner join dbo.CLAIM_Procedures													as cp 
			on cc.procedure_id = cp.PROCEDURE_ID
		inner join dbo.CLIENTS_Client													as client 
			on cc.CLIENT_ID = client.CLIENT_ID
		left outer join dbo.CLIENTS_Address												as ca 
			on client.CLIENT_ID = ca.CLIENT_ID
		OUTER APPLY (select dbo.CLAIMS_AMOUNT_CALC(cc.CLAIM_ID) as claim_amount)	as bill_amt

	group by 
		cc.CLIENT_ID, client.CLIENT_ID, client.CLIENT_NAME,
		NPI,
		TAX_ID,
		EIN,
		APPROVED_837,
		APPROVED_835,
		ca.CLIENT_ID
		
	order by [Total Dollar amount] desc

END

/*
* Grant Webuser Execute Permission
*/
GO

GRANT EXECUTE ON [dbo].[Claims_Transmission_ReportHowMuch] TO webuser

GO
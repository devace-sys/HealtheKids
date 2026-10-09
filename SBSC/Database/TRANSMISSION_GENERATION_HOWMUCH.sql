
use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_HOWMUCH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_HOWMUCH
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_HOWMUCH
(
	 @generationID as bigint OUTPUT
)

AS
BEGIN


/* TODO: Where does this fall in our transmission process? */

declare @today     as datetime 
declare @oldestDOS as datetime
declare @newestDOS as datetime

set @today     = getdate()
set @oldestDOS = dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,@today)) 	 
set @newestDOS = dateadd(day, 1, @today)

	/* 1: Create the generation for holding transmittable claims */
	exec dbo.TRANSMISSION_GENERATION_CREATE NULL, NULL, NULL, @oldestDOS, @newestDOS, NULL, NULL, @generationID OUTPUT

	/* 2: Append all transmissable claims for all clients */

		/* the null client record in the created generation  is used to do this internally */

	exec dbo.TRANSMISSION_GENERATION_APPEND_GENERATION_CLAIMS @generationID

	/* 3: Check the claims in the generation and figure out which are held */
		/* This hold predicts proxies */

	exec dbo.TRANSMISSION_GENERATION_APPLY_HOLDS @generationID, 1


	/* 4: Determine the claims that would be transmitted for this generation and use them as a basis for report/decisionmaking */
      
     /* EAW: Commented out to patch issue */
	
	/* TODO: If we're just using this as a data process, pull out this select */
	/*
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
*/
END
GO
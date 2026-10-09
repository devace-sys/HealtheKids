USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_AMOUNT_CALC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_AMOUNT_CALC
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLAIMS_AMOUNT_CALC]    
(@claimID bigint)
 RETURNS money
 WITH SCHEMABINDING 
 AS     
 BEGIN        
 
	/* Calculates the billable amount */
 
 
	declare @claim_amount decimal(18,2) =
	(
		select
			CASE 

				/* TCM rate is determined on a per-client basis */

				WHEN (cp.PROCEDURE_CODE like 'T1017%' and client.TCM_RATE = 'LOW')
				THEN (cc.service_units*CONVERT(DECIMAL(18,2),cp.TCM_LOW_RATE))

				WHEN (cp.PROCEDURE_CODE like 'T1017%' and client.TCM_RATE = 'MED')
				THEN (cc.service_units*CONVERT(DECIMAL(18,2),cp.TCM_MEDIUM_RATE))

				WHEN (cp.PROCEDURE_CODE like 'T1017%' and client.TCM_RATE = 'HIGH')
				THEN (cc.service_units*CONVERT(DECIMAL(18,2),cp.TCM_HIGH_RATE))
				
				
				/* 15-45 minute services:
				
				If a service is a 15-45 minute service, the normal rule of 1 billing unit/15min does not apply.
				One unit of a 15-45 minute service can cover 1-3 15min units.
				
				*/
				WHEN (cp.PROCEDURE_NAME like '%15-45%')
				THEN (1*cp.SERVICE_FEE)
				
				
				/* If we have no special payment rules, use the general rule of Units x Fee/Unit */
				ELSE
					(cc.service_units*cp.SERVICE_FEE)
			end as Dollar_amount
		from dbo.claim_claim						as cc
		inner join dbo.claim_procedures				as cp 
			on cc.procedure_id = cp.procedure_id
		inner join dbo.clients_client				as client 
			on cc.client_id = client.client_id
	 
		where cp.active = 1
		and cc.claim_id = @claimID
	 )
 
   RETURN CONVERT(money, @claim_amount)
END    
GO  
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_TRANSMISSION_LIST_CORE_CLAIM_SET') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_TRANSMISSION_LIST_CORE_CLAIM_SET
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].CLAIMS_TRANSMISSION_LIST_CORE_CLAIM_SET (
   @clientID            as bigint				/* Look for claims for a specific client */
 , @patientID           as bigint				/* Look for claims for a specific patient */
 , @claimID             as bigint				/* Look for a specific claim */
 , @oldestDOS           as date				/* DOS On or after this date */
 , @dayAfterNewestDOS   as date		/* DOS BEFORE this date (4/2/2017 would be saying 'The set of claims with DOS on or before 4/1/2017' */
 , @oldestEntry         as date				/* Entered on or after this date */	
 , @dayAfterNewestEntry as date		/* Entered BEFORE this date (4/2/2017 would be saying 'The set of claims entered on or before 4/1/2017' */
 , @allBillable bit					/* Indicates whether we are looking only at transmittable claims (0), or the set of all claims that would be billable, regardless of current status (1) */
 
)
RETURNS table as

/***********************************************************************
*
*	Generates a list of 'minimally transmissable claims'
*
*	There are a set of very basic criteria that a claim has to meet
*	before we even think of transmitting it.
*
*	This function provides access to the set of claims that fulfill 
*	this criteria for consistency and reusability, as well as
*	arguments that limit the set of claims by date ranges and
*	client\patient\claim IDs.
*
************************************************************************/

/* FOR FUTURE DEVS: NOT ALL TRANSMITTABLE CLAIMS HAVE SERVICE RECORDS */
/* SEE PROXIED CLAIMS ISSUES FROM 5/16-5/17 */
return
(

select distinct 
	cc.CLAIM_ID as ClaimID
from dbo.CLAIM_Claim											as cc
	
	/* A transmittable claim needs to have a transmittable procedure */
	inner join dbo.CLAIM_PROCEDURES_TRANSMITTABLE()					as prt
		on cc.procedure_id = prt.procedure_id

	/* A transmittable claim needs to be for a client who is transmittable */
	/* TODO: Is there address validation we can do? */
	inner join dbo.CLIENTS_Client									as cli
		  on (
				(@clientID is null)
				OR 
				 @clientID = cli.CLIENT_ID
			 )
		 AND cc.CLIENT_ID = cli.CLIENT_ID
		 and cli.CLIENT_ID <> 112 /* SpEdCare USD */
		 and cli.LEA = 1
		 AND cli.APPROVED_835 = 1
		 and cli.APPROVED_837 = 1
	     
	/* A transmittable claim needs to be for a patient that Medi-Cal will bill for */
	inner join dbo.PATIENTS_Patient									as pp
		 on cc.PATIENT_ID = pp.PATIENT_ID
		and (
				(@patientID is null)
				OR 
				 @patientID = pp.PATIENT_ID
			)
		and LEN(pp.BIC) = 14 /* TODO: Calculate BIC length in a computed column? */
	          
	where 1=1
	/* Filter the claimlist by arguments - this lets us look at the transmittable clients for: */
		/* A specific claim */
		/* A specific patient */
		/* A specific practitioner*/
		/* A range of service dates */
		/* A range of entry dates */
		and ( 
				@claimID is null
				OR
				cc.claim_id = @claimID
			)	
		and ( 
				cc.service_date is null
				or
				cc.SERVICE_DATE >= @oldestDOS
			)
		and (
				@dayAfterNewestDOS is null
				OR
				cc.service_date < @dayAfterNewestDOS
			)
		and (
				@oldestEntry is null
				OR
				cc.ENTRY_DATE >= @oldestEntry
			)
		and (
				@dayAfterNewestEntry is null
				OR
				cc.ENTRY_DATE < @dayAfterNewestEntry
			)	
		/* Sometimes we want to look at the set of all billable claims, not just the ones that are transmittable */
		and (
				cc.STATUS = 1 
				or 
				ISNULL(@allBillable,0) = 1
			) 
)


GO
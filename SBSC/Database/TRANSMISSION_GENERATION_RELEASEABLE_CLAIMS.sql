USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSMISSION_GENERATION_RELEASEABLE_CLAIMS') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSMISSION_GENERATION_RELEASEABLE_CLAIMS
GO

/*-------------------------------
 * Object Definitions
 *------------------------------*/

CREATE FUNCTION [dbo].TRANSMISSION_GENERATION_RELEASEABLE_CLAIMS
(@generationID bigint)
returns table as
RETURN 
(
	/* Compares the list of claims in the generation against the list of held claims for that generation */
	/* Outputs the list of claims that are not in the held list */
	/* TODO: This doesn't handle the case where a claim is not held, but also not processed */


	select tglc.ClaimID
	from dbo.TRANSMISSION_GENERATION_LIST_CLAIMS			as tglc

	where 1=1
	and not exists (
				select top 1 1
				from dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD		as held
					where 1=1
					and held.GenListClaimID = tglc.id
					and held.GenerationID	= tglc.GenerationID
			)
		
	 and tglc.GenerationID = @generationID
 
)

GO
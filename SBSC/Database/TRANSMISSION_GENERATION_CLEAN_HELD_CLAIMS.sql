
use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_CLEAN_HELD_CLAIMS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_CLEAN_HELD_CLAIMS
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_CLEAN_HELD_CLAIMS
(
 @generationID as bigint
)
AS
BEGIN

/******************************************
 *
 *	After determining a set of held claims 
 *	and inserting them into the hold table,
 *	set up linking between the held claim record and the hold indicating the specific reason
 *  This is crucial because it provides for an easy direct link between a claim in a generation and a held-identifier for that claim in that generation.
 *  (also index magic)
 *	
 ******************************************/
print 1
	raiserror ('TRANSMISSION_GENERATION_CLEAN_HELD_CLAIMS deprecated', 15, 1)
END

GO
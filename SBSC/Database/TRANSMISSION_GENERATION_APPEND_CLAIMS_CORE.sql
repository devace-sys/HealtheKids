
use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_APPEND_CLAIMS_CORE') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_APPEND_CLAIMS_CORE
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_APPEND_CLAIMS_CORE (
   @generationID	as bigint
 , @clientID		as bigint
 , @patientID		as bigint
 , @claimID		    as bigint
 , @oldestDOS		as date
 , @newestDOS		as date
 , @oldestEntry	    as date
 , @newestEntry	    as date
)
AS
BEGIN

-- Deprecated:  Consolidated into another routine

/* Put claims into a generation */
 
--RAISERROR ('Putting claims into a generation', 0, 1) WITH NOWAIT 
 
--insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS (GenerationID, ClaimID)
--select
--   @generationID
-- , ccs.ClaimID
--from dbo.CLAIMS_TRANSMISSION_LIST_CORE_CLAIM_SET (@clientID, @patientID, @claimID ,@oldestDOS ,@newestDOS, @oldestEntry, @newestEntry, 0) as ccs
 
RAISERROR ('Deprecated', 0, 1) WITH NOWAIT 

END


GO
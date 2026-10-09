
use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_APPEND_CLAIMS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_APPEND_CLAIMS
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_APPEND_CLAIMS
(
 @generationID as bigint,
 @clientIDs AS bigint_tabletype READONLY,
 @patientID as bigint,
 @claimID as bigint,
 @oldestDOS AS date,
 @newestDOS as date,
 @oldestEntry as date,
 @newestEntry as date
)
AS
BEGIN

	raiserror('TRANSMISSION_GENERATION_APPEND_CLAIMS is no longer used', 11,1)

end


GO
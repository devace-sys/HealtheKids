
/* EAW: I don't believe this is used anywhere.  */
/* TODO: See if we can remove.*/

use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_APPEND_CLIENT_CLAIMS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_APPEND_CLIENT_CLAIMS
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_APPEND_CLIENT_CLAIMS
(
 @generationID	as bigint,
 @clientIDs AS bigint_tabletype READONLY
)
AS
BEGIN

/******************************************
 *
 *	For a set of client IDs, iterate through and append 
 *	each transmissable client set to the generation list
 *	
 ******************************************/

 declare
	 @patientID		as bigint,
	 @claimID		as bigint,
	 @oldestDOS		AS date,
	 @newestDOS		as date,
	 @oldestEntry	as date,
	 @newestEntry	as date
	 
 /* get non-client values from generation */
 select top 1 
	 @patientID		= tg.patientID
	,@claimID		= tg.claimID
	,@oldestDOS		= tg.oldestDOS
	,@newestDOS		= tg.newestDOS
	,@oldestEntry	= tg.oldestEntry
	,@newestEntry	= tg.newestEntry
 from dbo.TRANSMISSION_GENERATIONS as tg
 where tg.id = @generationID	 


	 declare @clientIterationTable table (id bigint identity (1,1), clientID bigint)
 
 insert into @clientIterationTable
 select distinct ID from @clientIDs
	where ID is not null
 
 declare @idx bigint = 1
 declare @maxIDX bigint 
 select @maxIDX = MAX(id) from @clientIterationTable
 
declare @currClient bigint

/* If there were explicit non-NULL values in the client list, iterate through those and append by client */
if (select COUNT(*) from @clientIDs) <> 0
BEGIN
	while @idx <= @maxIDX
		BEGIN
			select top 1 @currClient =  clientID from @clientIterationTable where id = @idx
			exec dbo.TRANSMISSION_GENERATION_APPEND_CLAIMS_CORE 
					 @generationID	,
					 @currClient	,
					 @patientID		,
					 @claimID		,
					 @oldestDOS		,
					 @newestDOS		,
					 @oldestEntry	,
					 @newestEntry	
			set @idx = @idx + 1
		end
END
ELSE	/* Edge case : If no values were provided in the client, append all transmissable claims for all clients */
	BEGIN
		exec dbo.TRANSMISSION_GENERATION_APPEND_CLAIMS_CORE 
			 @generationID	,
			 null	,
			 @patientID		,
			 @claimID		,
			 @oldestDOS		,
			 @newestDOS		,
			 @oldestEntry	,
			 @newestEntry	
	
	END
	
	

END


GO
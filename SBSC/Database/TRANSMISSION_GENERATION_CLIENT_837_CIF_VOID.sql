use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_CLIENT_837_CIF_VOID') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE TRANSMISSION_GENERATION_CLIENT_837_CIF_VOID
GO

CREATE PROCEDURE TRANSMISSION_GENERATION_CLIENT_837_CIF_VOID (
	  @clientID           bigint	-- the client we want to transmit
	, @path               VARCHAR(255)	-- file path to save to
	, @filename           VARCHAR(100) -- save file name
	, @userid	          bigint	
	, @note               varchar(7000)
	, @transmissionID     bigint OUTPUT
)
AS
BEGIN

set nocount on

declare @today     as datetime
declare @oldestDOS as datetime
declare @newestDOS as datetime
declare @numClaims as int

set @today = getdate()
set @numClaims = 0


/* We are temporarily just submitting for 12 month window */

set @oldestDOS = dbo.CALC_OLDEST_DOS_ALLOWED (convert(date,@today))
set @newestDOS = @today

/*
select 
    @oldestDOS = min(clm.SERVICE_DATE)
  , @newestDOS = max(clm.SERVICE_DATE)
  , @numClaims = count(crps.claimID)  
from dbo.CIF_REQUESTS_PENDING_SUBMISSION as crps
join dbo.CLAIM_Claim                     as clm on clm.CLAIM_ID = crps.claimID
where (crps.clientID = @clientID)

if (@numClaims = 0)
begin 
  RAISERROR ('Nothing to CIF for this client', 0, 1) WITH NOWAIT		
  return
end
*/

set @filename = @fileName + '_CIF_VOID'

exec dbo.TRANSMISSION_GENERATION_CLIENT_837_BY_DATES 
    @clientID
  , @path
  , @filename
  , @userid
  , @note
  , @today
  , @oldestDOS
  , @newestDOS
  , 3 /* Claim source = 3 (CIF void) */
  , null /* Claim sub source (not used) */
  , @transmissionID OUTPUT

END
GO
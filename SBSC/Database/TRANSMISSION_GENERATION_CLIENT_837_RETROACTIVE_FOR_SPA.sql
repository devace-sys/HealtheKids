use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_CLIENT_837_RETROACTIVE_FOR_SPA') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE TRANSMISSION_GENERATION_CLIENT_837_RETROACTIVE_FOR_SPA
GO

CREATE PROCEDURE TRANSMISSION_GENERATION_CLIENT_837_RETROACTIVE_FOR_SPA (
	  @spaID              bigint
	, @clientID           bigint	-- the client we want to transmit
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
declare @forSpaID  as bigint

set @today = getdate()

select top 1
    @forSpaID  = crfs.id
  , @oldestDOS = crfs.earliestDOSAllowed 
  , @newestDOS = crfs.latestDOSAllowed
from dbo.CLAIM_RETROACTIVE_FOR_SPA as crfs
where ( 
      (crfs.id = @spaID)
  and (crfs.startClaiming = 1)
  and (@today between crfs.startClaimingOn and crfs.endClaimingOn)
)

if (@forSpaID is null)
begin 
  RAISERROR ('SPA record not found or claiming window is closed', 0, 1) WITH NOWAIT		
  return
end

set @filename = @fileName + '_RETRO'

exec dbo.TRANSMISSION_GENERATION_CLIENT_837_BY_DATES 
    @clientID
  , @path
  , @filename
  , @userid
  , @note
  , @today
  , @oldestDOS
  , @newestDOS
  , 2 /* Claim source = 2 (spa) */
  , @forSpaID
  , @transmissionID OUTPUT

END
GO
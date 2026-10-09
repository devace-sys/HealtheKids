use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_CLIENT_CLAIM_INIT') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE TRANSMISSION_GENERATION_CLIENT_CLAIM_INIT
GO

CREATE PROCEDURE TRANSMISSION_GENERATION_CLIENT_CLAIM_INIT (
    @generationID  as bigint
  , @userID       as bigint
)
AS
BEGIN

set nocount on

declare @clientID		as bigint
declare @patientID		as bigint
declare @claimID		as bigint
declare @oldestDOS		as date
declare @newestDOS		as date
declare @oldestEntry	as date
declare @newestEntry	as date
declare @claimSource    as bigint
declare @claimSubSource as bigint
declare @today          as datetime

set @today = getdate()

select top 1 
	  @clientID		  = tg.clientID
	, @patientID	  = tg.patientID
	, @claimID		  = tg.claimID
	, @oldestDOS	  = tg.oldestDOS
	, @newestDOS	  = tg.newestDOS
	, @oldestEntry	  = tg.oldestEntry
	, @newestEntry	  = tg.newestEntry
    , @claimSource    = tg.claimSource
	, @claimSubSource = tg.claimSubSource

from dbo.TRANSMISSION_GENERATIONS as tg
where (tg.id = @generationID)

/*============================================================
 * Transportation matching
 *============================================================*/ 

if (@claimSource = 1)
begin

  declare @clientMatches table (
      clientID         bigint
    , nonTransClientID bigint
    UNIQUE CLUSTERED (clientID,nonTransClientID)
  )	 
  
  /* Find matching services (Rules currently say IEP only) */
  
  exec dbo.PRINT_STATUS_MESSAGE 'Transportation matching - Finding matching services'

  insert into @clientMatches
  select distinct
        tm.clientID
      , nonTransClientID = sr.clientID
  from dbo.TRANSPORTATION_MGMT_MATCHING_SERVICES_VIEW_CORE (null,null,null,@clientID,1,@newestDOS) as tm
  join dbo.SERVICE_RECORDS                                                                         as sr on sr.id = tm.nonTransSvcRecID  
  
  /* Update match permit data */

  exec dbo.PRINT_STATUS_MESSAGE 'Transportation matching - Updating match permit data'

  insert into dbo.Claim_Client_Match_Permit
  select distinct
        TRANSPORT_CLIENT_ID = cm.clientID
      , MATCHING_CLIENT_ID  = cm.nonTransClientID
  from @clientMatches                     as cm
  left join dbo.Claim_Client_Match_Permit as mp on  ((mp.TRANSPORT_CLIENT_ID = cm.clientID)
                                                and (mp.MATCHING_CLIENT_ID = cm.nonTransClientID))
  where (
          (cm.clientID != cm.nonTransClientID) 
      and (mp.PERMIT_ID is null)
  )
end
else 
begin
    exec dbo.PRINT_STATUS_MESSAGE 'Transportation matching is not performed for this claim source'    
end

/*============================================================
 * Proxy claims hold and release
 *============================================================*/ 

if (@claimSource = 1)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Running proxy claim hold and release routine'
  exec dbo.CLAIMS_HOLD_RELEASE_PROCESS @userID, @clientID, @today, @oldestDOS, @newestDOS, 0
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Proxy hold and release is not performed for this claim source'
end

END
GO
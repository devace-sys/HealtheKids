use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_APPEND_GENERATION_CLAIMS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_APPEND_GENERATION_CLAIMS
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_APPEND_GENERATION_CLAIMS (
    @generationID	as bigint
  , @claimCount     as bigint output
)
AS
BEGIN

SET NOCOUNT ON
 
declare @clientID		as bigint
declare @patientID		as bigint
declare @claimID		as bigint
declare @oldestDOS		as date
declare @newestDOS		as date
declare @oldestEntry	as date
declare @newestEntry	as date
declare @claimSource    as bigint
declare @claimSubSource as bigint

declare @possibleClaims as table (
  CLAIM_ID bigint
  unique clustered (CLAIM_ID)
)

declare @msg as varchar(512) = ''

set @claimCount = 0

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

exec dbo.PRINT_STATUS_MESSAGE 'Append Generation Claims - Finding All Potential Claims'

/* Claim source is current or retroactive claims */

if (@claimSource in (1,2))
begin
  

  /* Get all claims that have the potential to be transmitted for the given date range */

  insert into @possibleClaims (CLAIM_ID)
  select distinct 
      clm.CLAIM_ID 
  from dbo.CLAIM_Claim                      as clm		
  join dbo.PATIENTS_PATIENT                 as pap on pap.PATIENT_ID = clm.PATIENT_ID
  join dbo.CLAIM_PROCEDURES_TRANSMITTABLE() as prt on clm.PROCEDURE_ID = prt.procedure_id
  where ( 
        (clm.CLIENT_ID = @clientID)
    and (clm.SERVICE_DATE between @oldestDOS and @newestDOS)
    and (clm.STATUS = '1') 
    and (dbo.IS_PATIENT_POSSIBLY_LEA_BOP_ELIG(pap.BIC,pap.ffpQualified) = 1)
  )

end

/* Claim source is CIF void */

else if (@claimSource = 3)
begin
  insert into @possibleClaims(CLAIM_ID)
  select 
    CLAIM_ID = cifps.claimID
  from dbo.CIF_REQUESTS_PENDING_SUBMISSION as cifps
  where (
         (cifps.clientID = @clientID)
	and (cifps.dos between @oldestDOS and @newestDOS)
  )
end

/* Unknown claim source */

else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Append Generation Claims - Unknown Claim Source'  
end

/* Claim source is current claims */

if (@claimSource = 1)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'Append Generation Claims - Assign Current Potential Claims to Generation (they might get held later)'

  insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS (GenerationID, ClaimID)
  select  
      GenerationID = @generationID
    , ClaimID      = pc.CLAIM_ID
  from @possibleClaims as pc

end

/* Claim source is retroactive claims from SPA */

else if (@claimSource = 2)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'Append Generation Claims - Assign Potential Retroactive Claims Authorized By Client to Generation (they might get held later)'
  
  insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS (GenerationID, ClaimID)  
  select distinct
      @generationID as GenerationID
    , rc.claimID    as ClaimID
  from dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SERVICE_RECORD_CLAIMS_POSSIBLE_VIEW_CORE (
      @claimSubSource /* For SPA id is passed in */
    , @clientID
    , null
  ) as rc
  join @possibleClaims as pc on pc.CLAIM_ID = rc.claimID
  where 
    (rc.authorized = 1)

end

/* CIF Void */

else if (@claimSource = 3)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'Append Generation Claims - Assign Current CIF Void Claims to Generation'

  insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS (GenerationID, ClaimID)
  select  
      GenerationID = @generationID
    , ClaimID      = pc.CLAIM_ID
  from @possibleClaims as pc
end

else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Append Generation Claims - Unknown Claim Source'  
end

select 
  @claimCount = count(pc.claimID) 
from dbo.TRANSMISSION_GENERATION_LIST_CLAIMS as pc
where 
  (pc.GenerationID = @generationID)

set @msg = 'Append Generation Claims - Possible Claim Count : ' + convert(varchar(256),@claimCount)
exec dbo.PRINT_STATUS_MESSAGE @msg

END
GO
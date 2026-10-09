use SPEDMON 
GO

/*---------------------------------------------------------------------------------------------------------*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_RESUBMIT_PREVIOUSLY_ADJUDICATED_SERVICE_RECORD_CLAIMS_CORE') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_RESUBMIT_PREVIOUSLY_ADJUDICATED_SERVICE_RECORD_CLAIMS_CORE
end
GO

/*---------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE dbo.CYBHI_RESUBMIT_PREVIOUSLY_ADJUDICATED_SERVICE_RECORD_CLAIMS_CORE (
	  @clientID                    bigint	    = -1
	, @svcRecID                    bigint       = -1
	, @userID	                   bigint       = -1
	, @claimsResetForResubmission  bit output	
)
AS
BEGIN
  
set nocount on

set @claimsResetForResubmission = 0

declare @tranOpen as bit = 0
declare @numClaims       as int      = 0
declare @numClaimsDenied as int      = 0
declare @today           as datetime = getdate()

declare @cybhiClaims as table (
    svcRecID      bigint
  , claimID       bigint
  , txStatusCode  smallint
)

if (@clientID = -1) return
if (@svcRecID = -1) return
if (@userID   = -1) return

begin try

insert into @cybhiClaims (svcRecID, claimID, txStatusCode)
select 
    svcRecID = sr.id
  , claimID  = cc.id  
  , cc.txStatusCode
from dbo.SERVICE_RECORDS             as sr
join dbo.CYBHI_SERVICE_RECORD_CLAIMS as src on src.svcRecID = sr.id
join dbo.CYBHI_CLAIMS                as cc  on cc.id = src.claimID

where (
       (src.svcRecID = @svcRecID)
   and (sr.clientID  = @clientID)
   and (cc.amountClaimed != 0)
   and (cc.numUnits != 0)
   and (cc.numOfSubmissions > 0)
   and (cc.txStatusCode in (3,4))

)


/*---------------------------------------------------------------------------------------------------------*/

select @numClaims       = count(t1.claimID) from @cybhiClaims as t1
select @numClaimsDenied = count(t1.claimID) from @cybhiClaims as t1 where (t1.txStatusCode = 4)

/*---------------------------------------------------------------------------------------------------------*/

if (@numClaims = 0)
begin
  print 'No claims'
  set @claimsResetForResubmission = 0
  return
end

/*---------------------------------------------------------------------------------------------------------*/

if (@numClaimsDenied = 0)
begin
  print 'No denials'
  set @claimsResetForResubmission = 0
  return
end

/*---------------------------------------------------------------------------------------------------------*/

if (@numClaims != @numClaimsDenied)
begin
  print 'All have to be denied'
  set @claimsResetForResubmission = 0
  return
end

/*---------------------------------------------------------------------------------------------------------*/

set @tranOpen = 1
begin transaction

  update cc
  set 
     cc.txStatusCode     = 1
   , cc.prevTxStatusCode = t1.txStatusCode
  from @cybhiClaims     as t1
  join dbo.CYBHI_CLAIMS as cc on cc.id = t1.claimID

  insert into dbo.CYBHI_RESUBMIT_LOG_PREVIOUSLY_ADJUDICATED_SERVICE_RECORD_CLAIMS (
      clientID 			
    , svcRecID               
    , claimID    
    , resetForResubmission 
    , resetForResubmissionOn				
    , created 				 
    , createdBy 			  
  )
  select 
      clientID = @clientID
    , t1.svcRecID
    , t1.claimID
    , resetForResubmission   = 1
    , resetForResubmissionOn = @today  
    , created                = @today
    , createdBy              = @userID
  from @cybhiClaims as t1

commit transaction

set @tranOpen                   = 0
set @claimsResetForResubmission = 1

end try
begin catch

  if (@tranOpen = 1) 
  begin
    rollback transaction
    set @tranOpen                   = 0
    set @claimsResetForResubmission = 0
  end

end catch

return(0)

END
GO

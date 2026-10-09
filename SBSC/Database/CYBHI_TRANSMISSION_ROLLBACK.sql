use SPEDMON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_TRANSMISSION_ROLLBACK') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_TRANSMISSION_ROLLBACK
end
GO

/*---------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE dbo.CYBHI_TRANSMISSION_ROLLBACK (	
	  @transmissionID     bigint 
    , @userID	          bigint
)
AS
BEGIN
  
  set nocount on
  
  if (@transmissionID is null) return(0)
  if (@userID is null)         return(0)

  declare @tranOpen as bit = 0
  declare @today    as datetime = getdate()

  declare @cbhiClaims as table (
      claimID      bigint
	, txStatusCode smallint
	, svcRecID     bigint
  unique clustered(claimID)
  )
  
  declare @cybhiSvcs as table (
      svcRecID    bigint
	, svcRecState smallint
  unique clustered (svcRecID)
  )
  
  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Rollback - Searching for Transmission'
 
  if not exists (
    select top 1
      cct.id	  
    from dbo.CYBHI_CLAIM_TRANSMISSIONS as cct
    where ( 
          (cct.id = @transmissionID)
      and (cct.active = 1)
    )
  )
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Rollback - Tx record not found or already rolled back.'
	return(0)
  end
  
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Rollback - Getting claims and Svc Data'

  insert into @cbhiClaims (
     claimID
   , txStatusCode
   , svcRecID
  )
  select 
      cctc.claimID
	, cctc.txStatusCode
    , cctc.svcRecID
  from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS(@transmissionID,0) as cctc

  insert into @cybhiSvcs (
     svcRecID
   , svcRecState 
  )
  select distinct
      cctc.svcRecID
	, svcRecState = sr.[state]
  from @cbhiClaims                         as cctc
  join dbo.SERVICE_RECORDS                 as sr on sr.id = cctc.svcRecID
  
  if exists (select top 1 claimID from @cbhiClaims where txStatusCode != 2)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Rollback - All claims have to be in submitted status'
    return(0)
  end

  if exists (select top 1 svcRecID from @cybhiSvcs where svcRecState != 20)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Rollback - All svcs have to be in submitted status'
    return(0)
  end

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Rollback - Updating claim records'
  
  begin try

  set @tranOpen = 1
  begin transaction
  
  update clm 
  set 
      clm.txStatusCode   = 1
	, clm.lastModified   = @today
	, clm.lastModifiedBy = @userID
	, clm.numOfSubmissions = iif ((clm.numOfSubmissions > 0)
	                            , (clm.numOfSubmissions - 1)
								, 0)
  from @cbhiClaims as t1
  join dbo.CYBHI_CLAIMS as clm on clm.id = t1.claimID
  
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Rollback - Updating service records'
  
  update sr
  set
      sr.state        = 10
	, sr.lastmodified = dbo.CONST_SVC_REC_STATE_MOD()
  from @cybhiSvcs          as t1
  join dbo.SERVICE_RECORDS as sr on sr.id = t1.svcRecID

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Rollback - Updating tx record'

  update dbo.CYBHI_CLAIM_TRANSMISSIONS
  set 
      active = 0
    , lastModified = @today
    , lastModifiedBy = @userID
  where 
    (id = @transmissionID)
  
  commit transaction
  set @tranOpen = 0

  end try
  begin catch
    if (@tranOpen = 1) rollback transaction
    exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Rollback - Error'
  end catch

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Rollback - Done'

END
GO

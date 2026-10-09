USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSMISSION_RECORD_ROLLBACK_FOR_NEW_CLAIM_SOURCES') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSMISSION_RECORD_ROLLBACK_FOR_NEW_CLAIM_SOURCES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSMISSION_RECORD_ROLLBACK_FOR_NEW_CLAIM_SOURCES] (
    @userID             BIGINT
  , @transmissionID     BIGINT
  , @reasonCode         BIGINT  
  , @notes              VARCHAR(MAX)
  , @test               BIT
  , @backfillMode       BIT )    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSMISSION_RECORD_ROLLBACK_FOR_NEW_CLAIM_SOURCES */    
/**    
 * Rolls back a transmission for a new claim source (1 or 2)
 *    
 * @param   userID          The userid (bigint) of who is doing this
 * @param   transmissonID   Tranmission to rollback
 * @param   reasonCode      The reason for the rollback
 * @param   notes           Additional notes
 * @param   test            1 = Test only
 *                          0 = Do it
 * @param   @backfillMode   0 = No
 *                          1 = Yes.  Do not update claim or service records
 ***************************************************************************/         
     
SET NOCOUNT ON    

BEGIN TRY    
    
declare @tranOpen                 as bit     = 0
declare @today                    as datetime = getdate()
declare @hasProxyClaims           as bit      = 0
declare @transmissionRollbackID   as bigint   = null
declare @clmStatusNotSent         as char(10) = convert(char(10),dbo.CONST_CLAIM_STATUS_NOT_SUB())
declare @clmStatusSent            as char(10) = convert(char(10),dbo.CONST_CLAIM_STATUS_SUB_PENDING())
declare @numClaimsToReset         as int      = 0
declare @numClaimsNotInStatus2    as int      = 0
declare @numOfStandAloneClaims    as int      = 0
declare @numOfProxyClaims         as int      = 0
declare @numOfProxyChildClaims    as int      = 0
declare @numOfSvcRecsNotInState20 as int      = 0
declare @numOfSvcRecs             as int      = 0
declare @numOfSvcRecsStandAlone   as int      = 0
declare @numOfSvcRecsProxied      as int      = 0
declare @txDate                   as datetime       = null
declare @txDateStr                as varchar(50)    = null
declare @clientName               as varchar(200)   = null
declare @totNumClmsStr            as varchar(50)    = '0'
declare @txID                     as bigint         = null
declare @fileName                 as varchar(100)   = null
declare @generationID             as bigint         = null
declare @msg                      as varchar(1000)  = ''
declare @txDaysAgo                as bigint
declare @claimSource              as bigint = 1

declare @transmissionClaims as table (
    CLAIM_ID   bigint
  , IS_PROXY   bit
  , HAS_PROXY  bit
  , trc_ID     bigint
)

declare @standAloneClaims as table (
    CLAIM_ID bigint
)

declare @standAloneServiceRecords as table (
  svcRecID bigint
)

declare @proxyParentClaims as table (
  CLAIM_ID bigint
)

declare @proxyChildClaims as table (
  CLAIM_ID bigint
)

declare @proxyChildServiceRecords as table (
  svcRecID bigint
)

declare @serviceRecordsToReset as table (
    svcRecID bigint
  , [state] smallint
)

declare @claimsToReset as table (
    CLAIM_ID bigint
  , [STATUS]  char(10)
)

/*###########################################################################
  # Init
  ###########################################################################*/    

set @tranOpen = 0    
set @today        = GETDATE()
set @test         = isnull(@test,1)
set @backfillMode = isnull(@backfillMode,0)

/*###########################################################################
  # Find transmission
  ###########################################################################*/    

set @txID = null

select top 1
    @fileName     = isnull(tra.fileName,'')
  , @generationID = tra.generationID
  , @txID         = tra.Transmission_ID
  , @txDate       = tra.Created_At
  , @claimSource = isnull(tga.claimSource,1) /* Default to 1 */

from      dbo.TRANSMISSION_RECORDS_ALL       as tra
left join dbo.TRANSMISSION_GENERATIONS_ALL   as tga on tga.id = tra.generationID
where (tra.Transmission_ID = @transmissionID)

/*###########################################################################
  # If its not found then get out
  ###########################################################################*/    

if (@txID is null)
begin
  RAISERROR ('Transmission record does not exist', 0, 1) WITH NOWAIT 
  RETURN(0)
end

if (@claimSource not in (1,2))
begin
  RAISERROR ('This tranmission source is not supported by this routine.', 0, 1) WITH NOWAIT 
  RETURN(0)
end

/*###########################################################################
  # Retrieve additional information about the transmission and calculate
  # its age
  ###########################################################################*/    

set @txDateStr = dbo.RPT_DATE_FMT(@txDate)

select 
    @clientName    = tsc.CLIENT_NAME
  , @totNumClmsStr = convert(varchar(50),tsc.TOTAL_NUMBER_CLAIMS)  
from dbo.TRANSMISSION_SUMMARY_BY_CLIENT_837_ALL as tsc
where (tsc.TRANSMISSION_RECORD_ID = @transmissionID)

set @txDaysAgo = DATEDIFF_BIG(day,@txDate,@today)

/*###########################################################################
  # Inform the user about the transmission
  ###########################################################################*/    

set @msg = FORMATMESSAGE ('Transmission file %s generated %I64d days ago on %s for %s containing %s claims !', @fileName, @txDaysAgo, @txDateStr, @clientName, @totNumClmsStr)
RAISERROR (@msg, 0, 1) WITH NOWAIT 

/*###########################################################################
  # See if transmision has already been rolled back.  If so get out.
  ###########################################################################*/    

/*----------------
 * Handles newer
 *----------------*/

if exists (select top 1 trr.TRANSMISSION_ID from dbo.Transmission_Record_Rollbacks as trr where trr.TRANSMISSION_ID = @transmissionID)
begin
  RAISERROR ('This transmission has already been rolled back', 0, 1) WITH NOWAIT 
  RETURN(0)
end

/*----------------
 * Handles older
 *----------------*/

if (@backfillMode = 0)
begin
  if exists (select top 1 tr.Transmission_ID from dbo.Transmission_Records as tr where tr.TRANSMISSION_ID = @transmissionID and tr.UseForBilling = 0)
  begin
    RAISERROR ('This transmission has already been rolled back', 0, 1) WITH NOWAIT 
    RETURN(0)
  end
end

/*###########################################################################
  # Validation warnings 
  ###########################################################################*/    

if ((@test = 1) and (@backfillMode = 1))
begin
  RAISERROR ('** WARNING ** YOU ARE USING BACKFILL MODE.  DO NOT USE THIS MDOE FOR REGULAR ROLLBACKS!!!!!!', 0, 1) WITH NOWAIT 
end

if ((@test = 1) and (@txDaysAgo > 4))
begin
  RAISERROR ('** WARNING ** THIS TRANSMISION WAS GENERATED OVER 4 DAYS AGO.', 0, 1) WITH NOWAIT 
end

/*###########################################################################
  # Look up rollback reason code
  ###########################################################################*/    

if (@backfillMode = 0)
begin
  if not exists (select top 1 ID from dbo.Transmission_Record_Rollback_Reasons as trr where trr.CODE = @reasonCode)
  begin
    RAISERROR ('Invalid reason code.  Please see dbo.Transmission_Record_Rollback_Reasons for a list of valid codes.', 0, 1) WITH NOWAIT
    RETURN(0)
  end
end
else
begin
  set @reasonCode = 299
  set @notes      = 'Backfilled previous rollback data'
end


/*##########################################################################
  # Get all claims that are in this transmission
  ###########################################################################*/ 

insert into @transmissionClaims
select 
    clm.CLAIM_ID 
  , clm.IS_PROXY
  , clm.HAS_PROXY
  , trc.trc_ID
from dbo.Transmission_Record_Claims as trc
join dbo.CLAIM_Claim                as clm on clm.CLAIM_ID = trc.claim_id
where (trc.transmission_id = @transmissionID)

/*##########################################################################
  # Break out stand alone claims
  ###########################################################################*/ 

insert into @standAloneClaims
select
  tc.CLAIM_ID 
from @transmissionClaims as tc
where ((tc.IS_PROXY = 0) and (tc.HAS_PROXY = 0))

/*##########################################################################
  # Get associated service records for the stand alone claims
  ###########################################################################*/ 

insert into @standAloneServiceRecords
select distinct
  src.svcRecID
from @standAloneClaims         as sac
join dbo.SERVICE_RECORD_CLAIMS as src on src.claimID = sac.CLAIM_ID

/*##########################################################################
  # Break out proxy claims (proxy parent)
  ###########################################################################*/ 

insert into @proxyParentClaims
select 
  tc.CLAIM_ID 
from @transmissionClaims as tc
where ((tc.IS_PROXY = 1) and (tc.HAS_PROXY = 0))

/*##########################################################################
  # Get associated proxy child claims (these are not transmitted)
  ###########################################################################*/ 

insert into @proxyChildClaims
select 
    clm.CLAIM_ID
from @proxyParentClaims   as ppc
join dbo.CLAIM_Claim      as clm on clm.REFERENCE_CLAIM_ID_1 = ppc.CLAIM_ID
where
  ((clm.HAS_PROXY = 1) and (clm.IS_PROXY = 0))

/*##########################################################################
  # Get associated service records for the child claims (the proxy claims
  # themselves dont have service records)
  ###########################################################################*/ 

insert into @proxyChildServiceRecords
select distinct
  src.svcRecID
from @proxyChildClaims         as pcc
join dbo.SERVICE_RECORD_CLAIMS as src on src.claimID = pcc.CLAIM_ID

/*###########################################################################
  # Service records we need to reset
  ###########################################################################*/    

insert into @serviceRecordsToReset
select svcRecID, [state] = null from @standAloneServiceRecords
union
select svcRecID, [state] = null from @proxyChildServiceRecords

update srr
  set srr.[state] = sr.[state]
from @serviceRecordsToReset as srr
join dbo.SERVICE_RECORDS    as sr on sr.id = srr.svcRecID

/*###########################################################################
  # Claims we need to reset
  ###########################################################################*/    

insert into @claimsToReset
select 
   CLAIM_ID = clm.CLAIM_ID
 , clm.STATUS
from @serviceRecordsToReset    as srr
join dbo.SERVICE_RECORD_CLAIMS as src on src.svcRecID = srr.svcRecID
join dbo.CLAIM_Claim           as clm on clm.CLAIM_ID = src.claimID

/*###########################################################################
  # Calculate stats
  ###########################################################################*/    

select @numOfStandAloneClaims  = COUNT(*) from @standAloneClaims
select @numOfProxyClaims       = COUNT(*) from @proxyParentClaims
select @numOfSvcRecs           = COUNT(*) from @serviceRecordsToReset
select @numOfSvcRecsStandAlone = COUNT(*) from @standAloneServiceRecords
select @numOfSvcRecsProxied    = COUNT(*) from @proxyChildServiceRecords

set @msg =  FORMATMESSAGE ('This transmission is for %d service records with %d of those as stand alone svcs and %d proxied svcs.', @numOfSvcRecs, @numOfSvcRecsStandAlone, @numOfSvcRecsProxied)
RAISERROR (@msg, 0, 1) WITH NOWAIT 

set @msg =  FORMATMESSAGE ('This transmission contains %d stand alone claims and %d proxy claims.', @numOfStandAloneClaims, @numOfProxyClaims)
RAISERROR (@msg, 0, 1) WITH NOWAIT 

if (@numOfProxyClaims > 0) set @hasProxyClaims = 1

/*###########################################################################
  # Calculate safety checks and exit if any fail
  ###########################################################################*/    

/*----------------
 * No claims
 *----------------*/

select 
    @numClaimsToReset = COUNT(*) 
from @claimsToReset

if (@numClaimsToReset = 0)
begin
  RAISERROR ('Cannot reset this transmission because there are no claims found', 0, 1) WITH NOWAIT 
  RETURN(0)    
end

if (@backfillMode = 0)
begin

  /*----------------
   * Service record
   * states are not
   * properly set
   *----------------*/

  select 
    @numOfSvcRecsNotInState20 = COUNT(*) 
  from @serviceRecordsToReset 
  where ([state] != dbo.CONST_SVC_REC_STATE_SUB())

  if (@numOfSvcRecsNotInState20 !=  0)
  begin
    RAISERROR ('Cannot reset this transmission because some of the service records associated with the claims are not in state 20', 0, 1) WITH NOWAIT 
    RETURN(0)    
  end

  /*----------------
   * Status of claims
   * IN transmission
   * is not properly 
   * set
   *----------------*/

  select 
    @numClaimsNotInStatus2 = COUNT(*) 
  from @transmissionClaims as tc
  join @claimsToReset      as ctr on ctr.CLAIM_ID = tc.CLAIM_ID
  where (ctr.[STATUS] != @clmStatusSent)

  if (@numClaimsNotInStatus2 != 0)
  begin
    RAISERROR ('Cannot reset this transmission because some of the claims have been adjudicated', 0, 1) WITH NOWAIT 
    RETURN(0)    
  end

  
  /*----------------
   * Proxy claims
   * and no child 
   * claims
   *----------------*/

  if (@hasProxyClaims = 1)
  begin
    
	select @numOfProxyChildClaims  = COUNT(*) from @proxyChildClaims
    
	if (@numOfProxyChildClaims = 0)
	begin
      RAISERROR ('Cannot reset this transmission because the child claims for the proxy claims could not be found', 0, 1) WITH NOWAIT 
      RETURN(0)    	
	end

  end

end

/*###########################################################################
  # Exit if we are in test mode
  ###########################################################################*/   

if (@test = 1)
begin
  RAISERROR ('Exiting because this rollback request is in TEST mode', 0, 1) WITH NOWAIT 
  RETURN(0)    
end

/*###########################################################################
  # Rollback
  ###########################################################################*/    

RAISERROR ('Rolling back transmission', 0, 1) WITH NOWAIT 

BEGIN TRANSACTION

set @TranOpen = 1

RAISERROR ('Creating transmission rollback record', 0, 1) WITH NOWAIT 

insert into dbo.Transmission_Record_Rollbacks (
    [TRANSMISSION_ID]
  , [REASON_CODE]
  , [NOTES]
  , [CREATED]
  , [CREATED_BY] 
)
values (
	@transmissionID
  , @reasonCode
  , @notes
  , @today
  , @userID
)

set @transmissionRollbackID = SCOPE_IDENTITY()

RAISERROR ('Updating transmission records', 0, 1) WITH NOWAIT 

update dbo.Transmission_Records
set 
   UseForBilling = 0
 , Transmission_Note = 'Files deleted due to error in 837 build ' + CONVERT(varchar,@today)
where (Transmission_ID = @transmissionID)

RAISERROR ('Updating transmission claim records', 0, 1) WITH NOWAIT 

update dbo.Transmission_Record_Claims
set 
   ACTIVE = 0
where (Transmission_ID = @transmissionID)

RAISERROR ('Archiving transmission records', 0, 1) WITH NOWAIT 

insert into dbo.Transmission_Records_Archive
select 
    TRANSMISSION_ROLLBACK_ID = @transmissionRollbackID
  , tr.* 
from dbo.Transmission_Records as tr
where (tr.Transmission_ID = @transmissionID)

RAISERROR ('Archiving transmission claim records', 0, 1) WITH NOWAIT 

insert into dbo.Transmission_Record_Claims_Archive
select 
    TRANSMISSION_ROLLBACK_ID = @transmissionRollbackID
  , trc.*
from dbo.Transmission_Record_Claims as trc
join @transmissionClaims            as txr on txr.trc_ID = trc.trc_ID
where (trc.transmission_id = @transmissionID)

RAISERROR ('Archiving transmission summary by client records', 0, 1) WITH NOWAIT 

insert into dbo.Transmission_Summary_By_Client_837_Archive
select 
    TRANSMISSION_ROLLBACK_ID = @transmissionRollbackID
  , tsc.*
from dbo.Transmission_Summary_By_Client_837 as tsc
where (tsc.TRANSMISSION_RECORD_ID = @transmissionID)

RAISERROR ('Archiving transmission generation list claims records', 0, 1) WITH NOWAIT 

insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_ARCHIVE
select 
    TRANSMISSION_ROLLBACK_ID = @transmissionRollbackID
  , tglc.*
from dbo.TRANSMISSION_GENERATION_LIST_CLAIMS as tglc
where (tglc.GenerationID = @generationID)

RAISERROR ('Archiving transmission generation list claims held records', 0, 1) WITH NOWAIT 

insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD_ARCHIVE
select 
    TRANSMISSION_ROLLBACK_ID = @transmissionRollbackID
  , tglch.*
from dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD as tglch
where (tglch.GenerationID = @generationID)

RAISERROR ('Archiving transmission generation records', 0, 1) WITH NOWAIT 

insert into dbo.TRANSMISSION_GENERATIONS_ARCHIVE
select 
    TRANSMISSION_ROLLBACK_ID = @transmissionRollbackID
  , tg.*
from dbo.TRANSMISSION_GENERATIONS as tg
where (tg.id = @generationID)

if (@backfillMode = 0)
begin
  if (@hasProxyClaims = 1)
  begin

    RAISERROR ('Rolling back proxy claims', 0, 1) WITH NOWAIT 

    RAISERROR ('Updating proxy claim children claims', 0, 1) WITH NOWAIT 

    update clm
    set 
        clm.HAS_PROXY            = 0
      , clm.IS_PROXY             = 0
      , clm.REFERENCE_CLAIM_ID_1 = null
      , clm.HOLD                 = 0
      , clm.STATUS               = @clmStatusNotSent
    from @proxyChildClaims  as pcc
    join dbo.CLAIM_Claim    as clm on clm.CLAIM_ID = pcc.CLAIM_ID
    where (pcc.CLAIM_ID = clm.CLAIM_ID)
  
    RAISERROR ('Deleting proxy claim parent claims', 0, 1) WITH NOWAIT 

    delete clm
    from @proxyParentClaims as ppc
    join dbo.CLAIM_Claim    as clm on clm.CLAIM_ID = ppc.CLAIM_ID
    where (ppc.CLAIM_ID = clm.CLAIM_ID)
  
  end

  RAISERROR ('Updating all claim records', 0, 1) WITH NOWAIT 

  update clm  
  set 
      clm.STATUS       = @clmStatusNotSent
    , clm.LAST_UPDATED = @today

	/* Decrement counter since we are rolling back */
	, clm.NUMBER_OF_SUBMISSIONS = iif (
	                                 (isnull(clm.NUMBER_OF_SUBMISSIONS, 0) > 0)
								   , (clm.NUMBER_OF_SUBMISSIONS - 1)
								   , 0
								   )
  from @claimsToReset  as ctr
  join dbo.CLAIM_Claim as clm on clm.CLAIM_ID = ctr.CLAIM_ID
  where (ctr.CLAIM_ID = clm.CLAIM_ID)

  RAISERROR ('Updating all service records.', 0, 1) WITH NOWAIT 

  update sr
  set
      sr.state        = dbo.CONST_SVC_REC_STATE_MOD()
    , sr.lastModified = @today
  from @serviceRecordsToReset as srr
  join dbo.SERVICE_RECORDS    as sr on sr.id = srr.svcRecID
    
end

RAISERROR ('Deleting transmission generation list claims records', 0, 1) WITH NOWAIT 
delete dbo.TRANSMISSION_GENERATION_LIST_CLAIMS where (GenerationID = @generationID)

RAISERROR ('Deleting transmission generation list claims held records', 0, 1) WITH NOWAIT 
delete dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD where (GenerationID = @generationID)

RAISERROR ('Deleting transmission generation records', 0, 1) WITH NOWAIT 
delete dbo.TRANSMISSION_GENERATIONS where (id = @generationID)

RAISERROR ('Deleting transmission record claim records', 0, 1) WITH NOWAIT 
delete 
  trc
from dbo.Transmission_Record_Claims as trc
join @transmissionClaims            as txr on txr.trc_ID = trc.trc_ID
where (trc.transmission_id = @transmissionID)

RAISERROR ('Deleting transmission records', 0, 1) WITH NOWAIT 
delete dbo.Transmission_Records where (transmission_ID = @transmissionID)

RAISERROR ('Deleting tranmission summary by client records', 0, 1) WITH NOWAIT 
delete dbo.Transmission_Summary_By_Client_837 where (TRANSMISSION_RECORD_ID = @transmissionID)

RAISERROR ('Deleting Import_From_837 records (these can be regenerated if needed using the UDF Claims_837_Data_Sent_Parse_Into_Text_Columns', 0, 1) WITH NOWAIT 
delete from dbo.Import_From_837 where transmission_id = @transmissionID

COMMIT TRANSACTION    
SET @TranOpen = 0    

RAISERROR ('Rollback complete', 0, 1) WITH NOWAIT 
RETURN(0)    
END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
   if (@ErrorSeverity > 11)    
     SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TRANSMISSION_RECORD_ROLLBACK_FOR_NEW_CLAIM_SOURCES] TO [webuser]
GO

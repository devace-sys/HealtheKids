USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSMISSION_RECORD_ROLLBACK_FOR_CIF_CLAIM_SOURCES') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSMISSION_RECORD_ROLLBACK_FOR_CIF_CLAIM_SOURCES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSMISSION_RECORD_ROLLBACK_FOR_CIF_CLAIM_SOURCES] (
    @userID             BIGINT
  , @transmissionID     BIGINT
  , @reasonCode         BIGINT  
  , @notes              VARCHAR(MAX)
  , @test               BIT
  , @backfillMode       BIT )    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSMISSION_RECORD_ROLLBACK_FOR_CIF_CLAIM_SOURCES */    
/**    
 * Rolls back a transmission for a CIF claim source (3)
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
declare @numClaimsToReset         as int      = 0
declare @txDate                   as datetime       = null
declare @txDateStr                as varchar(50)    = null
declare @clientID                 as bigint         = null
declare @clientName               as varchar(200)   = null
declare @totNumClaims             as int            = 0
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

if (@claimSource not in (3))
begin
  RAISERROR ('This tranmission source is not supported by this routine.', 0, 1) WITH NOWAIT 
  RETURN(0)
end

/*###########################################################################
  # Get additional info
  ###########################################################################*/    


select top 1 @clientID   = tga.clientID from dbo.TRANSMISSION_GENERATIONS_ALL as tga where (tga.id = @generationID)
select top 1 @clientName = isnull(clc.CLIENT_NAME,N'') from dbo.CLIENTS_Client as clc where (clc.CLIENT_ID = @clientID)
select @totNumClaims = isnull(count(trca.claim_id),0) from dbo.TRANSMISSION_RECORD_CLAIMS_ALL as trca where (trca.transmission_id = @transmissionID)
set @totNumClmsStr = convert(varchar(50),@totNumClaims)
set @txDateStr = dbo.RPT_DATE_FMT(@txDate)
set @txDaysAgo = DATEDIFF_BIG(day,@txDate,@today)

/*###########################################################################
  # Inform the user about the transmission
  ###########################################################################*/    

set @msg = FORMATMESSAGE ('Transmission file %s generated %I64d days ago on %s for %s containing %s claims !', @fileName, @txDaysAgo, @txDateStr, @clientName, @totNumClmsStr)
RAISERROR (@msg, 0, 1) WITH NOWAIT 

/*###########################################################################
  # See if transmision has already been rolled back.  If so get out.
  ###########################################################################*/    

if exists (select top 1 trr.TRANSMISSION_ID from dbo.Transmission_Record_Rollbacks as trr where trr.TRANSMISSION_ID = @transmissionID)
begin
  RAISERROR ('This transmission has already been rolled back', 0, 1) WITH NOWAIT 
  RETURN(0)
end


/*###########################################################################
  # Look up rollback reason code
  ###########################################################################*/    

if not exists (select top 1 ID from dbo.Transmission_Record_Rollback_Reasons as trr where trr.CODE = @reasonCode)
begin
  RAISERROR ('Invalid reason code.  Please see dbo.Transmission_Record_Rollback_Reasons for a list of valid codes.', 0, 1) WITH NOWAIT
  RETURN(0)
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


/*###########################################################################
  # Calculate safety checks and exit if any fail
  ###########################################################################*/    

/*----------------
 * No claims
 *----------------*/

select 
    @numClaimsToReset = COUNT(*) 
from @transmissionClaims

if (@numClaimsToReset = 0)
begin
  RAISERROR ('Cannot reset this transmission because there are no claims found', 0, 1) WITH NOWAIT 
  RETURN(0)    
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

/*insert into dbo.Transmission_Summary_By_Client_837_Archive
select 
    TRANSMISSION_ROLLBACK_ID = @transmissionRollbackID
  , tsc.*
from dbo.Transmission_Summary_By_Client_837 as tsc
where (tsc.TRANSMISSION_RECORD_ID = @transmissionID)
*/

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


/* Undo void submissions records */

RAISERROR ('Reverting all related claims_void_submissions', 0, 1) WITH NOWAIT 

update dbo.CIF_REQUESTS_CLAIMS_VOID_SUBMISSIONS
set 
    submitted      = 0
  , submittedOn    = null
  , generationID   = null
  , transmissionID = null
where 
   (generationID = @generationID)

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

GRANT EXECUTE ON  [dbo].[TRANSMISSION_RECORD_ROLLBACK_FOR_CIF_CLAIM_SOURCES] TO [webuser]
GO

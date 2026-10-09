USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_RELEASE_PROCESS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIMS_RELEASE_PROCESS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLAIMS_RELEASE_PROCESS]     
(@today         DATETIME,
 @userID        INT   = 0,    
 @clientID      INT   = null,
 @oldestDOS     DATETIME,
 @newestDOS     datetime,
 @validate      BIT   = 1)    
 
AS    

BEGIN     
    
/***************************************************************************    
 * CLAIMS_RELEASE_PROCESS */    
/**    
 * Processes claims that need to be released.
 * 
 * @param   today           Todays date
 * @param   userID          The userID of who is running this  
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   oldestDOS       Earliest date of service to work with
 * @param   validate        0 = Return counts and process records
 *                          1 = Just return counts
 ***************************************************************************/         

SET NOCOUNT ON    
    
DECLARE @recCount        AS INT  
DECLARE @standAloneCount as INT 
DECLARE @proxyCount      as INT 
DECLARE @msg             AS VARCHAR(1000)
  
/*-------------------------------
 * Table variable to hold
 * claims to release
 *------------------------------*/

declare @claimsToRelease as table (
  idx bigint identity(1,1)
, clientID bigint
, dos datetime
, patID bigint
, svcType int
, minBased bit
, mileBased bit
, procID1 bigint
, procID2 bigint
, min_units_1 int
, max_units_1 int
, totNumMinsExpd int
, totNumTripsExpd int
, totNumSvcsExpd  int
, client_name varchar(500)
, patient_name varchar(500)
, minEntryDateTime datetime
, maxEntryDateTime datetime
, totNumSvcRecs int
, totNumEnteredBySBSC int
, totNumEnteredByClient int
, totNumMinsRecv int
, totNumTripsRecv int
, totNumMilesRecv decimal (7,1)
, totNumUnitsRecv1 int
, totNumUnitsRecv2 int
, svcRecIDStrs nvarchar(max)
, clmID1Strs nvarchar(max)
, clmID2Strs nvarchar(max)
, Proxy_Send_Override int
, UseOrLoseStatus int
, ServiceAgeInMonths int
, MinEntryAgeInDays int
, MaxEntryAgeInDays int
, AllEnteredBySBSC int
, AllEnteredByClient int
, EnteredToday int
, EnteredAtLeast45DaysAgo int
, RecvMaxUnits int
, RecvExpdMins int
, RecvExpdTrips int
, RecvExpdSvcs  int
, PrefServiceReceived int
, UnitLimitReached int
, HoldUntilNextTrans int
, HoldLimitsReached int
, Sendable int
, ProxyNeeded int

UNIQUE CLUSTERED (
    Sendable
   ,ProxyNeeded
   ,MinBased
   ,MileBased
   ,idx
)

)
  
/*-------------------------------
 * Table variable to hold
 * service/claim data to proxy
 *------------------------------*/
 
declare @toProxy as table (
    idx              INT IDENTITY(1,1) 
  , clientID         INT
  , patID            INT  
  , dos              DATETIME
  , entryDate        DATETIME
  , totNumSvcRecs    INT
  , totNumSvcMins    INT
  , totNumSvcTrips   INT
  , totNumSvcMiles   INT
  , procID1          BIGINT
  , procID2          BIGINT
  , totNumUnits1     INT
  , totNumUnits2     INT
  , svcRecIDsStr     VARCHAR(1000)
  , clmRecIDs1Str    VARCHAR(1000)
  , clmRecIDs2Str    VARCHAR(1000)
  , proxyClaimID1    BIGINT
  , proxyClaimID2    BIGINT
  UNIQUE CLUSTERED (idx)
)  

BEGIN TRY    
    
SET @msg             = ''
select top 1 @msg = CLIENT_NAME from dbo.CLIENTS_CLIENT   as clc where clc.CLIENT_ID  = @clientID
RAISERROR (@msg, 0, 1) WITH NOWAIT 

/*============================================================
 * Starting
 *============================================================*/  

RAISERROR ('Releasing claims', 0, 1) WITH NOWAIT    

SET @recCount        = 0    
SET @standAloneCount = 0
SET @proxyCount      = 0
SET @msg             = ''


/*============================================================
 * Get claims that are being held or will be held
 *============================================================*/  

RAISERROR ('Determining how many claims need to be released', 0, 1) WITH NOWAIT
insert into @claimsToRelease
select * from dbo.CLAIMS_TO_RELEASE_VIEW_CORE (@clientID, @oldestDOS, @newestDOS, @today)

/*============================================================
 * Get counts
 *============================================================*/  

/*-------------------------------
 * Total held
 *------------------------------*/

SET @recCount = 0
SELECT @recCount = isnull(sum(totNumSvcRecs),0) from @claimsToRelease
SET @msg = 'There are ' + CONVERT(varchar(50),@recCount) + ' services that are being held or waiting for aggreg'
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*-------------------------------
 * Not ready for release
 *------------------------------*/
 
SET @recCount = 0
SELECT @recCount = isnull(sum(totNumSvcRecs),0) from @ClaimsToRelease where Sendable = 0
SET @msg = 'There are ' + CONVERT(varchar(50),@recCount) + ' services not ready for release yet'
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*-------------------------------
 * Ready for release
 *------------------------------*/

SET @recCount = 0
SELECT @recCount = isnull(sum(totNumSvcRecs),0) from @ClaimsToRelease where Sendable = 1
SET @msg = 'There are ' + CONVERT(varchar(50),@recCount) + ' services that are ready to be released or aggregated'
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*============================================================
 * If there are no records, get out
 *============================================================*/   

IF (@recCount = 0) 
BEGIN
  RAISERROR ('Nothing to do.', 0, 1) WITH NOWAIT
  GOTO getout
END

/*============================================================
 * Otherwise continue getting counts
 *============================================================*/   

/*-------------------------------
 * Ready for release - as is
 *------------------------------*/

set @standAloneCount = 0
SELECT @standAloneCount = isnull(sum(totNumSvcRecs),0) from @claimsToRelease where Sendable = 1 and ProxyNeeded = 0
SET @msg = CONVERT(varchar(50),@standAloneCount) + ' of these services that can be released as is'
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*-------------------------------
 * Ready for release - proxy
 *------------------------------*/
 
SET @proxyCount = 0
SELECT @proxyCount = isnull(sum(totNumSvcRecs),0) from @claimsToRelease where Sendable = 1 and ProxyNeeded = 1
SET @msg = CONVERT(varchar(50),@proxyCount) + ' of these services require proxy claims'
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*============================================================
 * If we are validating get out
 *============================================================*/   
 
IF (@validate = 1)
BEGIN
  GOTO getout
END

/*============================================================
 * Release claims
 *============================================================*/  
    
/*-------------------------------
 * Release claims that do not
 * require a proxy.
 *
 * These will be handled by the
 * 837 routine as if nothing
 * happened.
 *------------------------------*/
    
IF (@standAloneCount > 0)
BEGIN
    
  /*-------------------------------
   * Set hold flag to 0.  The 837
   * routine should pick these up.
   *------------------------------*/

  RAISERROR ('Releasing stand alone claims', 0, 1) WITH NOWAIT
    
  /*--------------------------------------
   * Service Record Claim 1
   *-------------------------------------*/       
  
  update dbo.CLAIM_Claim
  set 
    LAST_UPDATED = @today,
    HOLD         = 0  
  where CLAIM_ID in (
    select 
      convert(bigint,clmID1Strs) as CLAIM_ID 
    from @claimsToRelease 
    where ( 
          (Sendable    = 1) 
      and (ProxyNeeded = 0)
      and (clmID1Strs != '')
    )
  )
    
  /*--------------------------------------
   * Service Record Claim 2
   *-------------------------------------*/       
  
  update dbo.CLAIM_Claim
  set 
    LAST_UPDATED = @today,
    HOLD         = 0
  where CLAIM_ID in (
    select 
      convert(bigint,clmID2Strs) as CLAIM_ID 
    from @claimsToRelease 
    where (
          (Sendable    = 1)
      and (ProxyNeeded = 0)
      and (clmID2Strs != '')
    )
  )
    
END -- Stand alone
    
/*-------------------------------
 * Create proxy claims for
 * claims that require a proxy
 * These are brand new claims 
 * that will get picked up by
 * the 837.
 *------------------------------*/

IF (@proxyCount > 0)
BEGIN

  /*-------------------------------
   * Get data we need to create 
   * proxy claims
   *------------------------------*/

  RAISERROR ('Creating proxy claims', 0, 1) WITH NOWAIT  

           
  insert into @toProxy    
  select     
     clientID
   , patID
   , dos
   , entryDate = maxEntryDateTime
   , totNumSvcRecs
   , totNumSvcMins = totNumMinsRecv  
   , totNumSvcTrips = totNumTripsRecv
   , totNumSvcMiles = totNumMilesRecv
   , procID1        = procID1
   , procID2        = procID2
   , totNumUnits1 = totNumUnitsRecv1
   , totNumUnits2 = totNumUnitsRecv2
   , svcRecIDStrs
   , clmRecIDs1Str = clmID1Strs
   , clmRecIDs2Str = clmID2Strs
   , null
   , null

  from @claimsToRelease
     
  where (
        (Sendable    = 1) 
    and (ProxyNeeded = 1)
  )
  
  /*-------------------------------
   * Loop through this data set
   *------------------------------*/

  declare @minIdx as int 
  declare @maxIdx as int
  declare @curIdx as int
  
  select @minIdx = MIN(idx) from @toProxy
  select @maxIdx = MAX(idx) from @toProxy
  set @curIdx = @minIdx
  
  
  while (@curIdx <= @maxIdx)
  begin  
       
    
    declare @cltID          INT
    declare @patID          INT
    declare @dos            DATETIME
    declare @entryDate      DATETIME

    declare @totNumSvcRecs  INT
    declare @totNumSvcMins  INT
    declare @totNumSvcTrips INT
    declare @totNumSvcMiles INT

    declare @procID1        BIGINT  
    declare @procID2        BIGINT
    declare @totNumUnits1   INT
    declare @totNumUnits2   INT

    declare @svcRecIDsStr   VARCHAR(1000)
    declare @clmRecIDs1Str  VARCHAR(1000)   
    declare @clmRecIDs2Str  VARCHAR(1000)
    declare @proxyClmRecID1 bigint = null
    declare @proxyClmRecID2 bigint = null
    
    /* Fetch record */
       
    select top 1 
    
        @cltID     = clientID
      , @patID     = patID
      , @dos       = dos
      , @entryDate = entryDate
     
      , @totNumSvcRecs = totNumSvcRecs
      , @totNumSvcMins = totNumSvcMins
      , @totNumSvcTrips = totNumSvcTrips
      , @totNumSvcMiles = totNumSvcMiles
      , @procID1        = procID1
      , @procID2        = procID2
      , @totNumUnits1   = totNumUnits1
      , @totNumUnits2   = totNumUnits2
      , @svcRecIDsStr   = svcRecIDsStr
      , @clmRecIDs1Str  = clmRecIDs1Str
      , @clmRecIDs2Str  = clmRecIDs2Str
    
    from @toProxy
    where 
      (idx = @curIdx)
                   
    /* Create proxy */
       
    exec dbo.CLAIMS_PROXY_CREATE 
        @curIdx
      , @maxIdx
      , @today
      , @userID
      , @cltID
      , @patID  
      , @dos
      , @entryDate
     
      , @totNumSvcRecs
      , @totNumSvcMins
      , @totNumSvcTrips
      , @totNumSvcMiles
      , @procID1
      , @procID2 
      , @totNumUnits1
      , @totNumUnits2
      , @svcRecIDsStr
      , @clmRecIDs1Str
      , @clmRecIDs2Str
      , @proxyClmRecID1 OUTPUT
      , @proxyClmRecID2 OUTPUT
      
            
      /* Next record to get */
      
      set @curIdx = @curIdx + 1  
     
    END -- loop    
  END   -- proxy
    
/*============================================================
 * Early exit point
 *============================================================*/    

getout:

/*============================================================
 * Done
 *============================================================*/  

RAISERROR ('Done', 0, 1) WITH NOWAIT

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
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CLAIMS_RELEASE_PROCESS] TO [webuser]
GO

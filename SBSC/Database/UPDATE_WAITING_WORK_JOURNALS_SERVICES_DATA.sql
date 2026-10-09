USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.UPDATE_WAITING_WORK_JOURNALS_SERVICES_DATA') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.UPDATE_WAITING_WORK_JOURNALS_SERVICES_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[UPDATE_WAITING_WORK_JOURNALS_SERVICES_DATA]  
AS    

BEGIN     
    
/***************************************************************************    
 * UPDATE_WAITING_WORK_JOURNALS_SERVICES_DATA */    
/**    
 * 
 ***************************************************************************/         

SET NOCOUNT ON        

declare @today              as datetime
declare @startDateDOS       as datetime
declare @endDateDOS         as datetime

BEGIN TRY

/*============================================================
 * Get service date range
 *============================================================*/  

set @today        = GETDATE()
set @startDateDOS = dbo.CALC_OLDEST_DOS_ALLOWED(@today)
set @endDateDOS   = @today

/*============================================================
 * Drop indexes
 *============================================================*/  

RAISERROR ('Droping indexes on WAITING_SERVICES_DATA_TEMP', 0, 1) WITH NOWAIT

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'RPT_MISSING_ORP_DETAILS')
DROP INDEX [RPT_MISSING_ORP_DETAILS] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'RepNameClientNameDosMYUseLoseIdx')
DROP INDEX [RepNameClientNameDosMYUseLoseIdx] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'IEP_NAME_ID_IDX')
DROP INDEX [IEP_NAME_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'GROUP_ID_IDX')
DROP INDEX [GROUP_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'CLIENT_ID_IDX')
DROP INDEX [CLIENT_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'PROC_ID_IDX')
DROP INDEX [PROC_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'LAST_TX_GEN_ID_CLAIM_ID_IDX')
DROP INDEX [LAST_TX_GEN_ID_CLAIM_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'USER_ID_IDX')
DROP INDEX [USER_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'PAT_ID_CLIENT_ID_IDX')
DROP INDEX [PAT_ID_CLIENT_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'PRAC_ID_CLIENT_ID_IDX')
DROP INDEX [PRAC_ID_CLIENT_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'SVC_TYPE_STATUS_IDX')
DROP INDEX [SVC_TYPE_STATUS_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'SVC_REC_ID_CLIENT_ID_IDX')
DROP INDEX [SVC_REC_ID_CLIENT_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP]') AND name = N'IDX')
DROP INDEX [IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] WITH ( ONLINE = OFF )



/*============================================================
 * Truncate data temp tables
 *============================================================*/  

RAISERROR ('Truncating WAITING_JOURNALS_DATA_TEMP', 0, 1) WITH NOWAIT
truncate table dbo.WAITING_JOURNALS_DATA_TEMP

RAISERROR ('Truncating WAITING_SERVICES_DATA_TEMP', 0, 1) WITH NOWAIT
truncate table dbo.WAITING_SERVICES_DATA_TEMP

/*============================================================
 * Get all active client data
 *============================================================*/  

RAISERROR ('Get all active client data', 0, 1) WITH NOWAIT

declare @clients as table (
   CLIENT_ID                       bigint
  ,CLIENT_NAME                     nvarchar(256)
  ,REP_NAME                        nvarchar(256)
  ,REP_EMAIL                       nvarchar(256)
  ,APPROVED_837                    bit
  ,APPROVED_835                    bit
  ,TCM_RATE                        nvarchar(15)
  ,HOLD_CLIENT_WORK_FOR_DAYS       int
  ,CLIENT_CLAIM_TCM                bit
  ,CLIENT_CLAIM_NO_PLAN            bit
  ,CLIENT_PARENT_CONSENT_AGREEMENT bit
  ,LAST_TRANSMISSION_GENERATION_ID bigint
  ,LAST_TRANSMISSION_DATETIME      datetime
  ,REP_ID                          bigint
  ,PRE_TRANSMISSION_HOLD_REASONS   varchar(1000)
  UNIQUE CLUSTERED (CLIENT_ID)
)
insert into @clients
select *,'' as PRE_TRANSMISSION_HOLD_REASONS from dbo.CLIENTS_Client_Active_LEA

update @clients
  set PRE_TRANSMISSION_HOLD_REASONS = 'Client approved 837 or 835 are set to No'
where (APPROVED_837 = 0) or (APPROVED_835 = 0)

/*============================================================
 * Get input batch file upload cross ref
 *============================================================*/  

RAISERROR ('Getting input batch file upload cross ref', 0, 1) WITH NOWAIT
declare @inputBatchFileUploads as table (
    inputBatchID    bigint
  , uploadID        bigint
  , idx             bigint identity(1,1)
  unique clustered (inputBatchID, uploadID, idx)
)
insert into @inputBatchFileUploads
select 
    inputBatchID
  , uploadID
from dbo.FILE_UPLOAD_ID_INPUT_BATCH_ID_XREF(null)

/*============================================================
 * Get new data for journals
 *============================================================*/  

RAISERROR ('Repopulating WAITING_JOURNALS_DATA_TEMP', 0, 1) WITH NOWAIT
insert into dbo.WAITING_JOURNALS_DATA_TEMP
select 
    idx  = ROW_NUMBER() over (order by sj.clientID, sj.dos, sj.id)
  , sj.clientID
  , clientName = clc.CLIENT_NAME
  , repName    = clc.REP_NAME
  , REP_EMAIL  = clc.REP_EMAIL
  , sj.dos
  , dosMonthYear = null
  , dosAgeInDays = null
  , dosUseOrLose = null
  , svcJournalID = sj.id
  , lastModified          = coalesce(sj.lastModified, sj.created)
  , lastModifiedAgeInDays = null
  , patID                 = sj.patID
  , patName               = null
  , patBIC                = null
  , sjee.numOfEntries
  , sjsr.numSvcRecs
  , sjrv.numRevs
  , acl.autoCloseLogID   
  , acl.completedCloseOn
  , acl.statusMsg
  , acl.retState         
  , acl.errorMessage 
  , startDateDOS                  = @startDateDOS
  , endDateDOS                    = @endDateDOS
  , todaysDateTime                = @today
      
from @clients                      as clc 
join dbo.SvcJournals               as sj  on  sj.clientID    = clc.CLIENT_ID
    
outer apply (
  select 
    COUNT (ee.id) as numOfEntries
  from dbo.SvcJournal_Event_Entries as ee
  where 
    (ee.journalID = sj.id)
  group by 
    ee.journalID
) as sjee

outer apply (
  select 
    COUNT (sr.id) as numSvcRecs
  from dbo.SvcJournal_Service_Records as sr
  where 
    (sr.journalID = sj.id)
  group by 
    sr.journalID
) as sjsr
  
outer apply (
  select 
    count (revisionID) as numRevs
  from dbo.SvcJournals_Revisions as rv
  where 
   (rv.id = sj.id)
  group by 
    rv.id
) as sjrv
  
cross apply (
  select top 1 
     ac.id as autoCloseLogID
   , ac.startedCloseOn
   , ac.statusMsg 
   , ac.retState
   , ac.errorMessage
   , ac.completedCloseOn
  from dbo.SvcJournal_Auto_Close_Log as ac
  where (ac.journalID = sj.id)
  order by 
      ac.startedCloseOn desc
    , ac.id desc
) as acl

where (
      (sj.active    = 1)
  and (sj.completed = 0)    
  and (sj.dos between @startDateDOS and @endDateDOS)
)

/*============================================================
 * Get new data for services
 *============================================================*/  

RAISERROR ('Repopulating WAITING_SERVICES_DATA_TEMP', 0, 1) WITH NOWAIT
insert into dbo.WAITING_SERVICES_DATA_TEMP
select    
	  idx = ROW_NUMBER() over (order by sr.clientID, sr.dos, sr.id, cc.CLAIM_ID)
	, sr.clientID        
	, clientName     = null
	, repName        = null
	, repEmail       = null
	, sr.dos             
	, dosMonthYear  = null
     , dosAgeInDays = null
     , dosUseOrLose = null
	, sr.id as svcRecID       
	, svcRecState = sr.state 
     , cc.CLAIM_ID    
	, sr.userID
	, userName           = null
	, userEmail          = null
	, userIsPcalStaff    = null 
	, inputBatchID       = null
     , inputBatchParentID = null 
     , fileUploadID       = null  
	, sr.reference       
	, sr.entryType       
	, created                      = coalesce(sr.lastModified, sr.created)	    
     , createdAgeInDays             = null
	, createdDaysBeforeAfterLastTx = null
	, sr.pracID 
	, pracName = ''
	, sr.groupID         
	, groupName = ''
	, sr.patID
	, patName = ''
	, patBic  = ''
	, sr.planType        
	, sr.isIFSPorIEP     
	, sr.svcType         
	, sr.nameID          
	, svcName = null
	, sr.numMins        
	, numTrips = 0
	, numMiles = 0
	, sr.trip1Start     
	, sr.trip1End       
	, sr.trip2Start     
	, sr.trip2End       
	, sr.trip3Start     
	, sr.trip3End       
	, sr.trip4Start     
	, sr.trip4End        
	, sr.hasSvcDetFlags  
	, sr.svcDetFlag1     
	, sr.svcDetFlag2     
	, sr.svcDetFlag3     
	, sr.svcDetFlag4     
	, sr.orpRequired     
	, sr.hasOrpDocID     
	, sr.orpDocID        
	, sr.orpPracID       
	, sr.orpPracNPI      
	, sr.orpValidMcalOrp        
	, svcOrpStatus = null
     , cc.REFERENCE_CLAIM_ID_1
     , cc.REFERENCE_CLAIM_ID_2
     , cc.SERVICE_UNITS   
     , cc.PROCEDURE_ID
     , PROCEDURE_NAME = null
     , PROC_MOD_COMBO = null    
     , PROCEDURE_NOT_BILLABLE = null
     , cc.STATUS
     , cc.HOLD  
     , clc.TCM_RATE
     , REIMBURSE_ESTIMATE = null
     , clc.LAST_TRANSMISSION_DATETIME 
     , clc.LAST_TRANSMISSION_GENERATION_ID
     , LAST_TRANSMISSION_HOLD_REASON = null
     , PRE_TRANSMISSION_HOLD_REASONS = ''  
     , startDateDOS                  = @startDateDOS
     , endDateDOS                    = @endDateDOS
     , todaysDateTime                = @today
     , pracGroupFamilyName           = null
     , holdreason                    = null
     , REP_ID                        = clc.REP_ID  
       
from      @clients                        as clc
join      dbo.SERVICE_RECORDS             as sr  on  sr.clientID = clc.CLIENT_ID
                                                 and sr.dos between @startDateDOS and @endDateDOS
                                                 and (sr.state not in (99,199))
join      dbo.SERVICE_RECORD_CLAIMS       as src  on  src.svcRecID    = sr.id
join      dbo.CLAIM_Claim                 as cc   on  cc.CLAIM_ID     = src.claimID

where(       
      (cc.STATUS in ('1','12'))
  and (cc.SERVICE_UNITS != 0)
)

/*============================================================
 * Recreate indexes
 *============================================================*/  

RAISERROR ('Recreating indexes on WAITING_SERVICES_DATA_TEMP', 0, 1) WITH NOWAIT

CREATE UNIQUE NONCLUSTERED INDEX [IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [PROC_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[PROCEDURE_ID] ASC,
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [SVC_TYPE_STATUS_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[svcType] ASC,
	[STATUS] ASC,
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


CREATE UNIQUE NONCLUSTERED INDEX [SVC_REC_ID_CLIENT_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[svcRecID] ASC,
	[clientID] ASC,
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


CREATE UNIQUE NONCLUSTERED INDEX [LAST_TX_GEN_ID_CLAIM_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[LAST_TRANSMISSION_GENERATION_ID] ASC,
	[CLAIM_ID] ASC,
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


CREATE UNIQUE NONCLUSTERED INDEX [USER_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[userID] ASC,
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


CREATE UNIQUE NONCLUSTERED INDEX [PRAC_ID_CLIENT_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[pracID] ASC,
	[clientID] ASC,
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


CREATE UNIQUE NONCLUSTERED INDEX [PAT_ID_CLIENT_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[patID] ASC,
	[clientID] ASC,
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [CLIENT_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[clientID] ASC,
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [GROUP_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[groupID] ASC,
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [IEP_NAME_ID_IDX] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[isIFSPorIEP] ASC,
	[nameID] ASC,
	[idx] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

/*============================================================
 * Removing all proxy child records for all services except
 * transportation.  This handles cases where we have sent but
 * not yet adjudicated claims.
 *============================================================*/  

RAISERROR ('Deleting non transportation proxy child records from WAITING_SERVICES_DATA_TEMP.', 0, 1) WITH NOWAIT
delete dbo.WAITING_SERVICES_DATA_TEMP 
where ((svcType != 3) and (STATUS != '1'))

/*============================================================
 * Removing all proxy child records for transporation where
 * parent records have been sent.
 *
 * All proxy child records left after this should just be
 * ones that have not been sent.
 *============================================================*/  

RAISERROR ('Deleting transportation proxy child records from WAITING_SERVICES_DATA_TEMP where proxy has been sent.', 0, 1) WITH NOWAIT
delete
  t1
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join dbo.CLAIM_Claim                as pc on pc.CLAIM_ID = t1.REFERENCE_CLAIM_ID_1
where 
(     (t1.svcType = 3) 
  and (t1.STATUS = '12') 
  and (pc.STATUS = '2')
)

/*============================================================
 * Compute trips and miles.
 * Note numTrips and numMiles was set to 0 prior to this
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with trips and miles computations', 0, 1) WITH NOWAIT
update dbo.WAITING_SERVICES_DATA_TEMP
set  
  numTrips = dbo.CALC_TOTAL_TRIPS_8 ( trip1Start
                                     , trip1End
                                     , trip2Start
                                     , trip2End   
                                     , trip3Start   
                                     , trip3End   
                                     , trip4Start  
                                     , trip4End )    
    
, numMiles = dbo.CALC_TOTAL_MILES_8 (  trip1Start
                                      , trip1End
                                      , trip2Start
                                      , trip2End   
                                      , trip3Start   
                                      , trip3End   
                                      , trip4Start  
                                      , trip4End )   
where (svcType = 3)

/*============================================================
 * Compute ORP compliance status
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with ORP compliance status', 0, 1) WITH NOWAIT
update dbo.WAITING_SERVICES_DATA_TEMP
set   
  svcOrpStatus = dbo.RPT_DETERMINE_ORP_STATUS (   orpRequired
                                                , orpDocID
                                                , orpPracID
                                                , orpPracNPI
                                                , orpValidMcalOrp )

/*============================================================
 * Get work batch data
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with work batch data', 0, 1) WITH NOWAIT
update 
  t1
 set
    t1.inputBatchID       = ibsr.inputBatchID 
  , t1.inputBatchParentId = ibsr.inputBatchParentID 
  , t1.fileUploadID       = fur.uploadID 
from      dbo.WAITING_SERVICES_DATA_TEMP    as t1
join      dbo.INPUT_BATCHES_SERVICE_RECORDS as ibsr on ibsr.svcRecID = t1.svcRecID
left join @inputBatchFileUploads            as fur  on fur.inputBatchID = ibsr.inputBatchID


/*============================================================
 * Get last transmission hold status
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with last transmission hold status', 0, 1) WITH NOWAIT
update 
  t1
set
    t1.LAST_TRANSMISSION_HOLD_REASON = lch.holdReason  
from dbo.WAITING_SERVICES_DATA_TEMP               as t1
join dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD as lch  on  lch.GenerationID = t1.LAST_TRANSMISSION_GENERATION_ID
                                                          and lch.ClaimID      = t1.CLAIM_ID

/*===========================================================
 * Update transport proxy child claims hold status
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP transport proxy child claims hold status where parent has not been tx', 0, 1) WITH NOWAIT
update 
  t1
set 
  t1.LAST_TRANSMISSION_HOLD_REASON = tglch.holdReason
, t1.LAST_TRANSMISSION_DATETIME    = tglch.dateCreated
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join dbo.CLAIM_Claim                as pc on pc.CLAIM_ID = t1.REFERENCE_CLAIM_ID_1
cross apply (
  select top 1 
      ch.holdReason
    , tg.dateCreated
  from dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD as ch 
  join dbo.TRANSMISSION_GENERATIONS                 as tg on tg.id = ch.GenerationID
                                                          and tg.clientID = t1.clientID
  where (ch.ClaimID = pc.CLAIM_ID)
  order by 
    ch.id desc
) as tglch
where ((t1.svcType = 3) and (t1.STATUS = '12') and (t1.LAST_TRANSMISSION_HOLD_REASON is null) and (pc.STATUS = 1))
                                          
/*============================================================
 * Replace transmission ORP compliance hold reason with
 * more detailed reason
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP records that have tx hold because of ORP comp with more detailed msg', 0, 1) WITH NOWAIT
update dbo.WAITING_SERVICES_DATA_TEMP
set LAST_TRANSMISSION_HOLD_REASON = svcOrpStatus
where LAST_TRANSMISSION_HOLD_REASON = 'Claim is not ORP compliant' 

/*===========================================================
 * Reseting records that have no tx hold status
 *============================================================*/  
 
RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP records that have no tx hold status', 0, 1) WITH NOWAIT
update dbo.WAITING_SERVICES_DATA_TEMP 
set 
  LAST_TRANSMISSION_GENERATION_ID = null
, LAST_TRANSMISSION_DATETIME      = null
where (LAST_TRANSMISSION_HOLD_REASON is null)

/*===========================================================
 * Get user data
 *==========================================================*/  

declare @UsersData as table (
    USER_ID            bigint
  , USER_NAME          nvarchar(256)
  , USER_EMAIL         nvarchar(256)
  , USER_IS_PCAL_STAFF bit
  unique clustered (USER_ID)
)

insert into @UsersData
select distinct
     USER_ID            = u.userrid 
   , USER_NAME          = u.UserName
   , USER_EMAIL         = m.Email
   , USER_IS_PCAL_STAFF = m.SBSC_Employee
from dbo.WAITING_SERVICES_DATA_TEMP   as t1
join  users.dbo.Users                 as u    on  u.userrid           = t1.userID
join  users.dbo.Membership            as m    on  m.UserId            = u.UserId

/*===========================================================
 * Update WAITING_SERVICES_DATA_TEMP with user data
 *==========================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with user data', 0, 1) WITH NOWAIT
update
  t1
set  
    t1.userName        = ud.USER_NAME
  , t1.userEmail       = ud.USER_EMAIL
  , t1.userIsPcalStaff = ud.USER_IS_PCAL_STAFF
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @UsersData as ud on ud.USER_ID = t1.userID

/*===========================================================
 * Update WAITING_SERVICES_DATA_TEMP with client data
 *==========================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with client info', 0, 1) WITH NOWAIT
update t1
set 
  t1.clientName = clc.CLIENT_NAME
  ,t1.repName   = clc.REP_NAME
  ,t1.repEmail  = clc.REP_EMAIL
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @clients  as clc on clc.CLIENT_ID = t1.clientID

/*===========================================================
 * Getting practitioner data
 *==========================================================*/  

RAISERROR ('Getting practitioner data', 0, 1) WITH NOWAIT

declare @PractitionersData as table (
    PRACTITIONER_ID     bigint
  , CLIENT_ID           bigint
  , CONCAT_NAME         nvarchar(100)  
  , SUBMIT_CLAIMS       bit
  , CLAIM_TCM           bit
  , PRE_TRANSMISSION_HOLD_REASONS        varchar(1000)
  unique clustered (PRACTITIONER_ID)
)

insert into @PractitionersData
select distinct
    prp.PRACTITIONER_ID
  , t1.clientID as CLIENT_ID
  , prp.CONCAT_NAME
  , prp.SUBMIT_CLAIMS
  , prp.CLAIM_TCM  
  , PRE_TRANSMISSION_HOLD_REASONS = ''
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = t1.pracID

/*===========================================================
 * Get basic group data
 *============================================================*/  

RAISERROR ('Getting basic group data', 0, 1) WITH NOWAIT
declare @GroupData as table (
    GROUP_ID     bigint
  , GROUP_NAME   varchar(512)
  , pracGroupFamilyName varchar(512)
  unique clustered (GROUP_ID)
)

insert into @GroupData
select distinct 
    gg.GROUP_ID
  , gg.GROUP_NAME
  , gd.GROUP_SERVICE_CLASS_NAME 
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join dbo.GROUP_Group                                             as gg on gg.GROUP_ID = t1.groupID
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA  as gd on gd.GROUP_ID = gg.GROUP_ID
where (gd.GROUP_SERVICE_CLASS_PARTITION_ID = 100)

/*===========================================================
 * Get patient data
 *============================================================*/  

RAISERROR ('Getting patient data', 0, 1) WITH NOWAIT
declare @PatientsData as table (
    PATIENT_ID          bigint
  , CLIENT_ID           bigint
  , CONCAT_NAME         nvarchar(100)  
  , BIC                 nvarchar(14)
  , BIC_LEN             int
  , SUBMIT_CLAIMS       bit
  , parentConsentMcal   bit
  , PRE_TRANSMISSION_HOLD_REASONS        varchar(1000)
  unique clustered (PATIENT_ID)
)
insert into @PatientsData
select distinct
   pap.PATIENT_ID
  ,t1.clientID as CLIENT_ID
  ,pap.CONCAT_NAME
  ,BIC = ltrim(rtrim(isnull(pap.BIC,'')))
  ,BIC_LEN = null
  ,pap.SUBMIT_CLAIMS
  ,pap.parentConsentMcal
  ,PRE_TRANSMISSION_HOLD_REASONS = ''
from 
(
        select distinct clientID, patID from dbo.WAITING_SERVICES_DATA_TEMP 
  union select distinct clientID, patID from dbo.WAITING_JOURNALS_DATA_TEMP
) as t1
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = t1.patID

RAISERROR ('Determine possible pre transmission hold reasons for each patient', 0, 1) WITH NOWAIT
update @PatientsData set BIC_LEN = LEN(BIC)

update @PatientsData 
set PRE_TRANSMISSION_HOLD_REASONS = 'Patient has no BIC' 
where BIC_LEN = 0

update @PatientsData 
set PRE_TRANSMISSION_HOLD_REASONS = 'Patient has an invalid BIC' 
where BIC_LEN between 1 and 13

/*===========================================================
 * Get procedure data
 *============================================================*/  

RAISERROR ('Getting procedure data and billing status', 0, 1) WITH NOWAIT

declare @ProcedureData as table (
     PROCEDURE_ID            bigint
   , PROCEDURE_NAME          nvarchar(50)
   , PROC_MOD_COMBO          varchar(50)
   , MIN_UNITS               nchar(10)
   , MAX_UNITS               nchar(10)
   , SERVICE_FEE             numeric(18,12)
   , TCM_LOW_RATE            nchar(10)
   , TCM_MEDIUM_RATE         nchar(10)
   , TCM_HIGH_RATE           nchar(10)     
   , PROCEDURE_NOT_BILLABLE  bit
   , WAITING_FOR_SPA         bit
   unique clustered (PROCEDURE_ID)
 )

insert into @ProcedureData
select distinct
       t1.PROCEDURE_ID     
     , cp.PROCEDURE_NAME
     , PROC_MOD_COMBO = dbo.RPT_PROC_MOD_COMBO (  cp.PROCEDURE_CODE
                                                , cp.PROCEDURE_MODIFIER_1
                                                , cp.PROCEDURE_MODIFIER_2
                                                , cp.PROCEDURE_MODIFIER_3
                                                , cp.PROCEDURE_MODIFIER_4 )
     , cp.MIN_UNITS
     , cp.MAX_UNITS
     , cp.SERVICE_FEE
     , cp.TCM_LOW_RATE
     , cp.TCM_MEDIUM_RATE
     , cp.TCM_HIGH_RATE     
     , PROCEDURE_NOT_BILLABLE = null
     , WAITING_FOR_SPA        = null
from dbo.WAITING_SERVICES_DATA_TEMP   as t1
join dbo.CLAIM_Procedures             as cp   on  cp.PROCEDURE_ID = t1.PROCEDURE_ID

update pd
  set pd.PROCEDURE_NOT_BILLABLE = 0
from @ProcedureData                       as pd 
join dbo.CLAIM_PROCEDURES_TRANSMITTABLE() as cpt on cpt.PROCEDURE_ID = pd.PROCEDURE_ID
where (pd.PROCEDURE_NOT_BILLABLE is null)

update @ProcedureData
  set PROCEDURE_NOT_BILLABLE = 1
where PROCEDURE_NOT_BILLABLE is null

/*===========================================================
 * Is procedure possibly in the spa
 *============================================================*/  

update @ProcedureData set WAITING_FOR_SPA = 0 

update pd
    set pd.WAITING_FOR_SPA = 1
from @ProcedureData                       as pd
join dbo.CLAIM_PROCEDURES_WAITING_FOR_SPA as spa on spa.PROCEDURE_ID = pd.PROCEDURE_ID
where (pd.PROCEDURE_NOT_BILLABLE = 1)


/*===========================================================
 * Get service name data
 *============================================================*/  

RAISERROR ('Getting service name data', 0, 1) WITH NOWAIT
declare @SvcNames as table (
   IEP bit
  ,NAME_ID bigint
  ,SVC_NAME varchar(1000)
  unique clustered (IEP, NAME_ID)
)
insert into @SvcNames
select 
   isIFSPorIEP as IEP
  ,nameID      as NAME_ID
  ,SVC_NAME = null
from dbo.WAITING_SERVICES_DATA_TEMP 
group by isIFSPorIEP, nameID

update sn
  set SVC_NAME = cn.NAME
from @SvcNames as sn
join CLAIM_IEPandIFSPNames as cn on cn.IEP_IFSP_NAME_ID = sn.NAME_ID
where (sn.IEP = 1) 

update sn
  set SVC_NAME = cn.NAME
from @SvcNames as sn
join CLAIM_NoPlanNames as cn on cn.NO_PLAN_NAME_ID = sn.NAME_ID
where (sn.IEP = 0) 

/*===========================================================
 * Update waiting svcs data with various entity data and calcs
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with patient data', 0, 1) WITH NOWAIT
update
  t1
set t1.patName = pd.CONCAT_NAME
   ,t1.patBIC  = pd.BIC
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @PatientsData as pd on pd.PATIENT_ID = t1.patID

RAISERROR ('Removing WAITING_SERVICES_DATA_TEMP records that are for patients who are NOT elig', 0, 1) WITH NOWAIT
delete t1
from dbo.WAITING_SERVICES_DATA_TEMP      as t1
join dbo.PATIENTS_ELIGIBILITY_NORMALIZED as pen on pen.PATIENT_ID = t1.patID
                                                and pen.MONTH_DATE = t1.dosMonthYear
where ((pen.IS_ELIG = 0) and (t1.patBIC != ''))

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with practitioner data', 0, 1) WITH NOWAIT
update
  t1
set t1.pracName = pd.CONCAT_NAME
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @PractitionersData as pd on pd.PRACTITIONER_ID = t1.pracID
  
RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with service name data', 0, 1) WITH NOWAIT
update
  t1
set t1.svcName = sd.SVC_NAME
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @SvcNames as sd on sd.IEP = t1.isIFSPorIEP and sd.NAME_ID = t1.nameID

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with group data', 0, 1) WITH NOWAIT
update
  t1
set 
    t1.groupName           = gd.GROUP_NAME
  , t1.pracGroupFamilyName = gd.pracGroupFamilyName
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @GroupData as gd on gd.GROUP_ID= t1.groupID
  
RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with reimburse est, and proc mod combo', 0, 1) WITH NOWAIT
update 
  t1
set t1.REIMBURSE_ESTIMATE = dbo.CALC_REIMBURSE_ESTIMATE (  t1.svcType      
                                                         , t1.SERVICE_UNITS
                                                         , t1.TCM_RATE
                                                         , pd.MIN_UNITS
                                                         , pd.MAX_UNITS
                                                         , pd.SERVICE_FEE
                                                         , pd.TCM_LOW_RATE
                                                         , pd.TCM_MEDIUM_RATE
                                                         , pd.TCM_HIGH_RATE )
   ,t1.PROC_MOD_COMBO                    = pd.PROC_MOD_COMBO
   ,t1.PROCEDURE_NAME                    = pd.PROCEDURE_NAME
   ,t1.PROCEDURE_NOT_BILLABLE            = pd.PROCEDURE_NOT_BILLABLE
   
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @ProcedureData as pd on pd.PROCEDURE_ID = t1.PROCEDURE_ID


/*============================================================
 * Replace procedure specific hold for more detailed reason
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP records that have tx hold because of client specific procedure hold with more detailed msg', 0, 1) WITH NOWAIT
update dbo.WAITING_SERVICES_DATA_TEMP
set LAST_TRANSMISSION_HOLD_REASON = 'Client has requested we do not claim ' + svcName
where LAST_TRANSMISSION_HOLD_REASON like  '%not allowed to transmit procedure%'

/*============================================================
 * Replace pre 7/1/2018 speech treatment holds for no PBS
 * with more generic reason
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP records that have tx hold because of pre Jul 2017 speech PBS doc missing', 0, 1) WITH NOWAIT
update dbo.WAITING_SERVICES_DATA_TEMP
set LAST_TRANSMISSION_HOLD_REASON = 'Missing Order or Prescription in SpEdCare'
where LAST_TRANSMISSION_HOLD_REASON = 'Speech claim does not have a covering PBS in SpEdCare'


/*============================================================
 * Calc ages
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with date ages', 0, 1) WITH NOWAIT
update dbo.WAITING_SERVICES_DATA_TEMP
set 
    dosAgeInDays     = DATEDIFF(day,dos,@today)
   ,dosUseOrLose     = dbo.CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM(dos,@today)
   ,createdAgeInDays = DATEDIFF(day,created,@today) 
   
RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with before or after tx calc', 0, 1) WITH NOWAIT
update t1
  set createdDaysBeforeAfterLastTx = DATEDIFF(day,t1.created,clc.LAST_TRANSMISSION_DATETIME)
from @clients as clc
join dbo.WAITING_SERVICES_DATA_TEMP as t1 on t1.clientID = clc.CLIENT_ID
where (clc.LAST_TRANSMISSION_DATETIME is not null)

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with dos month year calc', 0, 1) WITH NOWAIT
update WAITING_SERVICES_DATA_TEMP 
set dosMonthYear = dbo.DATE_START(dos,3)

/*===========================================================
 * Clean up nulls
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP last tx hold reason with space', 0, 1) WITH NOWAIT
update dbo.WAITING_SERVICES_DATA_TEMP
  set LAST_TRANSMISSION_HOLD_REASON = ''
where LAST_TRANSMISSION_HOLD_REASON is null

/*===========================================================
 * Update waiting svcs data with pre transmission hold reasons
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP pre tx hold reason for client', 0, 1) WITH NOWAIT
update t1
  set t1.PRE_TRANSMISSION_HOLD_REASONS = t2.PRE_TRANSMISSION_HOLD_REASONS
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @clients as t2 on t2.CLIENT_ID = t1.clientID
where ((t1.PRE_TRANSMISSION_HOLD_REASONS = '') and (t2.PRE_TRANSMISSION_HOLD_REASONS != ''))

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP pre tx hold reason for future spa', 0, 1) WITH NOWAIT
update t1
  set t1.PRE_TRANSMISSION_HOLD_REASONS = 'Future SPA Services'
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @ProcedureData as t2 on t2.PROCEDURE_ID = t1.PROCEDURE_ID
where (t1.PRE_TRANSMISSION_HOLD_REASONS = '') and (t2.WAITING_FOR_SPA = 1)

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP pre tx hold reason for procedure', 0, 1) WITH NOWAIT
update t1
  set t1.PRE_TRANSMISSION_HOLD_REASONS = 'Service is non billable'
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @ProcedureData as t2 on t2.PROCEDURE_ID = t1.PROCEDURE_ID
where (t1.PRE_TRANSMISSION_HOLD_REASONS = '') and (t2.PROCEDURE_NOT_BILLABLE = 1)

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP pre tx hold reason for patient', 0, 1) WITH NOWAIT
update t1
  set t1.PRE_TRANSMISSION_HOLD_REASONS = t2.PRE_TRANSMISSION_HOLD_REASONS
from dbo.WAITING_SERVICES_DATA_TEMP as t1
join @PatientsData as t2 on t2.PATIENT_ID = t1.patID
where ((t1.PRE_TRANSMISSION_HOLD_REASONS = '') and (t2.PRE_TRANSMISSION_HOLD_REASONS != ''))

/*============================================================
 * Remove rows where the service is waiting to be considered
 * by the transmission routine hold logic OR the service will
 * probably be sent soon
 *============================================================*/  

RAISERROR ('Removing WAITING_SERVICES_DATA_TEMP records that are waiting for tx or will be tx soon', 0, 1) WITH NOWAIT

delete dbo.WAITING_SERVICES_DATA_TEMP
where LAST_TRANSMISSION_HOLD_REASON like  '%Service falls within the hold period for the client%'

delete dbo.WAITING_SERVICES_DATA_TEMP
where LAST_TRANSMISSION_HOLD_REASON like  '%the batch this service was in%'  

delete dbo.WAITING_SERVICES_DATA_TEMP
where ((PRE_TRANSMISSION_HOLD_REASONS = '')
and (LAST_TRANSMISSION_HOLD_REASON = ''))

/*============================================================
 * Update combined hold reason 
 *============================================================*/  

RAISERROR ('Updating WAITING_SERVICES_DATA_TEMP with combined hold reason', 0, 1) WITH NOWAIT

update dbo.WAITING_SERVICES_DATA_TEMP
set holdReason = case when (LAST_TRANSMISSION_GENERATION_ID is null)
                     then PRE_TRANSMISSION_HOLD_REASONS
                     else LAST_TRANSMISSION_HOLD_REASON 
                 end            

/*============================================================
 * Remove rows that became ORP compliant since last time this
 * update was run
 *============================================================*/  

RAISERROR ('Removing rows from WAITING_SERVICES_DATA_TEMP that are now ORP compliant', 0, 1) WITH NOWAIT
delete dbo.WAITING_SERVICES_DATA_TEMP where holdReason = 'ORP Compliant'

/*============================================================
 * Reporting index
 *============================================================*/  

RAISERROR ('Recreating reporting index on WAITING_SERVICES_DATA_TEMP', 0, 1) WITH NOWAIT

CREATE NONCLUSTERED INDEX [RepNameClientNameDosMYUseLoseIdx] ON [dbo].[WAITING_SERVICES_DATA_TEMP] 
(
	[repName] ASC,
	[clientName] ASC,
	[dosMonthYear] DESC,
	[dosUseOrLose] DESC
)
INCLUDE ( [idx]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [RPT_MISSING_ORP_DETAILS]
ON [dbo].[WAITING_SERVICES_DATA_TEMP] ([groupID],[orpRequired],[orpDocID])
INCLUDE ([clientID],[clientName],[repName],[repEmail],[dos],[svcRecID],[patID],[patName],[patBIC],[REIMBURSE_ESTIMATE],[pracGroupFamilyName],[holdReason],[REP_ID])

/*============================================================
 * Update WAITING_JOURNALS_DATA_TEMP
 *============================================================*/  

RAISERROR ('Updating WAITING_JOURNALS_DATA_TEMP client data', 0, 1) WITH NOWAIT
update t1
set 
    t1.clientName = clc.CLIENT_NAME
  , t1.repName    = clc.REP_EMAIL
  , t1.repEmail   = clc.REP_EMAIL
from dbo.WAITING_JOURNALS_DATA_TEMP as t1
join @clients as clc on clc.CLIENT_ID = t1.clientID

RAISERROR ('Updating WAITING_JOURNALS_DATA_TEMP patient data', 0, 1) WITH NOWAIT
update t1
set 
   t1.patName = pd.CONCAT_NAME
  ,t1.patBIC = pd.BIC  
from dbo.WAITING_JOURNALS_DATA_TEMP as t1
join @PatientsData as pd on pd.PATIENT_ID = t1.patID

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
 
GRANT EXECUTE ON  [dbo].[UPDATE_WAITING_WORK_JOURNALS_SERVICES_DATA] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_MANAGE_SERVICE_RECORDS') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_MANAGE_SERVICE_RECORDS
GO

/*-------------------------------
 * Create
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[SVCJOURNAL_MANAGE_SERVICE_RECORDS]    
 (@userID              BIGINT,    
  @userGroup           INT,    
  @userRank            INT,    
  @clientID            BIGINT,
  @journalID           BIGINT,
  @reference           VARCHAR(500),
  @editDelReason       VARCHAR(7000),    
  @validateRec         BIT,    
  @saveType            INT,    
  @recID               BIGINT,
  @MsgNoRec            VARCHAR(1000),    
  @MsgNoEdit           VARCHAR(1000),
  @MsgDupRec           VARCHAR(1000),  
  @MsgDataError        VARCHAR(1000),
  @MsgNotActive        VARCHAR(1000),  
  @msgInvCombo         VARCHAR(1000),    
  @MsgMinReq           VARCHAR(1000),    
  @MsgMinDef           VARCHAR(1000),    
  @MsgMilReq           VARCHAR(1000),    
  @MsgPatElg           VARCHAR(1000),
  @MsgPatDOBGteDOS     VARCHAR(1000),
  @MsgPatAbsent        VARCHAR(1000),
  @MsgFutureDOS        VARCHAR(1000),
  @spDetails           VARCHAR(8000) OUTPUT,    
  @recordID            BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * SVCJOURNAL_MANAGE_SERVICE_RECORDS */    
/**    
 * Creates service records from service journal when journal is closed
 * Deletes service records that are no longer valid when journal is reclosed
 *
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   journalID       Journal id
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    

BEGIN TRY


/*============================================================
 * Init output parameters
 *============================================================*/  
   
SET @recordID   = 0    
SET @spDetails  = ''    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
   
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)
IF (@clientID      IS NULL) RAISERROR ('clientID is required',    11, 1)    
IF (@journalID     IS NULL) RAISERROR ('journalID is required',   11, 1)    


/*============================================================
 * Check to see if the services associated with this journal
 * (if any) have been sent.  If they have we cannot do anything
 * and we need to get out.
 *============================================================*/  

declare @canStillEditOrDelJournal as bit = null

set @canStillEditOrDelJournal = dbo.SvcJournal_Can_Edit(@userID,@userGroup,@userRank,@clientID,@journalID)

if ((@canStillEditOrDelJournal = 0) or (@canStillEditOrDelJournal is null)) 
begin
  RAISERROR ('Service records associated with this journal can no longer be modified.', 11, 1)       
end


/*============================================================
 * Create table var to hold related service records 
 *============================================================*/  

declare @relatedSvcRecs as table (
     id             bigint identity(1,1)
   , journalID      bigint
   , svcRecID       bigint
   , pracID         bigint
   , userID         bigint
   , userGroup      int
   , userRank       int
   , state          int
   , canStillEditSvc bit
)

/*============================================================
 * Create table var to a list of pracs who have no changes
 * to the journal
 *============================================================*/  

declare @pracsWithNoChanges as table(
   id              bigint identity(1,1)
  ,pracID          bigint
)

/*============================================================
 * Create table var to hold service records to create data
 *============================================================*/  
 
declare @svcRecsNewData as table (
    id                   bigint identity(1,1)
  , idx                  bigint 
  , clientID             bigint
  , reference            varchar(500)
  , journalID            bigint
  , dos                  date
  , iep                  bit
  , patID                bigint
  , patAbsent            bit
  , pracID               bigint
  , userID               bigint
  , userGroup            int
  , userRank             int
  , nameID               bigint
  , procID               bigint
  , numMins              int
  , notes                varchar(max)
  , orpDocID             bigint
  , orpDocReq            bit
  , startTimeActual      time(0)
  , svcRecClaimable      bit
)


/*============================================================
 * Create table var to hold service records to delete 
 *============================================================*/  

declare @svcRecsToDelete as table (
     id          bigint identity(1,1)
   , svcRecID    bigint
   , pracID      bigint
   , userID      bigint
   , userGroup   int
   , userRank    int 
)

/*============================================================
 * Create working vars to use for our exec loops and init
 *============================================================*/  

declare @currID          as bigint    = null
declare @lastID          as bigint    = null
declare @pracID          as bigint    = null
declare @pracUserID      as bigint    = null
declare @pracUserGroupID as int       = null
declare @pracUserRank    as int       = null
declare @svcRecID        as bigint    = null
declare @isReclose       as bit       = null
declare @currentRevision as bigint    = null
declare @completed       as bit       = null
declare @today           as datetime  = null
declare @numSentSvcs     as int       = 0

set @today       = GETDATE()
set @numSentSvcs = 0

/*============================================================
 * Find journal
 *============================================================*/  

select 
   @recordID        = id 
  ,@currentRevision = currentRevision
  ,@completed       = completed 
from dbo.SvcJournals as sj 
where ((sj.clientID = @clientID) and (sj.id = @journalID) and (sj.active = 1))

/*============================================================
 * If journal is not found or is no longer active get out
 *============================================================*/  

if (@recordID is null)
  RAISERROR ('Journal not found or journal has been deleted.', 11, 1)   

/*============================================================
 * Determine if this is a reclose
 *============================================================*/  

if (@currentRevision is not null) 
  set @isReclose = 1 
else 
  set @isReclose = 0

/*============================================================
 * Get related service records 
 *============================================================*/  

insert into @relatedSvcRecs
select  
    journalID
  , svcRecID
  , pracID
  , userID
  , userGroup
  , userRank
  , state
  , canStillEditSvc
  
from dbo.SvcJournal_Related_Svc_Records_Data_Core (
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @journalID
  , null
  , null) 
  
where 
  ([state] != dbo.CONST_SVC_REC_STATE_DEL())

/*============================================================
 * Get a list of practitioners who have no changes to 
 * a previous revision of the journal
 *============================================================*/  

insert into @pracsWithNoChanges 

select distinct 
  pracID 
from dbo.SvcJournal_Compare_Prev_to_Curr_Core (@userID,@userGroup,@userRank,@clientID,@journalID,@currentRevision)
where (
      (Header = 0) 
  and (Block  = 1) 
  and (Prev   = 1) 
  and (Curr   = 1)
  and (pracID not in (
    select distinct pracID
    from
    (
      select pracID
      from dbo.SvcJournal_Compare_Prev_to_Curr_Core (@userID,@userGroup,@userRank,@clientID,@journalID,@currentRevision)
      where ((Header = 0) and (Block = 1) and (Prev = 0) and (Curr = 1))
      union 
      select pracID
      from dbo.SvcJournal_Compare_Prev_to_Curr_Core (@userID,@userGroup,@userRank,@clientID,@journalID,@currentRevision)
      where ((Header = 0) and (Block = 1) and (Prev = 1) and (Curr = 0))
    ) as q1
  ))
)

/*===========================================================
 * Journal Close
 * This call will be coming from JOURNAL_CLOSE
 *============================================================*/  

if @saveType = dbo.CONST_SAVE_TYPE_NEW()
begin

  /*-------------------------------
   * If the journal is not closed
   * yet we have to get out
   *------------------------------*/

  if (@completed = 0)
    RAISERROR ('Journal must be closed', 11, 1)    

  /*-------------------------------
   * Clean up and capture
   * time block data for later use
   *------------------------------*/

  delete dbo.SvcJournal_Service_Records_Time_Blocks where (journalID = @journalID)

  insert into dbo.SvcJournal_Service_Records_Time_Blocks
  select
    null as svcRecID
    , journalID
    , contBlock
    , pracID
    , nameID
    , iep
    , procID
    , numMins
    , startTime
    , endTime
    , eventTypeID
    , entryNotes
    , orpDocID
    , orpDocReq
    
  FROM dbo.SvcJournal_Journal_Service_Blocks_And_Procedure_Data_View_Core(  @userID
                                                                           ,@userGroup
                                                                           ,@userRank
                                                                           ,@clientID
                                                                           ,@journalID)
    
  /*-------------------------------
   * Initial journal close
   *------------------------------*/

  if (@isReclose = 0)
  begin
                    
    /* Get data for new service records */
    
    insert into @svcRecsNewData
    select 
      t1.* 
    from dbo.SvcJournal_Journal_Service_Blocks_And_Procedure_Data_Combined_View_Core( @userID
                                                                                    , @userGroup
                                                                                    , @userRank
                                                                                    , @clientID
                                                                                    , @journalID
                                                                                    , @reference ) as t1


       
  end
  
  /*-------------------------------
   * Journal reclose
   *------------------------------*/

  if (@isReclose = 1)
  begin
  
    /* Get list of service records that need to be deleted excluding pracs with no changes */
    
    insert into @svcRecsToDelete
    select 
        svcRecID
      , pracID
      , userID
      , userGroup
      , userRank
    from @relatedSvcRecs as rsr
    where (rsr.pracID not in (select pracID from @pracsWithNoChanges))
        
  
	/* Get data for new service records excluding pracs with no changes */
    
    insert into @svcRecsNewData
    select 
      sjsb.* 
    from dbo.SvcJournal_Journal_Service_Blocks_And_Procedure_Data_Combined_View_Core( @userID
                                                                                    , @userGroup
                                                                                    , @userRank
                                                                                    , @clientID
                                                                                    , @journalID
                                                                                    , @reference ) as sjsb
    where (sjsb.pracID not in (select pracID from @pracsWithNoChanges))

  end
   
end

/*===========================================================
 * Journal Delete
 * This will be coming from JOURNAL_DELETE
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_DELETE())
begin

  /*-------------------------------
   * If the journal is not open
   * we have to get out
   *------------------------------*/

  if (@completed = 1)
    RAISERROR ('Journal must be open', 11, 1)    

  /*-------------------------------
   * Delete before initial close
   *------------------------------*/
  
  if (@isReclose = 0)
  begin    
    return /* Exit early so the journal delete can complete*/
  end
    
  /*-------------------------------
   * Delete before a reclose
   *------------------------------*/
  
  if (@isReclose = 1)
  begin    
    
    /* Get list of service records to delete */     
    
    insert into @svcRecsToDelete
    select 
        svcRecID
      , pracID
      , userID
      , userGroup
      , userRank
    from @relatedSvcRecs
      
  end
end

else
begin
  RAISERROR ('Unknown save type', 11, 1)   
end

/*============================================================
 * Delete service records 
 *============================================================*/  

set @currID = null
set @lastID = null
set @currID = (select MIN(id) from @svcRecsToDelete)
set @lastID = (select MAX(id) from @svcRecsToDelete)

while (@currID <= @lastID)
begin
  
  set @svcRecID        = null
  set @pracID          = null
  set @pracUserID      = null
  set @pracUserGroupID = null
  set @pracUserRank    = null

  select top 1
      @svcRecID         = t1.svcRecID 
    , @pracID           = t1.pracID 
    , @pracUserID       = t1.userID
    , @pracUserGroupID  = t1.userGroup
    , @pracUserRank     = t1.userRank
  
  from @svcRecsToDelete as t1
    
  where 
    (t1.id = @currID)
  
  /*-------------------------------
   * Delete service
   *------------------------------*/

  exec dbo.SERVICE_RECORD_Delete_Core
      @pracUserID
    , @pracUserGroupID
    , @pracUserRank
    , @editDelReason
    , @validateRec
    , @clientID
    , @svcRecID
    , 0
    , @today    
    , @MsgNoRec   
    , @MsgNoEdit
    , @spDetails OUTPUT
    , @recordID  OUTPUT  
  
  /*-------------------------------
   * Remove time block data
   *------------------------------*/

  delete dbo.SvcJournal_Service_Records_Time_Blocks   
  where (
         (journalID = @journalID)
    and  (pracID    = @pracID) 
    and  (svcRecID  = @svcRecID)
  )
  
  /*-------------------------------
   * Remove svc rec cross ref data
   *------------------------------*/

  delete dbo.SvcJournal_Service_Records 
  where ( 
        (journalID = @journalID)  
    and (svcRecID  = @svcRecID)
  )
       
  /*-------------------------------
   * Update approval data (if any)
   *------------------------------*/

  update dbo.SERVICE_RECORDS_APPROVAL 
  set journalID = @journalID 
  where (svcRecID = @svcRecID)
  
  
  /*-------------------------------
   * Next
   *------------------------------*/

  set @currID = @currID + 1

end

/*============================================================
 * Create new service records
 *============================================================*/  

declare @batchID          AS UNIQUEIDENTIFIER = NULL
declare @batchIDRecID     AS bigint           = NULL
declare @batchIDAssRecID  AS bigint           = NULL

/*============================================================
 * Create service record batch id
 *============================================================*/  
 
SET @recordID = NULL

exec SERVICE_RECORD_BATCH_ID_Create
    @userID
  , @userGroup
  , @userRank
  , @saveType
  , @validateRec
  , @batchIDRecID OUTPUT
  , @batchID      OUTPUT  
  
/*============================================================
 * Create services
 *============================================================*/  

set @currID = null
set @lastID = null
set @currID = (select MIN(id) from @svcRecsNewData)
set @lastID = (select MAX(id) from @svcRecsNewData)

while (@currID <= @lastID)
begin

  declare @dos             as date          = null
  declare @patID           as bigint        = null
  declare @patAbsent       as bit           = null
  declare @iep             as bit           = null
  declare @nameID          as bigint        = null
  declare @numMins         as int           = null
  declare @notes           as varchar(max)  = null
  declare @procID          as bigint        = null
  declare @orpDocID        as bigint        = null
  declare @orpDocReq       as bit           = null
  declare @startTime       as time(0)       = null
  declare @svcRecClaimable as bit           = null

  set @svcRecID        = null
  set @pracID          = null
  set @pracUserID      = null
  set @pracUserGroupID = null
  set @pracUserRank    = null
  
  /*-------------------------------
   * Get service record entry data 
   *------------------------------*/

  select top 1 
  
      @dos             = dos
    , @patID           = patID
    , @patAbsent       = patAbsent
    , @iep             = iep
    , @pracID          = pracID
    , @pracUserID      = userID
    , @pracUserGroupID = userGroup
    , @pracUserRank    = userRank
    , @nameID          = nameID  
    , @numMins         = numMins
    , @notes           = notes  
    , @procID          = procID
    , @orpDocReq       = orpDocReq
    , @orpDocID        = orpDocID
    , @startTime       = startTimeActual  
	, @svcRecClaimable = svcRecClaimable
  from @svcRecsNewData
  where (id = @currID)
  
  /*-------------------------------
   * Create service record
   *------------------------------*/
   
  EXEC dbo.SERVICE_RECORD_Save_Core
    @pracUserID  
  , @pracUserGroupID
  , @pracUserRank
  , @svcRecClaimable /* Generate claims*/
  , 10    
  , @reference
  , ''    
  , ''    
  , @dos
  , @clientID
  , @pracID
  , @patID
  , @iep
  , @nameID
  , @orpDocReq   /* has orp doc*/
  , @orpDocID    /* orp doc id*/
  , null         /* ORP NPI */
  , 0
  , 0
  , 0
  , 0
  , 0
  , @startTime
  , @numMins
  , 0    
  , 0    
  , 0    
  , 0    
  , 0
  , 0    
  , 0
  , 0
  , @patAbsent  
  , 0
  , 0 
  , null /* @attendanceSelectionID*/
  , @notes
  , null
  , null
  , null
  , 0 /* has patient progress data tracking */
  , 1 /* Billing program */
  , 0    /* Has fillable pdf (TODO: Add these 3 parms) */
  , '[]' /* Fillable pdf selections */
  , '[]' /* Fillable pdf answers*/
  , @editDelReason
  , @validateRec
  , @saveType
  , @recID
  , @msgDupRec
  , @msgInvCombo
  , @MsgNoRec  
  , @MsgNoEdit    
  , @MsgDataError
  , @MsgMinReq    
  , @MsgMinDef    
  , @MsgMilReq    
  , @MsgPatElg
  , @MsgPatDOBGteDOS
  , @MsgNotActive
  , @MsgPatAbsent
  , @MsgFutureDOS
  , @spDetails     OUTPUT
  , @svcRecID      OUTPUT  
  
  /*-------------------------------
   * Assign batch id to service rec
   *------------------------------*/

  exec SERVICE_RECORD_BATCH_ID_Assign
    @userID
  , @userGroup
  , @userRank
  , @saveType
  , @validateRec
  , @batchID
  , 1
  , @svcRecID
  , @batchIDAssRecID OUTPUT

  /*-------------------------------
   * Update time block data with
   * service record id
   *------------------------------*/

  update dbo.SvcJournal_Service_Records_Time_Blocks
  
  set svcRecID = @svcRecID
  
  where (
         (journalID = @journalID)
    and  (pracID    = @pracID) 
    and  (nameID    = @nameID) 
    and  (procID    = @procID)
  )
  
  /*-------------------------------
   * Create service record journal
   * cross ref
   *------------------------------*/

  insert into dbo.SvcJournal_Service_Records (journalID,svcRecID,active) values (@journalID,@svcRecID,1)
  
  /*-------------------------------
   * Update approval data (if any)
   *------------------------------*/

  update dbo.SERVICE_RECORDS_APPROVAL 
  set journalID = @journalID 
  where (svcRecID = @svcRecID)

  
  set @currID = @currID + 1

end

set @recordID = @journalID

RETURN(0)    

END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Return any    
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
   
  -- Only send really bad exceptions back with sp details

  IF (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
   
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_MANAGE_SERVICE_RECORDS] TO [webuser]
GO
  
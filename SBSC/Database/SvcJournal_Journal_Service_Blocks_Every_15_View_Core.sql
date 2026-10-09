USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Service_Blocks_Every_15_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Service_Blocks_Every_15_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Service_Blocks_Every_15_View_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @journalID         BIGINT
)    

RETURNS 

@rows table (

   contRowNum       bigint
 , timeSlotNum      bigint
 , eventStartTime   time(0)
 , eventEndTime     time(0)
 , eventLabel       varchar(1000)
 , eventNotes       varchar(1000)
 , pracID           bigint
 , pracName         varchar(1000) 
)
 
 /***************************************************************************    
  * SvcJournal_Journal_Service_Blocks_Every_15_View_Core */    
 /**    
  * Returns a list of journal entries
  *
  * @return table 
  ***************************************************************************/                         
     
AS 
begin

declare @serviceBlocks as table (
   insideContBlock      bit
 , standAloneNonBillSvc bit
 , contBlock            bit
 , breakInCare          bit
 , journalID            bigint
 , dos                  date
 , patID                bigint
 , patAbsent            bit
 , iep                  bit
 , startTime            time(0)
 , endTime              time(0)
 , orpDocID             bigint
 , eventTypeID          bigint
 , eventTypeLabel       varchar(1000)
 , pracID               bigint
 , userID               bigint
 , entryNotes           varchar(8000)
 , contStartNotes       varchar(8000)
 , contEndNotes         varchar(8000)
 , contRowNum           bigint
 , startTimeRound15     time(0)
 , endTimeRound15       time(0)
 , numMins              int
 , numMinsRound15       int
 , userGroup            int
 , userRank             int
)

declare @contMonPracs as table (
   idx           bigint identity(1,1)
  ,pracID        bigint  
  ,pracName      varchar(1000)
  ,contStartNote varchar(8000)
  ,contEndNote   varchar(8000)
)

declare @serviceBlockExpanded as table (
        contRowNum       bigint
      , timeSlotNum      bigint
      , eventStartTime   time(0)
      , eventEndTime     time(0)
      , eventLabel       varchar(1000)
      , eventNotes       varchar(1000)
      , pracID           bigint
      , pracName         varchar(1000) 
    )
   
/*###########################################################################
  # Get service blocks
  ###########################################################################*/

insert into @serviceBlocks
select * 
from dbo.SvcJournal_Journal_Service_Blocks_View_Core (@userID,@userGroup,@userRank,@clientID,@journalID)


/*###########################################################################
  # Get cont mon svc pracs 
  ###########################################################################*/

insert into @contMonPracs
select distinct 
   pracID 
  ,null
  ,null
  ,null
from @serviceBlocks 
where (contBlock = 1)


declare @minIdx as bigint = null
declare @maxIdx as bigint = null
declare @curIdx as bigint = null

select top 1 @minIdx = MIN(idx) from @contMonPracs
select top 1 @maxIdx = MAX(idx) from @contMonPracs

set @curIdx = @minIdx

while (@curIdx <= @maxIdx)
begin
  
  declare @pracID        as bigint        = null
  declare @pracName      as varchar(1000) = null
  declare @minContRowNum as bigint        = null
  declare @maxContRowNum as bigint        = null
  declare @curContRowNum as bigint        = null
  declare @contStartNote as varchar(8000) = null 
  declare @contEndNote   as varchar(8000) = null

  select top 1 @pracID   = pracID      from @contMonPracs                 where (idx             = @curIdx)  
  select top 1 @pracName = concat_name from dbo.PRACTITIONER_Practitioner where (PRACTITIONER_ID = @pracID)
  
  select 
      @minContRowNum  = min(contRowNum) 
    , @maxContRowNum  = max(contRowNum)
    , @contStartNote  = max(contStartNotes)
    , @contEndNote    = max(contEndNotes)
    
  from @serviceBlocks 
  where (
        (pracID      = @pracID) 
    and (contBlock   = 1) 
    and (breakInCare = 0)
  )
  
  update @contMonPracs 
  set 
      pracName      = @pracName
    , contStartNote = @contStartNote
    , contEndNote   = @contEndNote
  where (idx = @curIdx)
  
  set @curContRowNum = @minContRowNum

  while (@curContRowNum <= @maxContRowNum)
  begin
    
    declare @startBlockTimeRnd15 as time(0)       = null
    declare @endBlockTimeRnd15   as time(0)       = null
    declare @startBlockTimeAct   as time(0)       = null
    declare @endBlockTimeAct     as time(0)       = null
    declare @eventLabel          as varchar(1000) = null
        
    select top 1
        @startBlockTimeRnd15 = sbp.startTimeRound15
      , @endBlockTimeRnd15   = sbp.endTimeRound15
      , @startBlockTimeAct   = sbp.startTime
      , @endBlockTimeAct     = sbp.endTime
      , @eventLabel          = sbp.eventTypeLabel      
    from @serviceBlocks as sbp 
    where (
          (pracID      = @pracID) 
      and (contBlock   = 1) 
      and (breakInCare = 0) 
      and (contRowNum  = @curContRowNum)
    )
    
    insert into @serviceBlockExpanded
    select
        contRowNum = @curContRowNum
      , timeSlotNum
      , startTime    as eventStartTime
      , endTime      as eventEndTime
      , @eventLabel as eventLabel
      , dbo.CONST_SVCJOURNAL_CONT_SVC_EVENT_DEFAULT_NOTE() as eventNotes
      , @pracID     as pracID
      , @pracName   as pracName
    from dbo.CALC_TIME_SLOTS (  @startBlockTimeRnd15
                              , @endBlockTimeRnd15
                              , 15
                              , null
                              , null ) 
    
    declare @minTimeSlotNum as bigint = null
    declare @maxTimeSlotNum as bigint = null
        
    select 
        @minTimeSlotNum = MIN(timeSlotNum) 
      , @maxTimeSlotNum = MAX(timeSlotNum)
    from @serviceBlockExpanded
    
    update @serviceBlockExpanded 
    set       
      eventStartTime = @startBlockTimeAct
    where (timeSlotNum = @minTimeSlotNum)
    
    update @serviceBlockExpanded 
    set        
      eventEndTime   = @endBlockTimeAct
    where (timeSlotNum = @maxTimeSlotNum)
    
    insert into @rows
    select     
       contRowNum      
     , timeSlotNum     
     , eventStartTime
     , eventEndTime
     , eventLabel     
     , eventNotes     
     , pracID
     , pracName       
     
    from @serviceBlockExpanded

    delete @serviceBlockExpanded 

    set @curContRowNum = @curContRowNum + 1    
  end
  
  declare @minTimeSlotNumFirstContRow as bigint = null
  declare @maxTimeSlotNumLastContRow  as bigint = null
  
  select @minTimeSlotNumFirstContRow = min(timeSlotNum) from @rows where (pracID = @pracID) and (contRowNum = @minContRowNum)
  select @maxTimeSlotNumLastContRow  = max(timeSlotNum) from @rows where (pracID = @pracID) and (contRowNum = @maxContRowNum)
  
  update @rows
  set eventNotes = isnull(@contStartNote,dbo.CONST_SVCJOURNAL_CONT_SVC_EVENT_DEFAULT_NOTE())
  where (pracID = @pracID) and (contRowNum = @minContRowNum) and (timeSlotNum = @minTimeSlotNumFirstContRow)
  
  update @rows
  set eventNotes = isnull(@contEndNote,dbo.CONST_SVCJOURNAL_CONT_SVC_EVENT_DEFAULT_NOTE())
  where (pracID = @pracID) and (contRowNum = @maxContRowNum) and (timeSlotNum = @maxTimeSlotNumLastContRow)
  
    
  set @curIdx = @curIdx + 1

end

insert into @rows
select 
  contRowNum       = null
, timeSlotNum      = null
, startTime        as eventStartTime
, endTime          as eventEndTime
, eventTypeLabel   as eventLabel
, entryNotes       as eventNotes
, pracID
, prp.CONCAT_NAME  as pracName
from
(
  select * from @serviceBlocks where contBlock = 1 and breakInCare = 1
  union all
  select * from @serviceBlocks where contBlock = 0 and breakInCare = 0
) as q1
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = q1.pracID

return

end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Service_Blocks_Every_15_View_Core] TO [webuser]
GO  

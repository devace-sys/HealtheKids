USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Entries_Validate') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SvcJournal_Journal_Entries_Validate
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Entries_Validate] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT    
  , @clientID          BIGINT  
  , @journalID         BIGINT
  , @pracID            BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Entries_Validate */    
 /**    
  * Returns a list of problems with journal entries
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with

/*###########################################################################
  # Get journal entries   
  ###########################################################################*/

cte_journal_entries
as
(
select        
     journalEntryID   = sjee.id
   , eventType        = sjet.id
   , eventLabel       = sjet.eventLabel
   , pracID           = sjee.pracID
   , pracGroupID      = pg.GROUP_ID
   , pracClassID      = sjpcpg.pracClass
   , pracName         = prp.CONCAT_NAME
   , entryStartTime   = sjee.entryStartTime
   , entryEndTime     = sjee.entryEndTime
   , entryNotes       = sjee.entryNotes
   , contSvcGroupPart = sjet.contSvcGroupPart
   , reqStartTime     = sjet.reqStartTime
   , reqEndTime       = sjet.reqEndTime
   , reqNote          = sjet.reqNote

from dbo.SvcJournals                    as sj
join dbo.SvcJournal_Event_Entries       as sjee   on  sjee.journalID      = sj.id
join dbo.SvcJournal_Event_Types         as sjet   on  sjet.id             = sjee.eventType
join dbo.PRACTITIONER_GROUPS            as pg     on  pg.PRACTITIONER_ID  = sjee.pracID
join dbo.PRACTITIONER_Practitioner      as prp    on  prp.PRACTITIONER_ID = pg.PRACTITIONER_ID
join dbo.SvcJournal_PracClass_PracGroup as sjpcpg on  sjpcpg.groupID      = pg.GROUP_ID

where (
       (sj.id = @journalID)   
  and  ((@pracID is null) or (sjee.pracID = @pracID))
  and  (sj.active   = 1)
  and  (sjee.active = 1)
)
)
,

/*##########################################################################
  # Get pracs
  ###########################################################################*/
  
cte_pracs
as
(
select distinct 
    pracID
  , pracName 
  , pracClassID
  , pracGroupID
from cte_journal_entries
)
,

/*###########################################################################
  # Get acccompany start/end times and any possible problems with these
  ###########################################################################*/

cte_acc_start_end_stats
as
(
select
    pracID
  , pracClassID
  , startOfAccTime
  , endOfAccTime
  , startLabel
  , endLabel
  
  /* Look for problems with start and end times themselves */
  
  , [problem] = case when (problem is null) then null     /* No pairs, nothing to do */
                     when (problem != '')   then problem  /* Incomplete pair */
                     when (problem = '')    then          /* Complete pair but are times OK */
                       case when (startOfAccTime = endOfAccTime) then startLabel + ' and ' + endLabel + ' have the same times'
                            when (startOfAccTime > endOfAccTime) then startLabel + ' is after ' + endLabel
          
                            else '' /* Pair is ok */
                       end 
                     else null
                end

from
(
  select
      p1.pracID
    , p1.pracClassID
    , p1.startOfAccTime
    , p1.endOfAccTime
    , p1.startLabel
    , p1.endLabel
    
    /* Look for incomplete pairs */

    , [problem] = case when (startOfAccTime is null)     and (endOfAccTime is null)     then null /* No pairs */
                       when (startOfAccTime is null)     and (endOfAccTime is not null) then 'Journal entry missing: ' + startLabel
                       when (startOfAccTime is not null) and (endOfAccTime is null)     then 'Journal entry missing: ' + endLabel 
                       when (startOfAccTime is not null) and (endOfAccTime is not null) then '' /* Has complete pair but still might be issues */                    
                       else null
                  end
  from          
  (
    select 
         pracID
       , pracClassID
       , sacc.startOfAccTime
       , eacc.endOfAccTime
       , sl.startLabel
       , el.endLabel
    from cte_pracs as p
    
    cross apply (
      select 
        startOfAccTime = min(entryStartTime) from cte_journal_entries 
      where 
            pracID = p.pracID 
        and contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY()
    ) as sacc

    cross apply (
      select 
        endOfAccTime = max(entryEndTime) from cte_journal_entries
      where 
             pracID = p.pracID 
         and contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY()
    ) as eacc
    
    cross apply (
      select top 1 eventLabel as startLabel from dbo.SvcJournal_Event_Types as et where et.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY() and et.pracClass = pracClassID
    ) as sl
    
    cross apply (
      select top 1 eventLabel as endLabel from dbo.SvcJournal_Event_Types as et where et.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY() and et.pracClass = pracClassID
    ) as el

  
  ) as p1
) as p2
)
,

/*###########################################################################
  # Get acccompany break times and any possible problems with these
  ###########################################################################*/

cte_acc_break_stats
as
(

select
  p1.*
, [problem] = case when numBreakTimes = 0 then null
                   when numBreakTimes > 0 then  
                     case when (numOfBadBreakTimes = 0) and (numOfOrphanBreakTimes = 0) then ''
                          when (numOfBadBreakTimes = 0) and (numOfOrphanBreakTimes > 0) then breakLabel + ' recorded without '    + startLabel + ' and ' + endLabel + ' entries' 
                          when (numOfBadBreakTimes > 0) and (numOfOrphanBreakTimes = 0) then breakLabel + ' recorded outside of ' + startLabel + ' and ' + endLabel + ' entries' 
                          when (numOfBadBreakTimes > 0) and (numOfOrphanBreakTimes > 0) then breakLabel + ' recorded without and recorded outside of ' + startLabel + ' and ' + endLabel + ' entries'                           
                     end
              end
from
(
  select 
      pracID                = ase.pracID
    , numBreakTimes         = timeCount.numOf 
    , numOfBadBreakTimes    = badTimes.numOf
    , numOfOrphanBreakTimes = orphanTimes.numOf
    , startLabel
    , endLabel
    , breakLabel
  from cte_acc_start_end_stats as ase

  cross apply (
      select top 1 eventLabel as breakLabel from dbo.SvcJournal_Event_Types as et where et.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY() and et.pracClass = pracClassID
  ) as bl
  
  cross apply (
    select 
      count(je.contSvcGroupPart) as numOf
    from cte_journal_entries as je 
    where 
          (je.pracID = ase.pracID) 
      and (je.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY())
  ) as timeCount

  cross apply (
    select 
      count(je.contSvcGroupPart) as numOf
    from cte_journal_entries as je 
    where 
          (ase.startOfAccTime is not null) 
      and (ase.endOfAccTime is not null)
      and (je.pracID = ase.pracID) 
      and (je.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY())
      and ((entryStartTime <= ase.startOfAccTime) or (entryEndTime >= ase.endOfAccTime ))
  ) as badTimes
  
  cross apply (
    select 
      count(je.contSvcGroupPart) as numOf 
    from cte_journal_entries as je 
    where 
          (ase.startOfAccTime is null) 
      and (ase.endOfAccTime is null)
      and (je.pracID = ase.pracID) 
       and (je.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY())
  ) as orphanTimes
) as p1
)
,

/*###########################################################################
  # Combine problems
  ###########################################################################*/

cte_problems
as
(
  select pracID, problem from cte_acc_start_end_stats where problem != ''
  union all
  select pracID, problem from cte_acc_break_stats     where problem != ''
)
,
cte_combined
as
(
select [retState] = dbo.CONST_RET_ERR(), * from cte_problems
)
,
cte_output
as
(
select 
    [journalID] = @journalID
  , cc.pracID
  , pp.pracName
  , cc.retState
  , [retStatus] = case 
    when retState = dbo.CONST_RET_WARN() then  'Warning'
    when retState = dbo.CONST_RET_ERR()  then  'Problem'
    else '' 
  end
  , cc.problem

from cte_combined as cc
join cte_pracs    as pp on pp.pracID = cc.pracID
)
select * from cte_output
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Entries_Validate] TO [webuser]
GO  

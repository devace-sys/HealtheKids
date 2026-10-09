USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNALS_AUTO_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNALS_AUTO_DELETE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNALS_AUTO_DELETE] 
AS    
BEGIN     
    
/***************************************************************************    
 * SVCJOURNAL_JOURNALS_AUTO_DELETE */    
/**    
 * Performs auto delete of empty journals
 *    
 ***************************************************************************/         
     
declare @emptyJournals as table (
  journalID  bigint
  unique clustered (journalID)
)

declare @numRecs    as int
declare @msgStatus  as varchar(256)
declare @today      as datetime

set NOCOUNT ON    
set @today = GETDATE()


RAISERROR ('Auto deleting empty journals', 0, 1) WITH NOWAIT   
RAISERROR ('Searching for empty journals',    0, 1) WITH NOWAIT   

insert into @emptyJournals

select   
  journalID  
from
(  
  select     
      sj.id                            as journalID
    , datediff(day,sj.created,@today)  as createdDaysAgo
    , isnull(sjee.numOfEntries,0)      as numOfEntries
    , ISNULL(sjsr.numSvcRecs,  0)      as numSvcRecs
    , ISNULL(sjrv.numRevs,     0)      as numRevs  
  from dbo.SvcJournals as sj
    
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
  
  where (
        (sj.active    = 1)
    and (sj.completed = 0)
    and (sj.patAbsent = 0)
    and (sj.lastModified   is null)
    and (sj.lastModifiedBy is null)
  )
) as q1
where (
      (q1.numOfEntries   = 0) 
  and (q1.numSvcRecs     = 0) 
  and (q1.numRevs        = 0) 
  and (q1.createdDaysAgo >= 1)
)


select @numRecs = isnull(COUNT(journalID),0) from @emptyJournals

set @msgStatus = CONVERT(varchar(1000),@numRecs) + ' empty journals to delete'

RAISERROR (@msgStatus, 0, 1) WITH NOWAIT   

if (@numRecs > 0)
begin
  RAISERROR ('Deleting empty journals', 0, 1) WITH NOWAIT   
  

  update 
    sj
  set
     active         = 0
   , completed      = 0
   , lastModified   = @today
   , lastModifiedBy = 0
  from dbo.SvcJournals  as sj
  join @emptyJournals   as ej on ej.journalID = sj.id
  where (1=1)  
   
end

RAISERROR ('Done', 0, 1) WITH NOWAIT   
  
RETURN(0)    

END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNALS_AUTO_DELETE] TO [webuser]
GO

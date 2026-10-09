USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journals_With_Missing_Start_Or_End_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journals_With_Missing_Start_Or_End_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journals_With_Missing_Start_Or_End_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @pracID            BIGINT
)    

RETURNS 

@recs table (
    journalID        bigint
  , startEntryID     bigint
  , endEntryID       bigint
  , clientID         bigint
  , pracID           bigint
  , patID            bigint
)
 
 /***************************************************************************    
  * SvcJournal_Journals_With_Missing_Start_Or_End */    
 /**    
  * Returns a list of journals with missing start or end
  *
  * @return table 
  ***************************************************************************/                         
     
AS 
BEGIN

declare @openJournalsAndEntriesWithStartOrEnd as table (
  
    journalID        bigint
  , contSvcGroupPart bigint
  , entryID          bigint
  , clientID         bigint
  , pracID           bigint
  , patID            bigint
 
 unique clustered (
     journalID
   , contSvcGroupPart
   , entryID
 )
)

declare @journalsWithStartOrEnd as table (
    journalID    bigint
  , startEntryID bigint
  , endEntryID   bigint
)
  
insert into @openJournalsAndEntriesWithStartOrEnd
select 
     sj.id                 as journalID
   , sjet.contSvcGroupPart as contSvcGroupPart
   , sjee.id               as entryID
   , sj.clientID           as clientID
   , sjee.pracID           as pracID
   , sj.patID              as patID
from dbo.SvcJournals               as sj
join dbo.SvcJournal_Event_Entries  as sjee on sjee.journalID      = sj.id
join dbo.SvcJournal_Event_Types    as sjet on sjet.id             = sjee.eventType

where (
      (1=1) 
  and ((@clientID is null) or (sj.clientID  = @clientID))
  and ((@pracID   is null) or (sjee.pracID  = @pracID))
  and (     contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY()
        or  contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY()
      )
  and (sj.active    = 1)
  and (sjee.active  = 1)
  and (sj.completed = 0)
)

insert into @journalsWithStartOrEnd
select distinct 
    oe.journalID 
  , se.entryID as startEntry
  , ee.entryID as endEntry

from ( select distinct journalID from @openJournalsAndEntriesWithStartOrEnd ) as oe

outer apply ( 
  select distinct
    entryID
  from @openJournalsAndEntriesWithStartOrEnd
  where ( 
        (journalID = oe.journalID)
    and (contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY())
  )
) as se

outer apply (
  select distinct
    entryID
  from @openJournalsAndEntriesWithStartOrEnd
  where ( 
        (journalID = oe.journalID)
    and (contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY())
  )
) as ee


insert into @recs
select distinct
   t2.journalID
  ,t1.startEntryID
  ,t1.endEntryID
 , t2.clientID
 , t2.pracID
 , t2.patID
  
from @journalsWithStartOrEnd               as t1
join @openJournalsAndEntriesWithStartOrEnd as t2 on t2.journalID = t1.journalID
where ( 
  (startEntryID is null) or (endEntryID is null)
)

RETURN
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journals_With_Missing_Start_Or_End_Core] TO [webuser]
GO  

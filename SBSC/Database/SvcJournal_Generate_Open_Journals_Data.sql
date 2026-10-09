USE SPEDMON
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Generate_Open_Journals_Data') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SvcJournal_Generate_Open_Journals_Data
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Generate_Open_Journals_Data] (
  @clientID bigint    
)   

/***************************************************************************    
 * SvcJournal_Generate_Open_Journals_Data */    
/**    
 * Calculates data about open journals
 *    
 * @param   clientID
 * @returns data
 ***************************************************************************/         
 
returns xml
begin

/*=======================================================================================================
 |                                     Create complex vars
 =========================================================================================================*/

declare @data as xml = null

/*=======================================================================================================
 |                                      Create table vars
 =========================================================================================================*/

declare @openJournalDetailData as table (
    journalID        bigint
  , entryID          bigint
  , clientID         bigint
  , dos              date
  , journalCreatedOn datetime
  , journalCreatedBy bigint
  , journalLastModOn datetime
  , journalLastModBy bigint
  , patID            bigint
  , pracID           bigint
  , entryCreatedOn   datetime
  , entryCreatedBy   bigint  
  , entryLastModOn   datetime
  , entryLastModBy   bigint
  , contStartCtr     int
  , contBreakCtr     int
  , contEndCtr       int
  , nonContCtr       int
  
  unique clustered (journalID, entryID)
)

declare @openJournalSummaryData as table (
    journalID             bigint
  , clientID              bigint
  , lastActivityUserID    bigint
  , lastActivityUserGroup int
  , lastActivityUserRank  int
  , lastActivityDateTime  datetime
  , lastActivityUID       uniqueidentifier
  , lastActivityIP        varchar(500)
  , lastActivityPracID    bigint
  , lastActivityDaysAgo   int
  , totContStart          int
  , totContBreak          int
  , totContEnd            int
  , totNonCont            int
  , totCombined           int
  , noEntries             bit
  , incompleteCont        bit
  , canStillEdit          bit
  , numValidateWarn       int
  , numValidateErr        int
  , canidateForFollowup   bit
  , canidateForClose      bit
  
  unique clustered (journalID)
)

declare @openJournalData as table (
    journalID        bigint
  , clientID         bigint
  , patID            bigint
  , dos              date
  , journalCreatedBy bigint
  , journalCreatedOn datetime
  , journalLastModBy bigint
  , journalLastModOn datetime
  unique clustered (journalID)
)


declare @openJournalClientData as table (
    clientID   bigint
  , clientName varchar(1000)
 
  unique clustered (clientID)
)

declare @openJournalPatData as table (
   patID   bigint
 , patName varchar(1000)
 
 unique clustered (patID)
)

declare @openJournalProblems as table (
    journalID bigint
  , idx       bigint identity(1,1)
  , pracID    bigint
  , pracName  varchar(1000)
  , retState  int
  , retStatus varchar(500)
  , problem   varchar(1000)
  unique clustered (journalID,idx)
)

declare @journalsToClose as table (
    idx        bigint identity(1,1)
  , journalID  bigint
  , clientID   bigint
  , clientName varchar(512)
  , patID      bigint
  , patName    varchar(512)
  , dos        date
  , userID     bigint
  , userGroup  int
  , userRank   int
  , userIP     varchar(500)
  , pracID     bigint
  unique clustered (idx)
)

declare @openJournalActivityTemp as table (
    journalID        bigint
  , activityUserID   bigint
  , activityDateTime datetime
)

/*=======================================================================================================
 |                                       Create scalar vars
 =========================================================================================================*/

declare @today                     as datetime
declare @numIdleDaysBeforeClose    as int
declare @numIdleDaysBeforeFollowup as int

/*========================================================================================================
 |                                              Init
 =========================================================================================================*/

set @today                     = GETDATE()
set @numIdleDaysBeforeFollowup = 3 
set @numIdleDaysBeforeClose    = 5

/*========================================================================================================
 |                    Retrieve and generate detail data rows for current open journals
 =========================================================================================================*/

insert into @openJournalDetailData
select 

  /*###########################################################################
    # Journal and entries data
    ###########################################################################*/

    journalID        = sj.id
  , entryID          = sjee.id
  , clientID         = sj.clientID
  , dos              = sj.dos 
  , journalCreatedOn = sj.created
  , journalCreatedBy = sj.createdBy
  , journalLastModOn = sj.lastModified
  , journalLastModBy = sj.lastModifiedBy
  , patID            = sj.patID
  , pracID           = sjee.pracID
  , entryCreatedOn   = sjee.created
  , entryCreatedBy   = sjee.createdBy
  , entryLastModOn   = sjee.lastModified
  , entryLastModBy   = sjee.lastModifiedBy
  
  /*###########################################################################
    # Generate counter values (these will be summed later)
    ###########################################################################*/

  , contStartCtr = convert ( int, case when (sjet.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY()) then 1 else 0 end )
  , contBreakCtr = convert ( int, case when (sjet.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY())   then 1 else 0 end )
  , contEndCtr   = convert ( int, case when (sjet.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY())   then 1 else 0 end )
  , nonContCtr   = convert ( int, case when (sjet.contSvcGroupPart is null)                                             then 1 else 0 end )
  
from dbo.SvcJournals               as sj
join dbo.SvcJournal_Event_Entries  as sjee on sjee.journalID      = sj.id
join dbo.SvcJournal_Event_Types    as sjet on sjet.id             = sjee.eventType
join dbo.CLIENTS_Client            as clc  on clc.CLIENT_ID       = sj.clientID

where (
      (1=1)  
  and ((@clientID is null) or (sj.clientID  = @clientID))
  and (sj.active    = 1)
  and (sjee.active  = 1)
  and (sj.completed = 0)
  and (sj.patAbsent = 0)
  and (clc.LEA      = 1)  
)

/*========================================================================================================
 |                                     Create initial summary rows
 =========================================================================================================*/

insert into @openJournalSummaryData

select
  
    journalID
  , clientID

  /*###########################################################################
    # Init last activity values.  Values will be computed and assigned later.
    ###########################################################################*/
 
  , lastActivityUserID    = null
  , lastActivityUserGroup = null
  , lastActivityUserRank  = null
  , lastActivityDateTime  = null
  , lastActivityUID       = null
  , lastActivityIP        = null
  , lastActivityPracID    = null
  , lastActivityDaysAgo   = null
 
  /*###########################################################################
    # Total types of entry
    ###########################################################################*/

  , totContStart
  , totContBreak
  , totContEnd
  , totNonCont

  /*###########################################################################
    # Total number of entries
    ###########################################################################*/

  , totCombined = totContStart 
                + totContBreak 
                + totContEnd 
                + totNonCont
  
  /*###########################################################################
    # Assign values to action flags.  Flags assigned nulls will be assigned
    # values later.  Flags assigned 0 will be updated later if applicable.
    ###########################################################################*/

  , noEntries           = null
  , incompleteCont      = convert(bit, case when (totContStart != totContEnd) then 1 else 0 end)
  , canStillEdit        = 0
  , numValidateWarn     = 0
  , numValidateErr      = 0
  , canidateForFollowup = 0
  , canidateForClose    = 0
  
from (

  select
      clientID
    , journalID
    , totContStart = sum (contStartCtr)
    , totContBreak = sum (contBreakCtr)
    , totContEnd   = sum (contEndCtr)
    , totNonCont   = sum (nonContCtr)

  from ( 
    select * from @openJournalDetailData 
  ) as q1
  
  group by 
      clientID
    , journalID
  
) as q2

/*========================================================================================================
 |            For each open journal summary row determine if the journal has entries
 =========================================================================================================*/

update @openJournalSummaryData set noEntries = 1 where (totCombined = 0)
update @openJournalSummaryData set noEntries = 0 where (totCombined > 0)

/*========================================================================================================
 |                           Get additional detail data for each open journal
 =========================================================================================================*/

/*###########################################################################
  # Get distinct journal ids, journal created by and journal last mod data 
  # from the detail data we retrieved and stored earlier and store 
  ###########################################################################*/

insert into @openJournalData
select distinct
    journalID
  , clientID
  , patID
  , dos
  , journalCreatedBy
  , journalCreatedOn
  , journalLastModBy
  , journalLastModOn
from @openJournalDetailData

/*###########################################################################
  # Client data
  ###########################################################################*/

insert into @openJournalClientData
select distinct
   clientID 
 , clientName = clc.CLIENT_NAME
from @openJournalData   as ojd 
join dbo.CLIENTS_Client as clc on clc.CLIENT_ID = ojd.clientID

/*###########################################################################
  # Patient data
  ###########################################################################*/

insert into @openJournalPatData
select distinct 
   patID 
 , patName = pap.CONCAT_NAME
from @openJournalData     as ojd 
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = ojd.patID

/*========================================================================================================
 |  For each open journal summary row determine the last activity userid and datetime for each open journal
 =========================================================================================================*/

/*###########################################################################
  # Break out the journal id and journal createdby data and store
  #
  # This is the 1/4 pairs of data considered in calculating latest activitiy
  ###########################################################################*/

insert into @openJournalActivityTemp
select 
    journalID
  , journalCreatedBy
  , journalCreatedOn
from @openJournalData

/*###########################################################################
  # Break out the journal id and journal last mod data and store
  #
  # This is the 2/4 pairs of data considered in calculating latest activitiy
  ###########################################################################*/

insert into @openJournalActivityTemp
select 
    journalID
  , journalLastModBy
  , journalLastModOn
from @openJournalData
where (journalLastModBy is not null)

/*###########################################################################
  # Get the latest journal entry created by data and store
  #
  # This is the 3/4 pairs of data considered in calculating latest activitiy
  ###########################################################################*/

insert into @openJournalActivityTemp

select 
    journalID
  , ecb.*
from @openJournalData as ojsd

cross apply (
  
  select top 1 
      activityUserID   = entryCreatedBy 
    , activityDateTime = entryCreatedOn

  from @openJournalDetailData 
  where (journalID = ojsd.journalID)
  order by 
    entryCreatedOn desc
) as ecb

/*###########################################################################
  # Get the latest journal entry last mod by data and store
  #
  # This is the 4/4 pairs of data considered in calculating latest activitiy
  ###########################################################################*/

insert into @openJournalActivityTemp
select *
from
(
  select 
      journalID
    , emb.*

  from @openJournalData as ojsd

  cross apply (
    select top 1 
        activityUserID   = entryLastModBy 
      , activityDateTime = entryLastModOn
    from @openJournalDetailData 
    where (journalID = ojsd.journalID)
    order by 
      entryLastModOn desc
  ) as emb
) as q1 
where (activityUserID is not null)

/*###########################################################################
  # Find the latest pair of data (with respect to date) in the 4 pairs of 
  # data we collected for each journal and update the journal summary data
  # accordingly.
  ###########################################################################*/

update ojsd
  set 
     ojsd.lastActivityUserID   = glad.activityUserID
    ,ojsd.lastActivityDateTime = glad.activityDateTime
   
  from @openJournalSummaryData as ojsd
  join (
    select  
       oj.journalID
     , ja.*
    from @openJournalData as oj
    cross apply (
      select top 1 
          activityUserID
        , activityDateTime
      from @openJournalActivityTemp
      where (journalID = oj.journalID)
      order by 
        activityDateTime desc
  ) as ja

) as glad on glad.journalID = ojsd.journalID

/*========================================================================================================
 |  For each open journal summary row retrieve data about the last activity userid 
 =========================================================================================================*/

update ojsd
set 
     ojsd.lastActivityIP        = ud2.userIP
   , ojsd.lastActivityPracID    = ud2.pracID  
   , ojsd.lastActivityUserGroup = ud2.userGroup
   , ojsd.lastActivityUserRank  = ud2.userRank

from @openJournalSummaryData as ojsd
  
join (
 
  select 
      ud1.*
    , pracID = prp.PRACTITIONER_ID
  
  from (
  
    select  
        userIdVal = oju.lastActivityUserID    
      , userIdUid = u.UserId
      , userIP    = uwbl.UserIP
      , userGroup = rd.userGroup
      , userRank  = rd.rank
    from (
      select distinct lastActivityUserID from @openJournalSummaryData
    ) as oju
     
    join users.dbo.Users        as u  on u.userrid = oju.lastActivityUserID
    join users.dbo.UsersInRoles as ur on ur.UserId = u.UserId
    join users.dbo.Roles        as r  on r.RoleId  = ur.RoleId
    join users.dbo.RoleData     as rd on rd.RoleId = r.RoleId 
    
    cross apply ( 
      select top 1
         UserIP 
      from users.dbo.WEB_BROWSER_LOG 
      where 
        (UserID = u.UserId) 
      order by 
         id desc
     ) as uwbl
  ) as ud1
  
  join dbo.PRACTITIONER_Practitioner as prp on prp.PRAC_ASP_ID = ud1.userIdUid
  ) 
as ud2 on ud2.userIdVal = ojsd.lastActivityUserID

/*========================================================================================================
 | For each open journal summary row compute the number of days the journal has been idle with respect
 | to the current datetime (set earlier)
 =========================================================================================================*/

update @openJournalSummaryData 
set lastActivityDaysAgo = DATEDIFF(day,lastActivityDateTime,@today)

/*========================================================================================================
 |                 For each open journal summary row call the can edit function
 =========================================================================================================*/

update @openJournalSummaryData
set canStillEdit = isnull(dbo.SvcJournal_Can_Edit (null,null,null,clientID, journalID),0)
    
/*========================================================================================================
 |         For each open journal summary row call the validate function and store the results
 =========================================================================================================*/

insert into @openJournalProblems
select 
  sjv.* 
from @openJournalSummaryData as ojsd
cross apply ( 
  select * 
  from dbo.SvcJournal_Journal_Validate (null,null,null,ojsd.clientID,ojsd.journalID)
) as sjv

/*========================================================================================================
 |      For each open journal summary row update the validate warn counts using the validate results
 =========================================================================================================*/

update ojsd
  set ojsd.numValidateWarn = jwrn.numOf
from @openJournalSummaryData as ojsd
join (
  select 
      journalID
    , numOf = COUNT(journalID) 
  from @openJournalProblems 
  where 
    (retState = dbo.CONST_RET_WARN())
  group by journalID
) as jwrn on jwrn.journalID = ojsd.journalID

/*=======================================================================================================
 |      For each open journal summary row update the validate error counts using the validate results
 =========================================================================================================*/

update ojsd
  set ojsd.numValidateErr = jerr.numOf
from @openJournalSummaryData as ojsd
join (
  select 
      journalID
    , numOf = COUNT(journalID) 
  from @openJournalProblems
  where 
    (retState = dbo.CONST_RET_ERR())
  group by journalID
) as jerr on jerr.journalID = ojsd.journalID


/*=======================================================================================================
 |                   Determine what open journals rows are canidates for followup
 =========================================================================================================*/

update @openJournalSummaryData 
  set canidateForFollowup = 1
where ( 
      ((noEntries = 1) or (incompleteCont = 1) or (numValidateWarn > 0) or (numValidateErr > 0))
  and (lastActivityDaysAgo >= @numIdleDaysBeforeFollowup)
)

/*=======================================================================================================
 |                  Determine what open journals rows are canidates for closure.
 =========================================================================================================*/

update @openJournalSummaryData 
  set canidateForClose = 1
where ( 
      (canStillEdit   = 1)
  and (numValidateErr = 0)
  and (noEntries      = 0) 
  and (incompleteCont = 0) 
  and (lastActivityDaysAgo >= @numIdleDaysBeforeClose)
)

/*=======================================================================================================
 |                                            Break out data
 =========================================================================================================*/

insert into @journalsToClose
select  
   ojsd.journalID
  ,ojd.clientID 
  ,ojcd.clientName
  ,ojd.patID
  ,ojpad.patName
  ,ojd.dos
 , userID    = ojsd.lastActivityUserID
 , userGroup = ojsd.lastActivityUserGroup
 , userRank  = ojsd.lastActivityUserRank
 , userIP    = ojsd.lastActivityIP
 , pracID    = ojsd.lastActivityPracID

from @openJournalSummaryData as ojsd
join @openJournalData        as ojd   on ojd.journalID = ojsd.journalID
join @openJournalClientData  as ojcd  on ojcd.clientID = ojd.clientID
join @openJournalPatData     as ojpad on ojpad.patID   = ojd.patID

where ( 
  (canidateForClose = 1)
)
order by 
    clientID
  , patID
  , dos

/*=======================================================================================================
 |                                      Create data document
 =========================================================================================================*/

set @data = (

  select    
  
      (select @today                      as "*" for xml path ('today')                     , type)
    , (select @numIdleDaysBeforeFollowup  as "*" for xml path ('numIdleDaysBeforeFollowup') , type)
    , (select @numIdleDaysBeforeClose     as "*" for xml path ('numIdleDaysBeforeClose')    , type)
    
    , (select * from @journalsToClose        for xml path ('JournalToCloseRow')     , root ('JournalToCloseRows')     , type)
    , (select * from @openJournalSummaryData for xml path ('OpenJournalSummaryRow') , root ('OpenJournalSummaryRows') , type)
    , (select * from @openJournalDetailData  for xml path ('OpenJournalDetailRow')  , root ('OpenJournalDetailRows')  , type)

  for xml path ('SvcJournalOpenJournalsData'), type
)

/*=======================================================================================================
 |                                       Return data document
 =========================================================================================================*/

return @data

end
GO

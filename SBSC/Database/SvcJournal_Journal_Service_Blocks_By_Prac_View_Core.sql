USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Service_Blocks_By_Prac_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Service_Blocks_By_Prac_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Service_Blocks_By_Prac_View_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @journalID         BIGINT
  , @pracID            BIGINT 
)    

returns

@rows table (
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
 , entryNotes           varchar(max)
 , contStartNotes       varchar(max)
 , contEndNotes         varchar(max)
 , contRowNum           bigint
 , startTimeRound15     time(0)
 , endTimeRound15       time(0)
 , numMins              int
 , numMinsRound15       int
 
)
begin
 
 /***************************************************************************    
  * SvcJournal_Journal_Service_Blocks_By_Prac_View_Core */    
 /**    
  * Returns a list of journal entries
  *
  * @return table 
  ***************************************************************************/                         
     
declare @entries as table (
    journalID             bigint
  , dos                   date
  , patID                 bigint
  , patAbsent             bit
  , entryIEP              bit
  , entryID               bigint
  , pracID                bigint
  , userID                bigint
  , entryStartTime        time(0)
  , entryEndTime          time(0)  
  , orpDocID              bigint
  , eventTypeParentID     bigint
  , eventLabelParent      varchar(1000)
  , eventTypeID           bigint
  , eventLabel            varchar(1000)
  , contSvcGroupPart      bigint
  , entryNotes            varchar(max) 
  , standAloneNonBillSvc       bit 
  , eventSequence              int
  , contSvcEventSequence       int
  , overlapsContSvcByNumMins   int
)

declare @contSvcBlocks as table (
   journalID         bigint
 , dos               date
 , patID             bigint
 , patAbsent         bit
 , iep               bit
 , startTime         time(0)
 , endTime           time(0)
 , orpDocID          bigint
 , eventTypeID       bigint
 , eventTypeLabel    varchar(1000)
 , pracID            bigint
 , userID            bigint
 , entryNotes        varchar(max)
 , contStartNotes    varchar(max)
 , contEndNotes      varchar(max)
 , contRowNum        bigint   
)

/*###########################################################################
  # Get journal entries
  ###########################################################################*/

insert into @entries
  select 
      sj.id                       as journalID
    , sj.dos                      as dos
    , sj.patID                    as patID
    , sj.patAbsent                as patAbsent
    , sjee.iep                    as entryIEP
    , sjee.id                     as entryID
    , sjee.pracID                 as pracID
    , sjee.createdBy              as userID
    , sjee.entryStartTime         as entryStartTime
    , sjee.entryEndTime           as entryEndTime
    , sjee.orpDocID               as orpDocID
    , sjet.parentID               as eventTypeParentID
    , sjetp.eventLabel            as eventLabelParent
    , sjee.eventType              as eventTypeID
    , sjet.eventLabel             as eventLabel
    , sjet.contSvcGroupPart       as contSvcGroupPart
    , entryNotes                  = ''
	                              + convert(varchar(max),iif(orpd.name is null, N'', 'Service: ' + orpd.name))
                                  + char(13)
								  + convert(varchar(max),(isnull(fbQA2.entryNotesFormBuilderText,N'')))
                                  + char(13)
								  + convert(varchar(max),(isnull(ncQA2.noteCriteriaText,N'')))
								  + char(13)
								  + '* Additional Notes: ' + isnull(sjee.entryNotes,'')
    , sjet.standAloneNonBillSvc   as standAloneNonBillSvc   
    , eventSequence              = DENSE_RANK() OVER (order by sjee.entryStartTime, sjee.entryEndTime, sjee.id) 
    , contSvcEventSequence       = null
    , overlapsContSvcByNumMins   = null

  from dbo.SvcJournals              as sj
  join dbo.SvcJournal_Event_Entries as sjee on sjee.journalID = sj.id
  join dbo.SvcJournal_Event_Types   as sjet on sjet.id        = sjee.eventType
  left join dbo.ORP_DOCUMENTS_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, null, null, null, null, null, null, null) as orpd on orpd.id = sjee.orpDocID
  
  outer apply (select top 1 * from dbo.SvcJournal_Event_Types as et where et.id = sjet.parentID) as sjetp
  
  outer apply (
      select top 1 
        entryNotesFormBuilderText = dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT ( fbQA1.entryNotesFormBuilderQuestionsJSON
                                                                          , fbQA1.entryNotesFormBuilderAnswersJSON
                                                                          , 1
                                                                          , 0
                                                                          , 1
                                                                          , 0
																		  , 1
																		  , 0)
      from dbo.SvcJournal_Event_Entries_Form_Builder_Data as fbQA1
      where 
        (fbQA1.entryID = sjee.id)
    ) as fbQA2

  outer apply (
      select top 1 
        noteCriteriaText = dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT (    ncQA1.noteCriteriaQuestionsJSON
                                                                    , ncQA1.noteCriteriaAnswersJSON
                                                                    , 1
                                                                    , 0
                                                                    , 1
                                                                    , 0
																	, 1
																	, 0)
      from dbo.SvcJournal_Event_Entries_Note_Criteria_Questions_Answers as ncQA1
      where 
        (ncQA1.entryID = sjee.id)
  ) as ncQA2

  
  where (
        (sj.clientID = @clientID)
    and (sj.id       = @journalID)   
    and (sj.active   = 1)
    and (sjee.pracID = @pracID)
    and (sjee.active = 1)  
  )

 /*###########################################################################
   # Get first and last cont entry note of the day and get orpDoc for cont
   ###########################################################################*/

 declare @startContNote     as varchar(max) = null
 declare @startContOrpDocID as bigint       = null
 declare @endContNote       as varchar(max) = null
  
 select top 1
     @startContNote     = t1.entryNotes
   , @startContOrpDocID = t1.orpDocID
 from @entries as t1
 where (
       (t1.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY())
   and (t1.standAloneNonBillSvc = 0)
 )

 select top 1
     @endContNote     = t1.entryNotes   
 from @entries as t1
 where (
       (t1.contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY())
   and (t1.standAloneNonBillSvc = 0)
)

/*###########################################################################
  # Determine sequence of continous monitoring events 
  ###########################################################################*/

update je1  
  set je1.contSvcEventSequence = je3.contSvcEventSequence
from @entries as je1
join (
  select 
      je2.entryID
    , contSvcEventSequence = DENSE_RANK() OVER (order by je2.entryStartTime, je2.entryEndTime, je2.entryID)
    from @entries as je2
    where ((je2.contSvcGroupPart is not null) and (je2.standAloneNonBillSvc = 0))
) as je3 on je3.entryID = je1.entryID

/*###########################################################################
  # Compute continuous service blocks
  ###########################################################################*/

insert into @contSvcBlocks
select
	 curr.journalID         as journalID
   , curr.dos               as dos
   , curr.patID             as patID
   , curr.patAbsent         as patAbsent
   , curr.entryIEP          as iep
   , prev.entryEndTime      as startTime
   , curr.entryStartTime    as endTime
   , @startContOrpDocID     as orpDocID
   , curr.eventTypeParentID as eventTypeID
   , curr.eventLabelParent  as eventTypeLabel 
   , curr.pracID            as pracID
   , curr.userID            as userID      
   , curr.entryNotes        as entryNotes
   , @startContNote         as contStartNotes
   , @endContNote           as contEndNotes
   , prev.contSvcEventSequence  as contRowNum

from      @entries as curr
left join @entries as prev on (prev.contSvcEventSequence = (curr.contSvcEventSequence - 1))
                           and (prev.standAloneNonBillSvc = 0)
where ( 
      (prev.entryEndTime is not null)
  and (curr.standAloneNonBillSvc = 0)
)

/*###########################################################################
  # Determine overlaps with continous service blocks
  ###########################################################################*/

update je    
  set je.overlapsContSvcByNumMins = overlaps.numMins
from @entries as je
cross apply (
  select 
    co2.numMins 
  from @contSvcBlocks as stb1
  cross apply (
    select 
	  co1.numMins
	from dbo.CALC_OVERLAP_TIME_AB_CD (je.entryStartTime, je.entryEndTime,stb1.startTime, stb1.endTime) as co1
  ) as co2
) as overlaps
where (
      (je.contSvcGroupPart is null) 
  and (je.standAloneNonBillSvc = 0)
)

/*###########################################################################
  # Take care of non overlaps
  ###########################################################################*/

update je    
  set je.overlapsContSvcByNumMins = 0
from @entries as je
where (
      (je.contSvcGroupPart is null)
  and (je.standAloneNonBillSvc = 0)
  and (je.overlapsContSvcByNumMins is null)
)

;
with
/*###########################################################################
  # Continuous service blocks
  ###########################################################################*/

cte_cont_blocks
as
(
  select * from @contSvcBlocks
)
,

/*###########################################################################
  # Continous service block breaks
  ###########################################################################*/

cte_cont_break_blocks
as
(
  select 
      journalID      as journalID
    , dos            as dos
    , patID          as patID
    , patAbsent      as patAbsent
    , entryIEP       as iep
    , entryStartTime as startTime
    , entryEndTime   as endTime
    , null           as orpDocID
    , eventTypeID    as eventTypeID
    , eventLabel     as eventLabel
    , pracID         as pracID
    , userID         as userID
    , entryNotes     as entryNotes
    , null as contStartNotes
    , null as contEndNotes
    , null as contRowNum
  from @entries  
  where ( 
       (contSvcGroupPart = dbo.CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY())
   and (standAloneNonBillSvc = 0)
  )
)
,

/*###########################################################################
  # Non continuous service blocks with NO overlap into continious svcs
  ###########################################################################*/

cte_non_cont_blocks_no_overlap
as
(
  select 
      je.journalID      as journalID
    , je.dos            as dos
    , je.patID          as patID
    , je.patAbsent      as patAbsent
    , je.entryIEP       as iep
    , je.entryStartTime as startTime
    , je.entryEndTime   as endTime
    , je.orpDocID       as orpDocID
    , je.eventTypeID    as eventTypeID
    , je.eventLabel     as eventLabel
    , je.pracID         as pracID
    , je.userID         as userID
    , je.entryNotes     as entryNotes
    , null           as contStartNotes
    , null           as contEndNotes
    , null           as contRowNum
  from @entries as je
  where (
      (je.contSvcGroupPart is null) 
  and (je.overlapsContSvcByNumMins = 0)
  and (je.standAloneNonBillSvc = 0)
  )

)
,

/*###########################################################################
  # Non continuous service blocks WITH overlap into continious svcs
  ###########################################################################*/

cte_non_cont_blocks_with_overlap
as
(
  select 
      je.journalID      as journalID
    , je.dos            as dos
    , je.patID          as patID
    , je.patAbsent      as patAbsent
    , je.entryIEP       as iep
    , je.entryStartTime as startTime
    , je.entryEndTime   as endTime
    , je.orpDocID       as orpDocID
    , je.eventTypeID    as eventTypeID
    , je.eventLabel     as eventLabel
    , je.pracID         as pracID
    , je.userID         as userID
    , je.entryNotes     as entryNotes
    , null              as contStartNotes
    , null              as contEndNotes
    , null              as contRowNum
  from @entries as je
  where (
        (je.contSvcGroupPart is null) 
    and (je.overlapsContSvcByNumMins != 0)
    and (je.standAloneNonBillSvc = 0)
  )

)
,

/*###########################################################################
  # Stand alone non billable service blocks
  #
  # Note: These are entries like RMTS and additional notes
  #       and they can overlap with anything
  ###########################################################################*/

cte_stand_alone_blocks
as
(
  select 
      journalID      as journalID
    , dos            as dos
    , patID          as patID
    , patAbsent      as patAbsent
    , entryIEP       as iep
    , entryStartTime as startTime
    , entryEndTime   as endTime
    , orpDocID       as orpDocID
    , eventTypeID    as eventTypeID
    , eventLabel     as eventLabel
    , pracID         as pracID
    , userID         as userID
    , entryNotes     as entryNotes
    , null           as contStartNotes
    , null           as contEndNotes
    , null           as contRowNum
  from @entries
  where (
        (contSvcGroupPart is null) 
	and (standAloneNonBillSvc = 1)
  )
)
,
/*###########################################################################
  # Combine 
  ###########################################################################*/

cte_blocks_p1
as
(
  select 
      insideContBlock      = convert(bit,0)
	, standAloneNonBillSvc = convert(bit,0)
	, contBlock            = convert(bit,1)
	, breakInCare          = convert(bit,0)
	, t1.* 
  from cte_cont_blocks as t1
  
  union all

  select 
      insideContBlock      = convert(bit,0)
	, standAloneNonBillSvc = convert(bit,0)
    , contBlock            = convert(bit,1)
	, breakInCare          = convert(bit,1)
	, t2.* 
  from cte_cont_break_blocks as t2

  union all

  select 
        insideContBlock      = convert(bit,0)
	  , standAloneNonBillSvc = convert(bit,0)
	  , contBlock            = convert(bit,0)
	  , breakInCare          = convert(bit,0)
	  , t3.* 
  from cte_non_cont_blocks_no_overlap as t3
  
  union all
  
  select 
        insideContBlock      = convert(bit,1)
	  , standAloneNonBillSvc = convert(bit,0)
	  , contBlock            = convert(bit,0)
	  , breakInCare          = convert(bit,0)
	  , t4.* 
  from cte_non_cont_blocks_with_overlap as t4

  union all

  select 
       insideContBlock      = convert(bit,0)
	 , standAloneNonBillSvc = convert(bit,1)
	 , contBlock            = convert(bit,0)
	 , breakInCare          = convert(bit,0)
	 , t5.* 
  from cte_stand_alone_blocks as t5

)
,

/*###########################################################################
  # Generate rounded (to nearest 15 minute) start and end time columns
  # and calculate actual minutes
  ###########################################################################*/

cte_blocks_p2
as
(
  select 
      p1.*
    , startTimeRound15 = dbo.TIME_ROUND_15_MIN(p1.startTime,1)
    , endTimeRound15   = dbo.TIME_ROUND_15_MIN(p1.endTime , 1)
    , numMins          = datediff(minute, p1.startTime, p1.endTime)
  from cte_blocks_p1 as p1
)
,

/*###########################################################################
  # Calculate rounded minutes using rounded start and end
  ###########################################################################*/

cte_blocks_p3
as
(
  select 
    p2.* 
   , numMinsRound15 = datediff(minute,p2.startTimeRound15, p2.endTimeRound15)
  from cte_blocks_p2 as p2
)


insert into @rows
select * from cte_blocks_p3

return

end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Service_Blocks_By_Prac_View_Core] TO [webuser]
GO  

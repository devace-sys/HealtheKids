USE SPEDMON
GO

/* TODO: Modify this proc to break events recorded inside cont mon block into their own non billable svc recs */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Service_Blocks_And_Procedure_Data_Combined_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Service_Blocks_And_Procedure_Data_Combined_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Service_Blocks_And_Procedure_Data_Combined_View_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @journalID         BIGINT
  , @reference         VARCHAR(500)
)    

RETURNS @recs table (
    idx                  bigint identity(1,1)
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
as
begin

/*=======================================================================================================
 |                                     Setup Table Variables
 =========================================================================================================*/

/*###########################################################################
  # svcBlockAndProcData
  #
  # This var contains all of the service blocks that apply to this journal
  ###########################################################################*/

declare @svcBlockAndProcData as table (
    idx                  bigint identity(1,1)
  , patID                bigint
  , dos                  datetime
  , pracID               bigint
  , procID               bigint
  , nameID               bigint
  , startTime            time(0)
  , endTime              time(0)
  , orpDocID             bigint
  , orpDocReq            bit
  , numMins              int
  , planType             int
  , iep                  bit
  , patAbsent            bit
  , userID               bigint
  , userGroup            int
  , userRank             int
  , eventTypeLabel       varchar(200)
  , entryNotes           varchar(max)
  , contBlock            bit
  , insideContBlock      bit
  , standAloneNonBillSvc bit
  , notesForBlock        varchar(max)
)


/*###########################################################################
  # Encounters by prac
  #
  #
  ###########################################################################*/

declare @encountersByPrac table (
    idx            bigint identity(1,1)
  , dos            datetime
  , startTime      time(0)
  , endTime        time(0)
  , pracID         bigint
  , iep            bit
  , patID          bigint
  , patAbsent      bit
  , userID         bigint
  , userGroup      int
  , userRank       int
  , procID         bigint
  , nameID         bigint
  , orpDocReq      bit
  , orpDocID       bigint
  , numMins        int
  , notes          varchar(max)
  , contSvcBlock   bit
  , claimableBlock bit
)

/*=======================================================================================================
 |                        Get all service blocks and generate notes for block
 =========================================================================================================*/

insert into @svcBlockAndProcData
select 
    t1.patID
  , t1.dos       
  , t1.pracID    
  , t1.procID    
  , t1.nameID    
  , t1.startTime 
  , t1.endTime
  , t1.orpDocID
  , t1.orpDocReq   
  , t1.numMins   
  , t1.planType  
  , t1.iep       
  , t1.patAbsent 
  , t1.userID    
  , t1.userGroup 
  , t1.userRank  
  , t1.eventTypeLabel 
  , entryNotes = isnull(t1.entryNotes,'')
  , t1.contBlock     
  , t1.insideContBlock 
  , t1.standAloneNonBillSvc
  , notesForBlock = ''
from dbo.SvcJournal_Journal_Service_Blocks_And_Procedure_Data_View_Core (  @userID
                                                                         , @userGroup
                                                                         , @userRank
                                                                         , @clientID
                                                                         , @journalID ) as t1

update @svcBlockAndProcData
set notesForBlock = '* ' 
                  + isnull(convert(varchar,startTime,100),'')
                  + ' - ' 
                  + isnull(convert(varchar,endTime,100),'')
                  + ' -- '
                  + isnull(eventTypeLabel,'') 
		          + char(13)
		          + entryNotes
				  + char(13)

/*=======================================================================================================
 |                        Get all cont svc block encounters by practitioner
 |                        The prac can possibly bill for these encounters
 |  Exclude the stand alone non billable since these are just notes or tags for items like RMTS moments
 |                                      We will add these later
 =========================================================================================================*/

insert into @encountersByPrac
select   
      sb.dos
	, sb.startTime
	, sb.endTime
    , sb.pracID  
    , sb.iep
    , sb.patID
    , sb.patAbsent
    , sb.userID
    , sb.userGroup
    , sb.userRank
    , sb.procID
    , sb.nameID
    , sb.orpDocReq
    , sb.orpDocID
    , sb.numMins
    , notes = sb.notesForBlock
    , contSvcBlock   = 1
	, claimableBlock = 1
  from @svcBlockAndProcData as sb
  
  where ((sb.contBlock = 1) and (sb.insideContBlock = 0) and (sb.standAloneNonBillSvc = 0))
  
  order by 
      sb.dos
	, sb.startTime
	, sb.endTime
    , sb.pracID  

/*=======================================================================================================
 |  Get all encounters inside cont svc block by practioner 
 |  The prac cannot bill for these encounters since the prac is already providing a service.
 |  We included these however since we need to record the service seperately as non claimable
 |
 |  Exclude the stand alone non billable since these are just notes or tags for items like RMTS moments
 |                                      We will add these later
 =========================================================================================================*/

insert into @encountersByPrac
select   
      sb.dos
	, sb.startTime
	, sb.endTime
    , sb.pracID  
    , sb.iep
    , sb.patID
    , sb.patAbsent
    , sb.userID
    , sb.userGroup
    , sb.userRank
    , sb.procID
    , sb.nameID
    , sb.orpDocReq
    , sb.orpDocID
    , sb.numMins
    , notes = sb.notesForBlock
    , contSvcBlock   = 0
	, claimableBlock = 0
  from @svcBlockAndProcData as sb
  
  where ((sb.contBlock = 0) and (sb.insideContBlock = 1) and (sb.standAloneNonBillSvc = 0))
  
  order by 
    sb.startTime
  , sb.endTime


/*=======================================================================================================
 |  Get all encounters outside cont svc block by practioner
 |  The prac can possibly bill for these encounters 
 |
 |  Exclude the stand alone non billable since these are just notes or tags for items like RMTS moments
 |                                      We will add these later
 =========================================================================================================*/

insert into @encountersByPrac
select   
      sb.dos
	, sb.startTime
	, sb.endTime
    , sb.pracID  
    , sb.iep
    , sb.patID
    , sb.patAbsent
    , sb.userID
    , sb.userGroup
    , sb.userRank
    , sb.procID
    , sb.nameID
    , sb.orpDocReq
    , sb.orpDocID
    , sb.numMins
    , notes = sb.notesForBlock
    , contSvcBlock   = 0
	, claimableBlock = 1
  from @svcBlockAndProcData as sb
  
  where ((sb.contBlock = 0) and (sb.insideContBlock = 0) and (sb.standAloneNonBillSvc = 0))
  
  order by 
       sb.startTime
	 , sb.endTime

/*=======================================================================================================
 |  Find overlaps between same discipline pracs and same service rendered completely within cont mon blocks
 |  Set the blocks to non claimable since another prac is already providing the same service 
 |  and the cont mon svc takes priority.
 =========================================================================================================*/
 
 update t2
    set t2.claimableBlock = 0    
 from @encountersByPrac as t1
 join @encountersByPrac as t2 on t2.nameID = t1.nameID
                        and t2.procID = t1.procID
						and t2.pracID != t1.pracID
 where (
       (t1.contSvcBlock = 1)
   and (t2.contSvcBlock = 0)
   and (t1.claimableBlock = 1)
   and (t2.claimableBlock = 1)
   and (t2.startTime >= t1.startTime)
   and (t2.endTime <= t2.endTime)
 )

/*=======================================================================================================
 |  Find overlaps between same discipline pracs and same service rendered outside of cont mon blocks
 |  that have not already been set to non claimable
 =========================================================================================================*/
 
 /*
 select 
   q3.*
 from
 (
   select
       q1.t1Idx
     , q1.t2Idx
     , co2.*
   from
   (
      select 
         t1.idx        as t1Idx   
        ,t1.startTime  as t1StartTime
        ,t1.endTime    as t1EndTime
        ,t2.idx        as t2Idx
  	    ,t2.startTime  as t2StartTime
        ,t2.endTime    as t2EndTime
  
    from @encountersByPrac as t1
    join @encountersByPrac as t2 on t2.nameID  = t1.nameID
                                 and t2.procID = t1.procID
	       		  			  
							 
    where ( 
	      (t1.claimableBlock = 1) 
	  and (t2.claimableBlock = 1) 
	  and (t1.contSvcBlock = 0) 
	  and (t2.contSvcBlock = 0)
	  and (t2.pracID != t1.pracID)
	)
  ) as q1
  cross apply (
    select 
      co1.* 
    from dbo.CALC_OVERLAP_TIME_AB_CD (q1.t1StartTime, q1.t1EndTime, q1.t2StartTime, q1.t2EndTime) as co1
    where (co1.numMins != 0) /* Ignore adjacent*/
  ) as co2
) as q3
*/

/*=======================================================================================================
 | Now we include the stand alone non billable 
 | These are non claimable since these are just notes or tags for items like RMTS moments
 =========================================================================================================*/

insert into @encountersByPrac
select   
      sb.dos
	, sb.startTime
	, sb.endTime
    , sb.pracID  
    , sb.iep
    , sb.patID
    , sb.patAbsent
    , sb.userID
    , sb.userGroup
    , sb.userRank
    , sb.procID
    , sb.nameID
    , sb.orpDocReq
    , sb.orpDocID
    , sb.numMins
    , notes = sb.notesForBlock
    , contSvcBlock   = 0
	, claimableBlock = 0
  from @svcBlockAndProcData as sb
  
  where ((sb.contBlock = 0) and (sb.insideContBlock = 0) and (sb.standAloneNonBillSvc = 1))

insert into @recs
select 
    clientID           = @clientID
  , reference          = @reference
  , journalID          = @journalID
  , t1.dos
  , t1.iep
  , t1.patID
  , t1.patAbsent
  , t1.pracID
  , t1.userID
  , t1.userGroup
  , t1.userRank
  , t1.nameID
  , t1.procID
  , t1.numMins
  , t1.notes
  , t1.orpDocID  
  , t1.orpDocReq 
  , startTimeActual = t1.startTime
  , svcRecClaimable = t1.claimableBlock
from @encountersByPrac as t1

return

end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Service_Blocks_And_Procedure_Data_Combined_View_Core] TO [webuser]
GO  

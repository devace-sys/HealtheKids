USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_VIEW_CORE] (
    @userID                as   bigint
  , @userGroup             as   int
  , @userRank              as   int
  , @clientID              as   bigint
  , @groupSvcClassNameID   as   bigint
  , @pracID                as   bigint  
  , @patID                 as   bigint
  , @svcTypeID             as   bigint
  , @startDate             as   datetime
  , @endDate               as   datetime  
  , @startEntryDate        as   datetime
  , @endEntryDate          as   datetime      
  , @reference             as   varchar(500)
  , @canEdit               as   bit
  , @applyEditDelViewRules as   bit
  , @recID                 as   bigint)    
    
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_VIEW_CORE */    
/**    
 * Service records core view.  Keep this in synch with the index    
 *     
 * @param  clientID        Client ID (required)    
 * @param  pracID          Practitioner ID    
 * @param  patID           PatientID    
 * @param  recID           Service record, record id (will only return one record)    
 * @return                 Service records    
 ***************************************************************************/     
    
return (    
with
cte_p1
as
(
  select 
    vdc.* 
  from dbo.SERVICE_RECORDS_DATA_CORE (@userID, @clientID, @groupSvcClassNameID, @pracID , @patID, @svcTypeID, @startDate , @endDate, @startEntryDate, @endEntryDate, @reference, @recID) as vdc
)
,
cte_p2
as
(
  select 
  
      p1.* 
    , srl.loggedOn                         as SRL_LOGGED_ON
    , srl.userID                           as SRL_USER_ID   
    , dbo.INT_HAS_VALUE (sre.id)           as canEdit
    , [endTimeVal]  = iif((p1.startTime is not null),dateadd(minute,p1.numMins,p1.startTime),null)
	, rmtsMomentVal = convert(bit,iif((rmts2.id is not null),1,0))

  from cte_p1 as p1

  left join dbo.SERVICE_RECORDS_VIEW_EDITABLE (  @clientID
                                               , @userID
                                               , @userGroup
                                               , @userRank
                                               , @applyEditDelViewRules) as sre on sre.id = p1.id
  outer apply (
    select top 1 
	    loggedOn
	  , userID 
    from dbo.SERVICE_RECORD_LAST_MODIFIED_BY() as lmb 
    where 
	 (lmb.svcRecID = p1.id)
  ) as srl 

  outer apply (
   select top 1 
     rmts1.id
   from dbo.SERVICE_RECORDS_RMTS_MOMENTS as rmts1
   where (rmts1.svcRecSvcProvided = p1.id)
   order by 
     rmts1.id desc
  ) as rmts2

)
,
cte_p3
as
(
  select 
      p2.* 
    , [dosStr]               = dbo.RPT_DATE_FMT (p2.dos)
    , [dosStrYMD]            = dbo.RPT_DATE_FMT_YYYY_MM_DD (p2.dos)
	, [startTimeStr]         = dbo.RPT_TIME_FMT (p2.startTime,0) 
    , [startTimeStrHHMM]     = dbo.RPT_TIME_FMT_HH_MM_SS (p2.startTime,0)  
	, [endTimeStr]           = dbo.RPT_TIME_FMT (p2.endTimeVal,0)
	, [endTimeStrHHMM]       = dbo.RPT_TIME_FMT_HH_MM_SS (p2.endTimeVal,0)  
	, [orpDocLabel]          = orp.name  
	, [isIFSPorIEPStr]       = dbo.RPT_BIT_TO_YN (p2.isIFSPorIEP)
	, [viaTelehealthStr]     = dbo.RPT_BIT_TO_YN (p2.viaTelehealth)
	, [tripsMiles]           = dbo.RPT_TRIPS_MILES (p2.svcType, p2.trip1Start, p2.trip1End, p2.trip2Start, p2.trip2End, p2.trip3Start, p2.trip3End, p2.trip4Start, p2.trip4End)     
    , [minutesStartEndMiles] = dbo.RPT_MINUTES_OR_START_END_MILES (p2.svcType,p2.numMins,p2.trip1Start, p2.trip1End, p2.trip2Start, p2.trip2End, p2.trip3Start, p2.trip3End, p2.trip4Start, p2.trip4End) 
	, [rmtsMomentStr]        = dbo.RPT_BIT_TO_YN(p2.rmtsMomentVal)
	, groupName              = isnull(gg2.groupName,N'')
	, pracGrpSvcClsName      = isnull(scn2.pracGrpSvcClsName,'')
	, set2.entryTypeName
	, [patDOBStr] = dbo.RPT_DATE_FMT (p2.PA_DOB)
	, csnamx2.nameIDAltModality
	, svcNameWithoutInPersonOrTelehealthText = dbo.SERVICE_NAME_REMOVE_IN_PERSON_AND_TELE_HEALTH_TEXT(p2.SVC_NAME)
  from cte_p2 as p2

  outer apply (
    select top 1 
	  orpvc.name 
    from dbo.ORP_DOCUMENTS_VIEW_CORE (null,null,null,null,null,null,null,null,null,null,p2.orpDocID) as orpvc 
    where (orpvc.id = p2.orpDocID)
  ) as orp
  
  outer apply (
    select top 1 
	  gg1.GROUP_NAME as groupName 
	from dbo.GROUP_Group as gg1 
	  where (gg1.GROUP_ID = p2.groupID)
  ) as gg2
  
  outer apply (
    select top 1
	  scn1.GROUP_SERVICE_CLASS_NAME as pracGrpSvcClsName 
	from dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as scn1 
	where 
	  (scn1.GROUP_SERVICE_CLASS_NAME_ID = p2.pracGrpSvcClsNameID)
  ) as scn2
  
  outer apply (
    select top 1
	  set1.Name as entryTypeName
	from dbo.SERVICE_RECORD_ENTRY_TYPES as set1 
	where 
	  (set1.ID = p2.entryType)
  ) as set2
 
 outer apply (
   select top 1 
     csnamx1.nameIDAltModality
   from dbo.CLAIM_SERVICE_NAME_ALT_MODALITY_XREF as csnamx1
   where (
         (csnamx1.groupID    = p2.groupID)
     and (csnamx1.planTypeID = p2.planType)
     and (csnamx1.nameID     = p2.nameID)
   )
 ) as csnamx2

 where (
        (1=1) 
    and ((@canEdit is null) or (p2.canEdit = @canEdit))
  )
)
select
  p3.* 
from cte_p3 as p3

)
GO

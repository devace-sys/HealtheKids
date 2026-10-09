
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW_CORE] (
    @clientID          as    bigint
  , @siteID            as    bigint
  , @reviewingPracID   as    bigint
  , @renderingPracID   as    bigint
  , @patID             as    bigint
  , @startDate         as    datetime
  , @endDate           as    datetime
  , @reviewed          as    bit
  , @approved          as    bit
)      
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW_CORE */    
/**    
 *     
 ***************************************************************************/     
    
return (    

with 
cte_p0
as
(
  select top 1
    minStartDate = convert(datetime, '1/1/1990 00:00:00')
  , maxEndDate   = convert(datetime, '12/31/9999 23:59:59')
)
,
cte_p1
as
(
  select top 1    
      startDate = convert(datetime,(isnull(@startDate, p0.minStartDate)))
    , endDate   = convert(datetime,(isnull(@endDate,   p0.maxEndDate)))
  from cte_p0 as p0
)
,
cte_p2
as
(
  select 
    t2.* 
  from cte_p1 as p1
 
  cross apply (
 
    select  
        t1.id
      , t1.clientID
      , t1.renderingPracID
  	  , t1.svcRecID
      , t1.assignedToPracID
      , t1.assignedOn
      , t1.reviewed
      , t1.reviewedOn
      , t1.reviewedByPracID
      , t1.reviewedByName
      , t1.reviewedByTitle
      , t1.approved  
      , t1.notes
    from dbo.SERVICE_RECORDS_INTERNAL_REVIEWS as t1
  
    where (
          (t1.clientID  = @clientID)
      and ((@reviewingPracID is null) or (t1.assignedToPracID = @reviewingPracID))
	  and (t1.reviewed = @reviewed)
      and ((@approved        is null) or (t1.approved = @approved))
      and ((@renderingPracID is null) or (t1.renderingPracID = @renderingPracID))
      and (t1.assignedOn between p1.startDate and p1.endDate)
	  and (t1.active = 1)
    )
  ) as t2
)
select 
    p2.* 
  , sr.siteID
  , renderingGroupID             = sr.groupID
  , renderingGroupSvcClassNameID = sr.pracGrpSvcClsNameID
  , sr.patID
  , sr.dos
  , svcNameID = sr.nameID
  , sr.attendanceSelectionID
  , sr.numMins
  , sr.planType
  , sr.svcType
  , sr.nameIDAliasID  
  , sr.hasSvcDetFlags
  , sr.svcDetFlag1
  , sr.svcDetFlag2
  , sr.svcDetFlag3
  , sr.svcDetFlag4

  , svcNotes = isnull(sr.notes,'')  
  , srfbd2.svcNotesFormBuilderText
  , srfbd2.svcNotesPatientGoalProgressText

from cte_p2              as p2
join dbo.SERVICE_RECORDS as sr on sr.id = p2.svcRecID

outer apply (
 select top 1 
	  [svcNotesFormBuilderText]         = convert(varchar(max),(isnull(srfbd1.svcNotesFormBuilderTextSaved,N'')))
	, [svcNotesPatientGoalProgressText] = convert(varchar(max),(isnull(srfbd1.patientGoalProgressTextSaved,N'')))  
  from dbo.SERVICE_RECORDS_FORM_BUILDER_DATA as srfbd1
  where 
    (srfbd1.svcRecID = p2.svcRecID)
) as srfbd2

where ( 
      (sr.[state] not in (99,199))
  and ((@siteID is null)  or (sr.siteID = @siteID))
  and ((@patID  is null)  or (sr.patID  = @patID))
)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW_CORE] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW] (
    @userID            as    bigint
  , @userGroup         as    int
  , @userRank          as    int
  , @clientID          as    bigint
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
 * SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW */    
/**    
 *     
 ***************************************************************************/     
    
return (    

  select top (dbo.CONST_MAX_ROWS()) 
  
  	  t1.id
    , t1.clientID
    , t1.renderingPracID
	, t1.renderingGroupID
	, t1.renderingGroupSvcClassNameID

	, t1.svcRecID
	, t1.patID
	, t1.attendanceSelectionID
    , t1.dos
	, t1.numMins

    , t1.assignedToPracID
    , t1.assignedOn
    , t1.reviewed
    , t1.reviewedOn
    , t1.reviewedByPracID
    , t1.reviewedByName
    , t1.reviewedByTitle
    , t1.approved  
    , t1.notes

	, svcNotes = dbo.BUILD_SVC_NOTES_TEXT(t1.svcNotesPatientGoalProgressText, t1.svcNotesFormBuilderText,t1.svcNotes)
	
    , clientName              = clc.CLIENT_NAME
	, siteName                = ss.SITE_NAME
    , patName                 = pap.CONCAT_NAME
    , ssid                    = isnull(pap.CSIS,'')
    , renderingPracName       = rprp.CONCAT_NAME
	, renderingGroupName      = rggd.GROUP_NAME

    , attendanceSelectionName = afs.[name]
    , svcName                 = snl2.[SERVICE_NAME]
	, dosStr                  = dbo.RPT_DATE_FMT(t1.dos)
	, assignedOnStr           = dbo.RPT_DATE_FMT(t1.assignedOn)
	, reviewedOnStr           = dbo.RPT_DATE_FMT(t1.reviewedOn)

	, assignedPracName        = aprp.CONCAT_NAME
	, reviewedStr             = dbo.RPT_BIT_TO_YN(t1.reviewed)
	, approvedStr             = dbo.RPT_BIT_TO_YNU(t1.approved)
		
  from dbo.SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW_CORE (   @clientID
                                                        , @siteID
														, @reviewingPracID
	  												    , @renderingPracID
														, @patID
														, @startDate
														, @endDate
													    , @reviewed
													    , @approved ) as t1      

  join dbo.CLIENTS_Client            as clc  on clc.CLIENT_ID        = t1.clientID
  join dbo.PATIENTS_Patient          as pap  on pap.PATIENT_ID       = t1.patID
  join dbo.PRACTITIONER_Practitioner as rprp on rprp.PRACTITIONER_ID = t1.renderingPracID
  join dbo.GROUP_Group               as rggd on rggd.GROUP_ID        = t1.renderingGroupID
  join dbo.PRACTITIONER_Practitioner as aprp on aprp.PRACTITIONER_ID = t1.assignedToPracID
  join dbo.SITES_Site                as ss   on ss.SITE_ID           = t1.siteID
  join dbo.SERVICE_RECORD_ATTENDANCE_FLAGS_SELECTIONS as afs on afs.id            = t1.attendanceSelectionID
     
  cross apply (
    select top 1 
      snl1.[SERVICE_NAME] 
	from dbo.SERVICE_NAME_LOOKUP (   t1.planType
                                   , t1.svcType
                                   , t1.svcNameID
                                   , t1.nameIDAliasID
                                   , t1.dos
                                   , t1.renderingGroupID
                                   , t1.hasSvcDetFlags
                                   , t1.svcDetFlag1
                                   , t1.svcDetFlag2
                                   , t1.svcDetFlag3
                                   , t1.svcDetFlag4 ) as snl1 
  ) as snl2

  order by 
    t1.assignedOn asc
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW] TO [webuser]
GO
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTICE_OFFICE_VISITS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTICE_OFFICE_VISITS_VIEW_CORE]    
(   @userID              bigint
  , @userGroup           int  
  , @userRank            int   
  , @clientID            bigint
  , @groupSvcClassNameID bigint
  , @siteID              bigint
  , @patID               bigint
  , @pracID              bigint  
  , @completed           bit
  , @active              bit
  , @recID               bigint
)     
 
 RETURNS TABLE    
 
 /***************************************************************************    
  * PRACTICE_OFFICE_VISITS_VIEW_CORE */    
 /**    
  * Returns a table of practice office visits that match the given parameters    
  *    
  * @return                 Table of practice office visits data    
  ***************************************************************************/     
  
AS RETURN (   
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/     
 
 with
 cte_p1
 as
 (
   select 
       pov.*	 
     , practiceOfficeVisitReasonName     = povr.[name]
	 , patName                           = isnull(pap2.patName,   '')
	 , patLastName                       = isnull(pap2.patLastName,'')
	 , patFirstName                      = isnull(pap2.patFirstName,'')
	 , pracName                          = isnull(prp2.pracName,  '')
	 , pracTitle                         = isnull(prp2.pracTitle, '')
	 , pracLastName                      = isnull(prp2.pracLastName,  '')
	 , pracFirstName                     = isnull(prp2.pracFirstName,  '')
	 , groupID                           = isnull(prp2.pracDispGroupID, 0)
     , checkInDateStr                    = dbo.RPT_DATE_FMT(pov.checkInDate)
	 , checkInTimeStr                    = dbo.RPT_TIME_FMT(pov.checkInTime,0)
	 , checkInDateYYMMDDStr              = dbo.RPT_DATE_FMT_YYYY_MM_DD(pov.checkInDate)
	 , checkInTimeHHMMStr                = dbo.RPT_TIME_FMT_HH_MM_SS(pov.checkInTime,0)     
     , siteName                          = ss.SITE_NAME
	 , groupSvcClassName                 = gscn.GROUP_SERVICE_CLASS_NAME
     , currentVisitStatusCodeName        = povsc.[name]
	 , practiceOfficeVisitResolutionName = isnull(povrs2.[name],'')
	 , visitStartDateStr                 = dbo.RPT_DATE_FMT(pov.visitStartDate)
     , visitStartTimeStr                 = dbo.RPT_TIME_FMT(pov.visitStartTime,0)
	 , visitStartDateYYMMDDStr           = dbo.RPT_DATE_FMT_YYYY_MM_DD(pov.visitStartDate)
	 , visitStartTimeHHMMStr             = dbo.RPT_TIME_FMT_HH_MM_SS(pov.visitStartTime,0)

	 , visitEndDateStr                   = dbo.RPT_DATE_FMT(pov.visitEndDate)
	 , visitEndTimeStr                   = dbo.RPT_TIME_FMT(pov.visitEndTime,0)
	 , visitEndDateYYMMDDStr             = dbo.RPT_DATE_FMT_YYYY_MM_DD(pov.visitEndDate)
	 , visitEndTimeHHMMStr               = dbo.RPT_TIME_FMT_HH_MM_SS(pov.visitEndTime,0)
   
 	 , waitingTimeStr = iif ((pov.completed = 0)
	                        , iif((pov.visiting = 0)
	                              , dbo.CALC_HUMAN_FRIENDLY_RELATIVE_DATE_IN_DAYS_HOURS_MINS_SECONDS(pov.checkInDateTime,getdate(),0)
		                          , dbo.CALC_HUMAN_FRIENDLY_RELATIVE_DATE_IN_DAYS_HOURS_MINS_SECONDS(pov.checkInDateTime,pov.visitStartDateTime,0))
                            , dbo.CALC_HUMAN_FRIENDLY_RELATIVE_DATE_IN_DAYS_HOURS_MINS_SECONDS(pov.checkInDateTime,pov.visitStartDateTime,0))
     
	 , visitingTimeStr = iif( (pov.completed = 0)
	                         , iif ((pov.visiting = 1)
	                              , dbo.CALC_HUMAN_FRIENDLY_RELATIVE_DATE_IN_DAYS_HOURS_MINS_SECONDS(pov.visitStartDateTime,getdate(),0)
		                          , '')
							, dbo.CALC_HUMAN_FRIENDLY_RELATIVE_DATE_IN_DAYS_HOURS_MINS_SECONDS(pov.visitStartDateTime,pov.visitEndDateTime,0))

     , hasVisitReasonNotes = convert(bit,(iif((len(trim(isnull(pov.practiceOfficeVisitReasonNotes,''))) != 0),1,0)))

	
   from dbo.PRACTICE_OFFICE_VISITS             as pov 
   join dbo.PRACTICE_OFFICE_VISIT_REASONS      as povr  on povr.id                          = pov.practiceOfficeVisitReasonID
   join dbo.SITES_Site                         as ss    on ss.SITE_ID                       = pov.siteID
   join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES    as gscn  on gscn.GROUP_SERVICE_CLASS_NAME_ID = pov.groupSvcClassNameID
   join dbo.PRACTICE_OFFICE_VISIT_STATUS_CODES as povsc on povsc.codeValue                  = pov.currentVisitStatusCodeValue

   /* Patient */

   outer apply (
     select top 1 
         patName      = pap1.CONCAT_NAME
	   , patLastName  = pap1.LAST_NAME
	   , patFirstName = pap1.FIRST_NAME 
     from dbo.PATIENTS_Patient as pap1
     where 
       (pap1.PATIENT_ID = pov.patID)
   ) as pap2

   /* Assigned practitioner */

   outer apply (
     select top 1 
         pracName        = prp1.CONCAT_NAME 	   
	   , pracTitle       = ggd1.GROUP_NAME
	   , pracLastName    = prp1.LAST_NAME
	   , pracFirstName   = prp1.FIRST_NAME
	   , pracDispGroupID = ggd1.GROUP_ID
     from dbo.PRACTITIONER_Practitioner as prp1
	 join dbo.PRACTITIONER_GROUPS       as pgd1 on ((pgd1.PRACTITIONER_ID = prp1.PRACTITIONER_ID)
	                                            and (pgd1.GROUP_TYPE in (1,2)))
     join dbo.GROUP_Group               as ggd1 on ggd1.GROUP_ID = pgd1.GROUP_ID
	 where 
       (prp1.PRACTITIONER_ID = pov.pracID)
   ) as prp2
   
   /* Resolution */

   outer apply (
     select top 1 
       povrs1.[name]
     from dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS as povrs1
     where 
       (povrs1.id = pov.practiceOfficeVisitResolutionID)
   ) as povrs2
   
   where (
           (1=1)     
	   and (pov.clientID = @clientID)
	   and ((@groupSvcClassNameID is null) or (pov.groupSvcClassNameID = @groupSvcClassNameID))
	   and ((@siteID    is null)  or (pov.siteID    = @siteID))
       and ((@pracID    is null)  or (pov.pracID    = @pracID))
       and ((@patID     is null)  or (pov.patID     = @patID))
	   and ((@completed is null)  or (pov.completed = @completed))
	   and ((@active    is null)  or (pov.active    = @active))
	   and ((@recID     is null)  or (pov.id        = @recID)) 
	)
)

select 
  p1.* 
, assignedPracSig = iif ( (p1.completed = 1)
                          ,'Electronically Signed By ' + p1.pracName + ' (' + p1.pracTitle + ') On ' + dbo.RPT_DATE_FMT(p1.lastModified)
						  ,'')
from cte_p1 as p1

)    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTICE_OFFICE_VISITS_VIEW_CORE] TO [webuser]
GO

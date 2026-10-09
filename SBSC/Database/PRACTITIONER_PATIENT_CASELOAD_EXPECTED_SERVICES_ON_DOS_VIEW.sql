USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW] (
   @userID          BIGINT    
 , @userGroup       BIGINT    
 , @userRank        BIGINT
 , @clientID        BIGINT
 , @pracID          BIGINT
 , @patID           BIGINT
 , @dos             DATETIME 
 , @pracPatGroupID  BIGINT
)    

RETURNS table 
as
return
(
 /***************************************************************************    
  * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW */    
 /**    
  * 
  * @return Table of expected service data   
  ***************************************************************************/     

with
cte_p1
as
(
  select 
    ppssvc.*
  from dbo.Practitioner_Patient_Scheduled_Services_View_Core (@clientID,@pracID,@patID,null,1,null,@dos,@pracPatGroupID) as ppssvc
  where 
    (ppssvc.occursOnRefDate = 1)
)
,
cte_p2
as
(
  select 
      p1.* 	  
    , idx = ROW_NUMBER() OVER(ORDER BY p1.pracID)
    , startTimeForDOW = dbo.Practitioner_Patient_Scheduled_Service_Get_Start_Time_For_Dow (  p1.dow
	                                                                                      , p1.recurring
	                                                                                      , p1.startTime
	                                                                                      , p1.monStartTime
	                                                                                      , p1.tueStartTime
	                                                                                      , p1.wedStartTime
	                                                                                      , p1.thuStartTime
													   								      , p1.friStartTime )

  from cte_p1 as p1
)

select top (dbo.CONST_MAX_ROWS())
      id = p2.idx
	, p2.clientID
    , p2.clientName
	, p2.pracID
    , p2.pracName
    , p2.groupID  
    , p2.groupName
    , p2.patID
    , patName = p2.patName
    , dos     = p2.refDate
    , dosStr  = p2.refDateStr
    , dosYMD  = p2.refDateYMD
    , p2.numMins
	, startTime     = p2.startTimeForDOW
    , startTimeStr  = dbo.RPT_TIME_FMT(p2.startTimeForDOW,0)
	, startTimeHMS  = dbo.RPT_TIME_FMT_HH_MM_SS(p2.startTimeForDOW,0)
    , p2.svcTypeID
    , p2.svcSubType1ID
    , planTypeSelectionID  = null /* Check if needed */
    , internalPlanTypeID   = p2.planTypeID	
    , p2.isIEPOrIFSP
    , p2.svcNamesListDataSourceID
    , p2.svcNamesListDataSourceName
    , serviceNameID           = p2.nameID
    , p2.svcName         
    , p2.viaTeleHealth
	, p2.altModalityNameID
	, scheduledServiceID = p2.id
	, p2.caseloadGrpID
from cte_p2 as p2
order by 
	p2.startTimeForDOW asc
  , p2.patName
  , p2.svcTypeID
)


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW] TO [webuser]
GO

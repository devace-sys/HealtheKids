USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Services_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Patient_Scheduled_Services_View
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Practitioner_Patient_Scheduled_Services_View] (
    @userID                 bigint
  , @userGroup              int 
  , @userRank               int     
  , @clientID               bigint     
  , @pracID                 bigint
  , @patID                  bigint 
  , @practitionerPatientCaseloadExpectedServiceID bigint
  , @active                 bit
  , @recID                  bigint    
)
    
returns table     
as
 
return 
(    

/***************************************************************************
 * Practitioner_Patient_Scheduled_Services_View */
/**
 ***************************************************************************/

with
cte_p1
as
(
  select 
      ppssvc.* 		
	, viaTeleHealthYN            = dbo.RPT_BIT_TO_YN(ppssvc.viaTeleHealth)
	, recurringYN                = dbo.RPT_BIT_TO_YN(ppssvc.recurring)
    , startDateStr               = dbo.RPT_DATE_FMT(ppssvc.startDate)	
	, startDateYMD               = dbo.RPT_DATE_FMT_YYYY_MM_DD(ppssvc.startDate)
	, endDateStr                 = dbo.RPT_DATE_FMT(ppssvc.endDate)
	, endDateYMD                 = dbo.RPT_DATE_FMT_YYYY_MM_DD(ppssvc.endDate)
    , startTimeStr               = dbo.RPT_TIME_FMT(ppssvc.startTime,0)
    , startTimeHMS               = dbo.RPT_TIME_FMT_HH_MM_SS(ppssvc.startTime,0)	
	, monStartTimeStr            = dbo.RPT_TIME_FMT(ppssvc.monStartTime,0)
	, monStartTimeHMS            = dbo.RPT_TIME_FMT_HH_MM_SS(ppssvc.monStartTime,0)
	, tueStartTimeStr            = dbo.RPT_TIME_FMT(ppssvc.tueStartTime,0)
	, tueStartTimeHMS            = dbo.RPT_TIME_FMT_HH_MM_SS(ppssvc.tueStartTime,0)
	, wedStartTimeStr            = dbo.RPT_TIME_FMT(ppssvc.wedStartTime,0)
	, wedStartTimeHMS            = dbo.RPT_TIME_FMT_HH_MM_SS(ppssvc.wedStartTime,0)
    , thuStartTimeStr            = dbo.RPT_TIME_FMT(ppssvc.thuStartTime,0)
	, thuStartTimeHMS            = dbo.RPT_TIME_FMT_HH_MM_SS(ppssvc.thuStartTime,0)
    , friStartTimeStr            = dbo.RPT_TIME_FMT(ppssvc.friStartTime,0)
	, friStartTimeHMS            = dbo.RPT_TIME_FMT_HH_MM_SS(ppssvc.friStartTime,0)
    , occursOnRefDateStr         = dbo.RPT_BIT_TO_YN(ppssvc.occursOnRefDate)

    , dateRangeBeforeInOrAfterRefDateName = case 
       when (ppssvc.dateRangeBeforeInOrAfterRefDateVal = -1) then 'Past'
	   when (ppssvc.dateRangeBeforeInOrAfterRefDateVal = 0)  then 'Present'
	   when (ppssvc.dateRangeBeforeInOrAfterRefDateVal = 1)  then 'Future'
	   else ''
    end
    
	, scheduleHasExpiredStr = dbo.RPT_BIT_TO_YN(ppssvc.scheduleHasExpired)

  from dbo.Practitioner_Patient_Scheduled_Services_View_Core (  @clientID
                                                              , @pracID
															  , @patID
															  , @practitionerPatientCaseloadExpectedServiceID
															  , @active
															  , @recID
															  , null
															  , null ) as ppssvc
)
select top (dbo.CONST_MAX_ROWS())
    p1.* 
from cte_p1 as p1
order by 
    p1.clientName
  , p1.pracName
  , p1.patName
  , p1.startDate desc
  , p1.svcName  

) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Practitioner_Patient_Scheduled_Services_View] TO [webuser]
GO
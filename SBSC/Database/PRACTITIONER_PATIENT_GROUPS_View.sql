USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_GROUPS_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_GROUPS_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_GROUPS_View]    
(@userID     INT,    
 @userGroup  INT,    
 @userRank   INT,
 @clientID   INT,
 @pracID     INT,
 @term       VARCHAR(500),
 @recID      INT)    

RETURNS TABLE

 /***************************************************************************    
  * PRACTITIONER_PATIENT_GROUPS_View */    
 /**    
  * Returns a table of patients that match the given parameters    
  *    
  * @param  clientID        Required.  ID of client. 
  * @param  pracID          Required.  ID of practitioner.    
  * @param  patID           Required.  ID of patient.
  * @param  startDate       Start of month.
  * @param  endDate         End of month
  * @return                 Table of expected service data   
  ***************************************************************************/     
  
AS RETURN
(

select 
    ppg.groupName as name
    , viaTeleHealthYN            = dbo.RPT_BIT_TO_YN(ppg.viaTeleHealth)
	, recurringYN                = dbo.RPT_BIT_TO_YN(ppg.recurring)
    , startDateStr               = dbo.RPT_DATE_FMT(ppg.startDate)	
	, startDateYMD               = dbo.RPT_DATE_FMT_YYYY_MM_DD(ppg.startDate)
	, endDateStr                 = dbo.RPT_DATE_FMT(ppg.endDate)
	, endDateYMD                 = dbo.RPT_DATE_FMT_YYYY_MM_DD(ppg.endDate)	
	, monStartTimeStr            = dbo.RPT_TIME_FMT(ppg.monStartTime,0)
	, monStartTimeHMS            = dbo.RPT_TIME_FMT_HH_MM_SS(ppg.monStartTime,0)
	, tueStartTimeStr            = dbo.RPT_TIME_FMT(ppg.tueStartTime,0)
	, tueStartTimeHMS            = dbo.RPT_TIME_FMT_HH_MM_SS(ppg.tueStartTime,0)
	, wedStartTimeStr            = dbo.RPT_TIME_FMT(ppg.wedStartTime,0)
	, wedStartTimeHMS            = dbo.RPT_TIME_FMT_HH_MM_SS(ppg.wedStartTime,0)
    , thuStartTimeStr            = dbo.RPT_TIME_FMT(ppg.thuStartTime,0)
	, thuStartTimeHMS            = dbo.RPT_TIME_FMT_HH_MM_SS(ppg.thuStartTime,0)
    , friStartTimeStr            = dbo.RPT_TIME_FMT(ppg.friStartTime,0)
	, friStartTimeHMS            = dbo.RPT_TIME_FMT_HH_MM_SS(ppg.friStartTime,0)
    ,ppg.* 
from dbo.PRACTITIONER_PATIENT_GROUP as ppg
where 
      ppg.clientID = @clientID
  and ppg.pracID   = @pracID
  and ((@recID is null) or (ppg.id = @recID))

)


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_GROUPS_View] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MISSING_TREATMENTS_SPED_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MISSING_TREATMENTS_SPED_DATA_CORE
GO


CREATE FUNCTION [dbo].[RPT_MISSING_TREATMENTS_SPED_DATA_CORE] (
   @clientID             bigint  = null
 , @groupSvcClassNameID  bigint  = null
 , @spEdServiceCode      int     = null
 , @patHasBIC            bit     = null
 , @leaBopSvc            bit     = null
 , @missingTmt           bit     = null
)
returns
table
as
return
(

/*============================================================
 * Get all possible spEdSvcCode and groupSvcClassNameID
 * assignments including spEdSvcCodes without groupSvcClass
 * assignments
 *===========================================================*/  

with
cte_p0
as
(
  select distinct scn1.spEdSvcCodeValue, scn1.groupSvcClassNameID from dbo.SpEd_Service_GroupServiceClassNames            as scn1 
  union
  select distinct scn2.spEdSvcCodeValue, scn2.groupSvcClassNameID from dbo.SpEd_Service_GroupServiceClassNamesNotAssigned as scn2
)
,

/*============================================================
 * If applicable filter out JUST spEdSvcCodes that relate
 * to @groupSvcClassNameID or @spEdSvcCodeValue.
 *
 * NOTE: We do not return the groupSvc class data as this 
 * would create duplicates.  The data is SpEdSvcCode centric
 * and we are just using the @grouSvcClassNameID to limit
 * svcCodes returned to groups resposible for those codes.
 *===========================================================*/  

cte_p1
as
(
  select distinct 
    scn1.spEdSvcCodeValue  
  from cte_p0 as scn1 
  where ( 
        (1=1)
    and ((@groupSvcClassNameID is null) or (scn1.groupSvcClassNameID = @groupSvcClassNameID))
	and ((@spEdServiceCode is null)     or (scn1.spEdSvcCodeValue    = @spEdServiceCode))
  )
) 
,

/*============================================================
 * Get data (cached)
 *===========================================================*/  

cte_p2
as
(
  select 
      ss.*
	, groupServiceClassNameID    = @groupSvcClassNameID
	, groupServiceClassNames     = gsn.groupSvcClassNames
    , spEdServiceCodeStr         = convert(varchar(50),ss.spEdServiceCode)
    , spEdServiceName            = ssn.name
  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services_For_LEA_BOP_Reports as ss 
  join cte_p1                                                           as p1  on p1.spEdSvcCodeValue = ss.spEdServiceCode
  join dbo.SpEd_Service_GroupServiceClassNamesAgg                       as gsn on gsn.spEdSvcCodeValue = ss.spEdServiceCode 
  join dbo.SpEd_Service                                                 as ssn on ssn.codeValue = ss.spEdServiceCode	
  where (
	        (ss.clientID = @clientID)                                               /* For index */
	    and ((@spEdServiceCode is null) or (ss.spEdServiceCode = @spEdServiceCode)) /* For index */
	    and ((@patHasBIC  is null) or (ss.patHasBIC        = @patHasBIC))
	    and ((@leaBopSvc  is null) or (ss.billableSvc      = @leaBopSvc))
	    and ((@missingTmt is null) or (ss.lessThanExpected = @missingTmt))
  )
)
select 
      ss.clientID
    , ss.patID
    , groupServiceClassNameID       = ss.groupServiceClassNameID
    , groupServiceClassNames        = ss.groupServiceClassNames
    , planStart                     = ss.planStartDate
    , planEnd                       = ss.planEndDate
    , spEdServiceCode               = ss.spEdServiceCode
    , spEdServiceCodeStr            = ss.spEdServiceCodeStr
    , spEdServiceName               = ss.spEdServiceName
    , spEdServiceCodeName           = ss.spEdServiceCodeStr + ' - ' + ss.spEdServiceName
	, orpDocStandardSelectionNameID = -1
    , orpDocStandardSelectionName   = ''
	, orpDocID                      = -1
    , svcTrackingClass              = dbo.CONST_SVC_TRACKING_CLASS_SPED()
    , serviceOrOrderName            = ss.spEdServiceCodeStr + ' - ' + ss.spEdServiceName
	, numMinsExpected               = ss.totalMinutesExpected
    , numMinsApplicable             = ss.totalMinutesSatisfied
    , minsExpectedApplicableDiff    = ss.diffMinutesExpectedSatified
    , estLostReimburse              = ss.potentialLostReimbursment
	, ss.spEdFreqCode
	, spEdFreqName = ssf.[name]
	, ss.minsPerFreq
	, ss.id 
	  
from cte_p2 as ss 
join dbo.SpEd_Service_Frequency                 as ssf on ssf.codeValue = ss.spEdFreqCode


)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_MISSING_TREATMENTS_SPED_DATA_CORE TO [webuser]
GO
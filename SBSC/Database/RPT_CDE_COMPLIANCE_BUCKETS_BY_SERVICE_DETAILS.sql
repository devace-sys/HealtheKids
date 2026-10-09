USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_DETAILS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_DETAILS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_DETAILS]
(
    @userID                     bigint 
  , @userGroup                  int
  , @userRank                   int 
  , @clientID                   bigint
  , @siteID                     bigint
  , @patID                      bigint
  , @spEdServiceCode            int
  , @pcalComplianceRatingForPat tinyint
  , @overDelivery               bit
)
returns
table
as
return
(
with
cte_p1
as
(
  select   
      pps.clientID
	, pps.spEdServiceCode
    , pps.patID
	, startDate                  = pps.planStartDate
	, endDate                    = pps.endDate
	, totMinsDiff                = pps.diffMinutesExpectedSatified
	, totMinsExpected            = pps.totalMinutesExpected
	, totMinsApplicable          = pps.totalMinutesSatisfied
	, potLostReimbursement       = pps.potentialLostReimbursment
	
	, pps.planStartDate
	, pps.planEndDate
    , pps.minsPerFreq
	, pps.spEdFreqCode
	
	, pps.numPatAbsentTot
	, pps.numPracAbsentTot
	, pps.numSvcRecs

    , pps.siteID
    , siteName     = ss.SITE_NAME
    , numAbsentTot = numPatAbsentTot + numPracAbsentTot
    , overDelivery = convert(bit,(iif((pps.diffMinutesExpectedSatified < 0),1,0)))
	
  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services as pps  
  join dbo.SITES_Site                                                   as ss on ss.SITE_ID = pps.siteID

  where (
        (pps.clientID = @clientID)
	and ((@siteID is null) or (pps.siteID = @siteID))
	and ((@patID  is null) or (pps.patID  = @patID))
	and ((@spEdServiceCode            is null) or (pps.spEdServiceCode            = @spEdServiceCode))
	and ((@pcalComplianceRatingForPat is null) or (pps.pcalComplianceRatingForPat = @pcalComplianceRatingForPat))
  )
)
,
cte_p2
as
(
  select 
      spEdServiceName         = ss.[name]
    , spEdServiceCodeAndName  = convert(varchar(50),p1.spEdServiceCode) + '-' + ss.[name]
	, patName                 = pap.CONCAT_NAME
    , patDOBStr               = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
    , patSSID                 = isnull(pap.CSIS,N'')
    , patBIC                  = isnull(pap.BIC,N'')
	, spEdCaseManagerName     = isnull(pap.spEdCaseManagerName,'')
	, pap.spEdExitedSpEdDate
	, spEdExitedSpEdDateStr   = dbo.RPT_DATE_FMT(pap.spEdExitedSpEdDate)
	, p1.* 
	, startDateStr            = dbo.RPT_DATE_FMT(p1.startDate)
	, endDateStr              = dbo.RPT_DATE_FMT(p1.endDate)	
    , pctExpectedApplicable   = dbo.CALC_PERCENTAGE (p1.totMinsApplicable,p1.totMinsExpected,1,1,0)
    , potLostReimbursementStr = convert(varchar(50),p1.potLostReimbursement)
	, spEdFreqName     = ssf.[name]
	, planStartDateStr = dbo.RPT_DATE_FMT (p1.planStartDate)
	, planEndDateStr   = dbo.RPT_DATE_FMT (p1.planEndDate)
	
	, pctAbsencePat    = dbo.CALC_PERCENTAGE (p1.numPatAbsentTot,p1.numSvcRecs,1,1,0)
    , pctAbsencePrac   = dbo.CALC_PERCENTAGE (p1.numPracAbsentTot,p1.numSvcRecs,1,1,0)
	, pctAbsence       = dbo.CALC_PERCENTAGE (p1.numAbsentTot,p1.numSvcRecs,1,1,0)
  
  from cte_p1                            as p1
  join dbo.SpEd_Service                  as ss  on ss.codeValue   = p1.spEdServiceCode
  join dbo.PATIENTS_Patient              as pap on pap.PATIENT_ID = p1.patID
  join dbo.SpEd_Service_Frequency        as ssf on ssf.codeValue = p1.spEdFreqCode  
  where ( 
        (1=1)
    and ((@overDelivery is null) or (p1.overDelivery = @overDelivery))
  )
)
,
cte_p3
as
(
select 
    p2.* 
  , caseLoadAssignmentsForSpEdSvcSummaryText = isnull(ppc3.caseLoadAssignmentsForSpEdSvcSummaryTxt,'No Current Caseload Assignments For This Service Plan Itself')
  , hasCaseloadAssignmentsForSpEdSvc         = convert(bit,(iif((ppc3.caseLoadAssignmentsForSpEdSvcSummaryTxt is null),0,1)))  
from cte_p2 as p2

/* Generate summary text of caseload assignments FOR THIS SpEdService Code */

outer apply (
  select 
    caseLoadAssignmentsForSpEdSvcSummaryTxt = trim(STRING_AGG(ppc2.pracNameAndTitle,char(10)+char(13)))
  from
  (
    select      
	    pracNameAndTitle  = '' 
		+ '('
		+ convert(varchar(256),(ROW_NUMBER() OVER (PARTITION BY ppc1.patID ORDER BY ppc1.id)))
		+ ') ' 
		+ prp.CONCAT_NAME + ' - ' + ggd.GROUP_NAME
		+ ' '
    from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc1
	join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as pps on pps.caseloadEntryID = ppc1.id
	                                                         and pps.spEdServiceCode = p2.spEdServiceCode
															 and pps.spEdFreqCode    = p2.spEdFreqCode
															 and pps.startDate       = p2.startDate
    join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = ppc1.pracID
    join dbo.PRACTITIONER_GROUPS       as pgd on (pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID)
                                       and (pgd.GROUP_TYPE in (1,2))
    join dbo.GROUP_Group               as ggd on ggd.GROUP_ID = pgd.GROUP_ID
    where (
            (ppc1.clientID = p2.clientID)
        and (ppc1.patID    = p2.patID)
	  )
  ) as ppc2
) as ppc3

)

select top (dbo.CONST_MAX_ROWS())
   p3.* 
 , pctExpectedApplicableStr = convert(varchar(50),p3.pctExpectedApplicable) + '%'
 , pctAbsencePatStr         = convert(varchar(50),p3.pctAbsencePat)   + '%'
 , pctAbsencePracStr        = convert(varchar(50),p3.pctAbsencePrac)  + '%'
 , pctAbsenceStr            = convert(varchar(50),p3.pctAbsence)      + '%'
 , hasCaseloadAssignmentsForSpEdSvcStr      = dbo.RPT_BIT_TO_YN(p3.hasCaseloadAssignmentsForSpEdSvc)
 , caseLoadAssignmentsForSpEdSvcSummaryHTML = REPLACE(p3.caseLoadAssignmentsForSpEdSvcSummaryText,char(10)+char(13),'<br>')

from cte_p3 as p3
order by 
  p3.patName
)

GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_DETAILS TO [webuser]
GO
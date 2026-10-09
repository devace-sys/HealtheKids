USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_DETAILS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_DETAILS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_DETAILS] (
    @userID                      bigint 
  , @userGroup                   int
  , @userRank                    int 
  , @clientID                    bigint
  , @siteID                      bigint
  , @pcalComplianceRatingForPat  tinyint
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
	, pps.siteID
	, pps.patID    
	, pps.pcalComplianceRatingForPat
	, pps.iepCompliancePctForPat
    , numSvcs = count(pps.pcalComplianceRatingForPat)	
  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services as pps
  where (
         (pps.clientID = @clientID)
    and ((@siteID    is null) or (pps.siteID                     = @siteID))
    and ((@pcalComplianceRatingForPat is null) or (pps.pcalComplianceRatingForPat = @pcalComplianceRatingForPat))
  )
  group by 
      pps.clientID
    , pps.siteID
    , pps.patID
    , pps.pcalComplianceRatingForPat
	, pps.iepCompliancePctForPat
)
,
cte_p2
as
(
  select 
      p1.clientID
    , p1.siteID
    , p1.patID
    , p1.numSvcs
	, p1.iepCompliancePctForPat
	, pcalComplianceRatingForPatCode = pcrfp.code
    , pcalComplianceRatingForPatName = pcrfp.[name]   
	, caseLoadAssignmentsSummaryText = isnull(ppc3.caseLoadAssignmentsSummaryTxt,'No Current Caseload Assignments')
    , hasCaseloadAssignments          = convert(bit,(iif((ppc3.caseLoadAssignmentsSummaryTxt is null),0,1)))
from cte_p1 as p1
join dbo.PATIENTS_Promised_Services_Pcal_Compliance_Rating_For_Pat_Codes as pcrfp on pcrfp.code = p1.pcalComplianceRatingForPat

/* Generate summary text of caseload assignments */

outer apply (
  select 
    caseLoadAssignmentsSummaryTxt = trim(STRING_AGG(ppc2.pracNameAndTitle,char(10)+char(13)))
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
    join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = ppc1.pracID
    join dbo.PRACTITIONER_GROUPS       as pgd on (pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID)
                                       and (pgd.GROUP_TYPE in (1,2))
    join dbo.GROUP_Group               as ggd on ggd.GROUP_ID = pgd.GROUP_ID
    where (
            (ppc1.clientID = p1.clientID)
        and (ppc1.patID    = p1.patID)
	  )
  ) as ppc2
) as ppc3


)
select top (dbo.CONST_MAX_ROWS()) 
    p2.* 
  , clientName            = clc.CLIENT_NAME
  , siteName              = ss.SITE_NAME
  , patName               = pap.CONCAT_NAME
  , patDOB                = pap.DATE_OF_BIRTH
  , patDOBStr             = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
  , patSSID               = isnull(pap.CSIS,'')
  , spEdCaseManagerName   = isnull(pap.spEdCaseManagerName,'')
  , spEdExitedSpEdDateStr = dbo.RPT_DATE_FMT(pap.spEdExitedSpEdDate)
  , pap.spEdExitedSpEdDate
  , hasCaseloadAssignmentsStr      = dbo.RPT_BIT_TO_YN(p2.hasCaseloadAssignments)
  , caseLoadAssignmentsSummaryHTML = REPLACE(p2.caseLoadAssignmentsSummaryText,char(10)+char(13),'<br>')

from cte_p2               as p2
join dbo.CLIENTS_Client   as clc on clc.CLIENT_ID  = p2.clientID
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = p2.patID
join dbo.SITES_Site       as ss  on ss.SITE_ID     = p2.siteID

order by 
  pap.CONCAT_NAME
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_DETAILS TO [webuser]
GO
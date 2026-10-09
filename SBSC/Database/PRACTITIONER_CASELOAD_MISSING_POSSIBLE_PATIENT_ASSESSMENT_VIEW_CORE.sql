USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_CASELOAD_MISSING_POSSIBLE_PATIENT_ASSESSMENT_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_CASELOAD_MISSING_POSSIBLE_PATIENT_ASSESSMENT_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_CASELOAD_MISSING_POSSIBLE_PATIENT_ASSESSMENT_VIEW_CORE] ( 
    @clientID           BIGINT
  , @pracID             BIGINT
  , @patsInCaseload     bit = 0
)    

RETURNS 
TABLE 
AS
RETURN
(

with
cte_p1
as
(
  select top 1 
      clientID              = @clientID
    , pracID                = @pracID
	, groupID               = pg.GROUP_ID
    , groupSvcClassNameID   = png.GROUP_SERVICE_CLASS_NAME_ID
  from dbo.PRACTITIONER_GROUPS                               as pg 
  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on  ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
                                                                      and (png.GROUP_ID = pg.GROUP_ID)
	    															  and (png.GROUP_SERVICE_CLASS_NAME_ID is not null)) /* Uses index*/
  where (
         (pg.PRACTITIONER_ID = @pracID) 
	 and (pg.GROUP_TYPE in (1,2))
  )
)
,
cte_p2
as
(
  select 
      p1.*
	, ppsuidc2.pastDate
    , ppsuidc2.patID
	, ppsuidc2.prevIEPDate	
	, ppsuidc2.startDosToSearchForRecordedAmmts
	, ppsuidc2.endDosToSearchForRecordedAssmts
  from cte_p1 as p1
  cross apply (
    select 
      ppsuidc1.*  
    from dbo.PATIENT_PROMISED_SERVICES_RECENT_IEPS_DATA_CORE (p1.clientID, p1.groupSvcClassNameID) as ppsuidc1
    where (
        /* Limits to cases where practice family has something to do*/
		  (ppsuidc1.appliesToGroupSvcClassNameID        = 1)
	  and (ppsuidc1.assmtRecordedForGroupSvcClassNameID = 0) 
	  /* Limit to last 90 days */
	  and (ppsuidc1.prevIEPWasDaysAgo between 1 and 90)
	) 
  ) as ppsuidc2
)
,
cte_p3
as
(
  select 
      p2.*
	, ppcID = ppc2.id 
  from cte_p2 as p2
  outer apply (
    select top 1 
      ppc1.id
    from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc1
    where ((
          (ppc1.clientID = p2.clientID)
	  and (ppc1.pracID   = p2.pracID)
	  and (ppc1.patID    = p2.patID)
	  and (ppc1.id is not null))
    ) /* Uses index */
  ) as ppc2
)
,
cte_p4
as
(
  select 
      p3.* 
    , patInCaseload = convert(bit,iif((p3.ppcID is null),0,1))
  from cte_p3 as p3
)

select     
    p4.patID
  , startDateStr  = dbo.RPT_DATE_FMT(p4.startDosToSearchForRecordedAmmts)
  , endDateStr    = dbo.RPT_DATE_FMT(p4.endDosToSearchForRecordedAssmts)
  , p4.clientID  
  , p4.pracID
  , p4.groupID
  , expectedEntryContext = 'Missing assessment for IEP on ' + dbo.RPT_DATE_FMT(p4.prevIEPDate)
from cte_p4 as p4
where (
      (1=1)
  and ((@patsInCaseload is null) or (p4.patInCaseload = @patsInCaseload))
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_CASELOAD_MISSING_POSSIBLE_PATIENT_ASSESSMENT_VIEW_CORE] TO [webuser]
GO

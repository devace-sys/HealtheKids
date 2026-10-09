USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_COMPLIANCE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_COMPLIANCE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_COMPLIANCE_VIEW] (
   @userID          BIGINT    
 , @userGroup       BIGINT    
 , @userRank        BIGINT
 , @clientID        BIGINT
 , @pracID          BIGINT
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
  select
	  ppc.clientID
	, ppc.patID
	, groupSvcClassNameID   = png.GROUP_SERVICE_CLASS_NAME_ID
	, totAnnualMins         = isnull(ppc.expectedMinsSvcTmtAnn,0)
    , dStart                = convert(datetime,(isnull(ppc.startDateTmtSvcs,(dbo.GET_FY_START_OR_END(getdate(),1)))))
    , dEnd                  = convert(datetime,(convert(date,getdate())))

  from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
  join dbo.PRACTITIONER_GROUPS           as pg on  pg.PRACTITIONER_ID = ppc.pracID
                                               and pg.GROUP_TYPE in (1,2)

  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on  png.GROUP_SERVICE_CLASS_PARTITION_ID = 100
                                                                    and png.GROUP_SERVICE_CLASS_NAME_ID is not null
                                                                    and png.GROUP_ID = pg.GROUP_ID
  where (
         (ppc.clientID = @clientID)
	and (ppc.pracID  = @pracID)
  )
)
,
cte_p2
as
(

select 
   p1.clientID
 , p1.patID
 , p1.totAnnualMins
 , p1.dStart
 , p1.dEnd
 , totMinsRegular    = isnull(pes2.totMinsRegular,   0)
 , totMinsPatAbsent  = isnull(pes2.totMinsPatAbsent, 0) 
 , totMinsPracAbsent = isnull(pes2.totMinsPracAbsent,0)
 , totMinsMakeup     = isnull(pes2.totMinsMakeup,    0)    
 , totRecsRegular    = isnull(pes2.totRecsRegular,   0)   
 , totRecsPatAbsent  = isnull(pes2.totRecsPatAbsent ,0)
 , totRecsPracAbsent = isnull(pes2.totRecsPracAbsent,0)
 , totRecsMakeup     = isnull(pes2.totRecsMakeup,    0)
from cte_p1 as p1
outer apply (
  select 
    pes1.* 
  from dbo.PATIENTS_EXPECTED_SERVICES_SERVICE_RECORD_ENTRY_STATS_VIEW_CORE (  p1.clientID
                                                                            , p1.patID
																			, p1.groupSvcClassNameID
                                                                            , 2
                                                                            , p1.dStart
                                                                            , p1.dEnd) as pes1
) as pes2
)
,
cte_p3
as
(
  select 
    p2.* 
  , totMinsSatisfied = (p2.totMinsRegular + p2.totMinsPatAbsent + p2.totRecsMakeup)
  from cte_p2 as p2
)
,
cte_p4
as
(
  select 
    p3.* 
  , totMinsStillOwed = p3.totAnnualMins - p3.totMinsSatisfied
  from cte_p3 as p3
) 

select 
    id                 = ROW_NUMBER() over (order by pap.CONCAT_NAME asc, pap.DATE_OF_BIRTH, pap.PATIENT_ID)
  , p4.patID
  , [patName]          = pap.CONCAT_NAME 
  , dobStr             = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
  , startDate          = dbo.RPT_DATE_FMT(p4.dStart)
  , endDate            = dbo.RPT_DATE_FMT(p4.dEnd)
  , annualMins         = p4.totAnnualMins
  , p4.totMinsSatisfied
  , p4.totMinsStillOwed
  , p4.totMinsRegular
  , p4.totMinsPatAbsent
  , p4.totMinsPracAbsent
  , p4.totMinsMakeup
  , p4.clientID
from cte_p4               as p4
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = p4.patID

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_COMPLIANCE_VIEW] TO [webuser]
GO

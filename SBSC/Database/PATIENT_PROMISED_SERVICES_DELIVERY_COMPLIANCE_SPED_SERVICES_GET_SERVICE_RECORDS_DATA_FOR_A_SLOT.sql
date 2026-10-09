USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_DATA_FOR_A_SLOT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_DATA_FOR_A_SLOT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_DATA_FOR_A_SLOT] (
    @clientID                      bigint
  , @patID                         bigint
  , @pracID                        bigint = null
  , @spEdServiceCode               int    = null
  , @dosStart                      datetime
  , @dosEnd                        datetime
  , @patAbsentMinsAreSatisfiedMins bit =  1
) 
RETURNS table
AS
return
(     

with
cte_p1
as
(
  select 
      
	  sr.clientID
	, sr.patID
	, sr.dos
	, sr.pracID
	, sr.numMins
	, sr.patAbsent
    , sr.pracAbsent
    , sr.makeupSession
	, sr.attendanceSelectionID
	, sr.siteID
    , csn.spEdSvcCodeValue
	, sr.id	 
  from dbo.SERVICE_RECORDS                       as sr
  join dbo.SERVICE_RECORD_ATTENDANCE_SELECTIONS  as sras on sras.id = sr.attendanceSelectionID
  join dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA as csn  on  (     (csn.planTypeID  = sr.planType)
                                                               and (csn.groupID     = sr.groupID)
                                                               and (csn.nameID      = sr.nameID)
                                                               and (csn.hasClientID = 0)
                                                               and (csn.clientID is null)
                                                               and (csn.active      = 1)
                                                               and (csn.id is not null))
                                                               and (csn.spEdSvcCodeValue != -1)

  where ( 
        /* uses CLIENT_ID_PAT_ID_DOS index */
	    ((sr.clientID = @clientID)  
    and (sr.patID     = @patID)
    and (sr.dos between @dosStart and @dosEnd)
    and (sr.groupID is not null)
    and (sr.planType in (1,2))
    and (sr.nameID is not null)
    and (sr.id is not null))

    and (sr.state not in (99,199))
	and ((@pracID is null) or (sr.pracID = @pracID))
  ) /* where */
)  
select 
    p1.* 
  , pms2.numMinsSatisfied
  , numPatAbsent  = convert(int,(iif((p1.patAbsent  = 1),1,0)))
  , numPracAbsent = convert(int,(iif((p1.pracAbsent = 1),1,0)))
from cte_p1 as p1
cross apply ( 
  select top 1 
    pms1.numMinsSatisfied 
  from dbo.CALC_PROMISED_MINS_SATISFIED_AS_ROW (  p1.numMins
		                                        , p1.patAbsent
							      		        , p1.pracAbsent
												, p1.makeupSession
												, @patAbsentMinsAreSatisfiedMins
												, p1.attendanceSelectionID ) as pms1
) as pms2
where ( 
      (1=1)
  and ((@spEdServiceCode is null) or (p1.spEdSvcCodeValue = @spEdServiceCode))
)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_DATA_FOR_A_SLOT] TO [webuser]
GO
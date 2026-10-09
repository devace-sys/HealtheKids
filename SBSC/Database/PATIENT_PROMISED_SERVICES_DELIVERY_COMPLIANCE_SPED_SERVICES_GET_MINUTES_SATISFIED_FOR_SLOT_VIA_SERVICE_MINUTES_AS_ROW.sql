/* Note: This was replaced with PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_STATS_FOR_A_SLOT */
/* TODO: Remove when it is confirmed we can rely on its replacement */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_MINUTES_SATISFIED_FOR_SLOT_VIA_SERVICE_MINUTES_AS_ROW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_MINUTES_SATISFIED_FOR_SLOT_VIA_SERVICE_MINUTES_AS_ROW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_MINUTES_SATISFIED_FOR_SLOT_VIA_SERVICE_MINUTES_AS_ROW] (
    @clientID                      bigint
  , @patID                         bigint
  , @pracID                        bigint = null
  , @spEdServiceCode               int
  , @dosStart                      datetime
  , @dosEnd                        datetime
  , @patAbsentMinsAreSatisfiedMins bit = 1
) 
RETURNS table
AS
return
(     
  select numMinsSatisfiedTot = isnull(sum(q1.numMinsSatisfied),0)
  from
  (
    select 
      srs.numMinsSatisfied
    from dbo.CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED as snx
    cross apply (      
      select     
	    pms2.numMinsSatisfied
      from dbo.SERVICE_RECORDS as sr       
	  cross apply ( 
	    select top 1 
		  pms1.numMinsSatisfied 
		from dbo.CALC_PROMISED_MINS_SATISFIED_AS_ROW (  sr.numMins
		                                              , sr.patAbsent
													  , sr.pracAbsent
													  , sr.makeupSession
													  , @patAbsentMinsAreSatisfiedMins
													  , sr.attendanceSelectionID ) as pms1
	  ) as pms2      
	  where (
            /* Index predicate */
                ((sr.clientID  = @clientID)
            and (sr.patID      = @patID)
	        and (sr.dos between @dosStart and @dosEnd)
	        and (sr.groupID  = snx.groupID)
	        and (sr.planType = snx.planTypeID)
	        and (sr.nameID   = snx.nameID) 
	        and (sr.id is not null))     
            /* Additional */
	        and (sr.[state] not in (99,199))
			and ((@pracID is null) or (sr.pracID = @pracID))
       )     
    ) as srs
    where ( 
	      (snx.clientID         = @clientId)
	  and (snx.spEdSvcCodeValue = @spEdServiceCode)
	)
  ) as q1
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_MINUTES_SATISFIED_FOR_SLOT_VIA_SERVICE_MINUTES_AS_ROW] TO [webuser]
GO
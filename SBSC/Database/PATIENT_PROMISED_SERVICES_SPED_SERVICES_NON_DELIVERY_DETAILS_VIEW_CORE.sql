USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_SPED_SERVICES_NON_DELIVERY_DETAILS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_SPED_SERVICES_NON_DELIVERY_DETAILS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_SPED_SERVICES_NON_DELIVERY_DETAILS_VIEW_CORE] (
    @clientID    bigint  
  , @source      int
  , @startDate   datetime    
  , @endDate     datetime
)   

returns @recs table (
    idx                   bigint identity(1,1)
  , patID                 bigint
  , reason                varchar(256) 
  , spEdSvcCodeValue      int
)
as
begin

declare @pats as table (
    patID   bigint  
  unique clustered (patID)
)

/*============================================================
 * Current CDE audit
 *===========================================================*/  

if (@source = 1)
begin

  declare @currentCdeAuditID as bigint = null

  select top 1  
      @startDate         = ppscac.startDate
    , @endDate           = ppscac.endDate
    , @currentCdeAuditID = ppscac.id
  from dbo.Patients_Promised_Services_CDE_Audits_Current as ppscac
  where (
        (ppscac.clientID = @clientID) 
	and (ppscac.active   = 1)
  )

  insert into @pats (
    patID
  )
  select  
    ppscacp.patID 
  from dbo.Patients_Promised_Services_CDE_Audits_Current_Patients as ppscacp
  where (
        (ppscacp.patientsPromisedServicesCDEAuditsCurrentID = @currentCdeAuditID)
	and (ppscacp.active = 1)
  )
  option (recompile)
end

/*============================================================
 * All SpEd Patients 
 *===========================================================*/  

else if (@source = 2)
begin
  insert into @pats (
    patID
  )
  select distinct 
    pps.patID
  from dbo.PATIENTS_Client            as pac
  join dbo.PATIENTS_Promised_Services as pps on pps.patID = pac.PATIENT_ID
  where 
        (pac.CLIENT_ID = @clientID)
    and (pps.active = 1)
  group by 
    pps.patID
  option (recompile)
end

/*============================================================
 * Unknown/unsupported source
 *===========================================================*/  

else
begin
  return
end

/*============================================================
 * Get details for service record entries
 *===========================================================*/  

insert into @recs (  
    patID
  , reason  
  , spEdSvcCodeValue  
)
select 
    srStats.patID
  , srStats.reason
  , srStats.spEdSvcCodeValue
from @pats as pats
cross apply (
  select 
      sr.patID
	, reason = sras.[name]
	, sr.spEdSvcCodeValue
  from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_DATA_FOR_A_SLOT (
      @clientID
    , pats.patID
    , null /*@pracID */
    , null /*@spEdServiceCode */
    , @startDate
    , @endDate
    , 1 /* @patAbsentMinsAreSatisfiedMins bit =  1 */
  ) as sr
    
  join dbo.SERVICE_RECORD_ATTENDANCE_SELECTIONS  as sras on sras.id = sr.attendanceSelectionID
  where 
    ((sr.patAbsent = 1) or (sr.pracAbsent = 1))
) as srStats
option (recompile)

/*============================================================
 * Get details for deferal requests
 *===========================================================*/  

insert into @recs (  
    patID
  , reason
  , spEdSvcCodeValue  
)
select 
    ppsdeStats.patID
  , ppsdeStats.reason
  , ppsdeStats.spEdSvcCodeValue  
from @pats as pats
cross apply (
  select 
      ppsde.patID
	, reason           = 'Deferal request'
    , spEdSvcCodeValue = ppsde.spEdServiceCode
  from dbo.PATIENTS_Promised_Services_Delivery_Exceptions as ppsde
  where (
        (ppsde.clientID = @clientID)
    and (ppsde.patID    = pats.patID)
	and (ppsde.svcTrackingClass = 100)
    and (dosStart >= @startDate)
	and (dosEnd   <= @endDate)
	and (ppsde.removed = 0)
    and (ppsde.active  = 1)	
  )
) as ppsdeStats
option (recompile)

return

end
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_SPED_SERVICES_NON_DELIVERY_DETAILS_VIEW_CORE] TO [webuser]
GO
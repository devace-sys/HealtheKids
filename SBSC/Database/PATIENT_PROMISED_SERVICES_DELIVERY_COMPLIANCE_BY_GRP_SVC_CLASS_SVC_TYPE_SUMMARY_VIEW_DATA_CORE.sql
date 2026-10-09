USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_SUMMARY_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_SUMMARY_VIEW_DATA_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_SUMMARY_VIEW_DATA_CORE] (
    @clientID                 bigint
  , @patID                    bigint
  , @groupSvcClassNameID      bigint
  , @svcTypeID                int
  , @svcSubType1ID            int
  , @startDate                datetime
  , @endDate                  datetime
  , @isIEPorIFSP              bit = 1
  , @requireClientPatSvcType  bit = 0 
)   

returns @recs table  (
    clientID                             bigint
  , patID                                bigint
  , totalMinutesSatisfied                int default(0)
  , generatedOn                          datetime
  , idx                                  bigint identity(1,1)
    unique clustered  (clientID, patID, idx)
)     
as
begin


/*============================================================
 * Early return mode for optimizing patient specific reports
 *===========================================================*/  

if (@requireClientPatSvcType = 1)
begin
  if (@svcTypeID is null) return
  if (@clientID  is null) return
  if (@patID     is null) return
  if (@startDate is null) return
  if (@endDate   is null) return
end

declare @today as datetime = getdate()

/*============================================================
 * Default dates to rolling 12 month
 *===========================================================*/  

if (@startDate is null) and (@endDate is null) 
begin

  select  @startDate = dbo.CALC_OLDEST_DOS_ALLOWED (@today)
        , @endDate = @today
end

/*============================================================
 * Check dates
 *===========================================================*/  

if (@startDate is null) return
if (@endDate   is null) return
if (@startDate > @endDate) return

insert into @recs (
    clientID
  , patID
  , totalMinutesSatisfied
  , generatedOn
)
select 
    sr.clientID 
  , sr.patID              
  , totalMinutesSatisfied = sum(dbo.CALC_PROMISED_MINS_SATISFIED (sr.numMins, sr.patAbsent, sr.pracAbsent, sr.makeupSession, 1, sr.attendanceSelectionID))
  , generatedOn           = @today
  from dbo.SERVICE_RECORDS as sr 
  where (
        (1=1)
	  and (
	        (sr.clientID = @clientID) 
        and ((@patID is null) or (sr.patID = @patID))
        and (sr.pracGrpSvcClsNameID = @groupSvcClassNameID)
        and (sr.svcType             = @svcTypeID)
        and (sr.dos between @startDate and @endDate)
        and (sr.id is not null)
	  )
	  and (sr.state not in (99,199))
	  and ((@isIEPorIFSP   is null) or (sr.isIFSPorIEP = @isIEPorIFSP))
      and ((@svcSubType1ID is null) or (sr.svcSubType1 = @svcSubType1ID))
  )
  group by 
      sr.clientID
	, sr.patID

return 
end 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_SUMMARY_VIEW_DATA_CORE] TO [webuser]
GO
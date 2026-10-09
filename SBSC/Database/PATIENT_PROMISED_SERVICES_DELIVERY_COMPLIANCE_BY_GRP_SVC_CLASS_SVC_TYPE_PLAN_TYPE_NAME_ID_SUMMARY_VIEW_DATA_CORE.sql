USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_PLAN_TYPE_NAME_ID_SUMMARY_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_PLAN_TYPE_NAME_ID_SUMMARY_VIEW_DATA_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_PLAN_TYPE_NAME_ID_SUMMARY_VIEW_DATA_CORE] (
    @clientID                 bigint
  , @patID                    bigint
  , @spEdFreqCode             int
  , @minsPerFreqAssigned      int
  , @groupSvcClassNameID      bigint
  , @pracID                   bigint
  , @svcTypeID                int
  , @planTypeID               int
  , @nameID                   bigint  
  , @altModalityNameID        bigint
  , @viaTeleHealth            bit
  , @includeAltModality       bit
  , @startDate                datetime
  , @endDate                  datetime  
  , @exitWithoutCalculation   bit = 0
)   

returns @recs table  (
    clientID                    bigint
  , patID                       bigint  
  , totalMinutesExpected        int
  , totalMinutesSatisfied       int  
  , diffMinutesExpectedSatified int
)     
as
begin

if (@exitWithoutCalculation = 1) return

declare @totMinsExpected     as int      = 0
declare @totMinsSatisfied    as int      = 0
declare @totMinsSatisfiedNme as int      = 0
declare @totMinsSatisfiedAlt as int      = 0
declare @totMinsDiff         as int      = 0
declare @reqParmsAreOK       as bit      = 1
declare @canCalcMinsExpected as bit      = 1

/*============================================================
 * Check parameters
 *===========================================================*/  

if (@nameID              is null) set @reqParmsAreOK = 0
if (@startDate           is null) set @reqParmsAreOK = 0
if (@endDate             is null) set @reqParmsAreOK = 0
if (@clientID            is null) set @reqParmsAreOK = 0
if (@patID               is null) set @reqParmsAreOK = 0

if (@spEdFreqCode        is null) set @canCalcMinsExpected = 0
if (@minsPerFreqAssigned is null) set @canCalcMinsExpected = 0

if (@reqParmsAreOK = 1)
begin
  
  if (@canCalcMinsExpected = 1)
  begin
    set @totMinsExpected = dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_PLAN (@startDate, @endDate, @spEdFreqCode, @minsPerFreqAssigned) 
  end

  select 
    @totMinsSatisfiedNme = sum(dbo.CALC_PROMISED_MINS_SATISFIED (sr.numMins, sr.patAbsent, sr.pracAbsent, sr.makeupSession, 1, sr.attendanceSelectionID)) 
  from dbo.SERVICE_RECORDS as sr 
  where 
  (
    /* Uses [CLIENT_PAT_GRP_FAM_SVCTYPE_IDX_W_ADD_COLS] index */
    (
          (sr.clientID            = @clientID) 
      and (sr.patID               = @patID)
      and (sr.pracGrpSvcClsNameID = @groupSvcClassNameID)
      and (sr.svcType             = @svcTypeID)
      and (sr.dos between @startDate and @endDate)
      and (sr.id is not null)
    )
   
    and (sr.state not in (99,199))
    and (sr.planType = @planTypeID)
    and (sr.nameID = @nameID)
    and ((@pracID is null) or (sr.pracID = @pracID))      
  )
 
  if ((@includeAltModality = 1) and (@altModalityNameID is not null))
  begin 
    select 
      @totMinsSatisfiedAlt = sum(dbo.CALC_PROMISED_MINS_SATISFIED (sr.numMins, sr.patAbsent, sr.pracAbsent, sr.makeupSession, 1, sr.attendanceSelectionID)) 
    from dbo.SERVICE_RECORDS as sr 
    where 
    (
      /* Uses [CLIENT_PAT_GRP_FAM_SVCTYPE_IDX_W_ADD_COLS] index */
      (
            (sr.clientID            = @clientID) 
        and (sr.patID               = @patID)
        and (sr.pracGrpSvcClsNameID = @groupSvcClassNameID)
        and (sr.svcType             = @svcTypeID)
        and (sr.dos between @startDate and @endDate)
        and (sr.id is not null)
      )
   
      and (sr.state not in (99,199))
      and (sr.planType = @planTypeID)
      and (sr.nameID = @altModalityNameID)
      and ((@pracID is null) or (sr.pracID = @pracID))      
    )
 
  end /* include alt*/

  set @totMinsSatisfied = isnull(@totMinsSatisfiedNme,0) + isnull(@totMinsSatisfiedAlt,0)

  if (@canCalcMinsExpected = 1)
  begin
    set @totMinsDiff = @totMinsExpected - @totMinsSatisfied
  end
  else
  begin
    set @totMinsDiff = @totMinsSatisfied
  end
end

insert into @recs (
    clientID
  , patID
  , totalMinutesExpected
  , totalMinutesSatisfied  
  , diffMinutesExpectedSatified
)
select 
    @clientID
  , @patID
  , @totMinsExpected
  , @totMinsSatisfied
  , @totMinsDiff  

return 
end 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_PLAN_TYPE_NAME_ID_SUMMARY_VIEW_DATA_CORE] TO [webuser]
GO
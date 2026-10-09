USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_Promised_Services_Delivery_Exceptions_View_Data_Core') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_Promised_Services_Delivery_Exceptions_View_Data_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENTS_Promised_Services_Delivery_Exceptions_View_Data_Core] (    
    @source                        int
  , @clientID                      bigint
  , @patID                         bigint
  , @svcTrackingClass              int
  , @spEdServiceCode               int
  , @orpDocStandardSelectionNameID bigint
  , @planStartDate                 date
  , @planEndDate                   date
  , @reviewed                      bit
  , @active                        bit
)
returns @recs table (
  id bigint
)       
as
begin      
    
declare @today       as datetime = getdate()
declare @currAuditID as bigint

if (@source not in (0,1)) return
if (@clientID is null)    return

/*------------------------------------ All ------------------------------------*/

if (@source = 0)
begin
  insert into @recs (
    id
  )
  select 
    ppsde.id 
  from dbo.PATIENTS_Promised_Services_Delivery_Exceptions as ppsde
  where (
        (ppsde.clientID = @clientID)
	and ((@patID            is null) or (ppsde.patID            = @patID))    
	and ((@svcTrackingClass is null) or (ppsde.svcTrackingClass = @svcTrackingClass))
	and ((@spEdServiceCode  is null) or (ppsde.spEdServiceCode  = @spEdServiceCode))	
	and ((@orpDocStandardSelectionNameID is null) or (ppsde.orpDocStandardSelectionNameID = @orpDocStandardSelectionNameID))
	and (dbo.[DATES_HAVE_OVERLAP](@planStartDate,@planEndDate, ppsde.dosStart, ppsde.dosEnd,1,1,0) = 1)
	and ((@reviewed is null) or (ppsde.reviewed = @reviewed))
	and (ppsde.active = @active)
  )
end

/*------------------------------------ Current CDE Audit ------------------------------------*/

else if (@source = 1)
begin

  /* Load audit data.  Audit dates replace plan start and end dates */

  select top 1
      @currAuditID   = ppscac.id  
    , @planStartDate = ppscac.startDate
    , @planEndDate   = dbo.DATE_VALUE_OR_REPLACEMENT_IF_GT_LT(ppscac.endDate,@today,1)
  from dbo.Patients_Promised_Services_CDE_Audits_Current as ppscac
  where (
        (ppscac.clientID = @clientID)
    and (ppscac.active = 1)
  )

  /* Get exceptions */

  insert into @recs(
    id
  )
  select 
    ppsde.id 
  from dbo.PATIENTS_Promised_Services_Delivery_Exceptions         as ppsde
  join dbo.Patients_Promised_Services_CDE_Audits_Current_Patients as ppscacp on ppscacp.patID = ppsde.patID
  where (
        (ppsde.clientID = @clientID)
	and ((@patID            is null) or (ppsde.patID            = @patID))    
	and ((@svcTrackingClass is null) or (ppsde.svcTrackingClass = @svcTrackingClass))
	and ((@spEdServiceCode  is null) or (ppsde.spEdServiceCode  = @spEdServiceCode))	
	and ((@orpDocStandardSelectionNameID is null) or (ppsde.orpDocStandardSelectionNameID = @orpDocStandardSelectionNameID))
	and (dbo.[DATES_HAVE_OVERLAP](@planStartDate,@planEndDate, ppsde.dosStart, ppsde.dosEnd,0,0,0) = 1)
    and ((@reviewed is null) or (ppsde.reviewed = @reviewed))
	and (ppsde.active = @active)
	and (ppscacp.patientsPromisedServicesCDEAuditsCurrentID = @currAuditID)

  )
end
else
begin
  return
end

return
  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].PATIENTS_Promised_Services_Delivery_Exceptions_View_Data_Core TO [webuser]
GO   



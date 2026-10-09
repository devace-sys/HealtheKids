USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_APPLY_MINS_CONSIDERED_SATISFIED_SET_POINT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_APPLY_MINS_CONSIDERED_SATISFIED_SET_POINT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_APPLY_MINS_CONSIDERED_SATISFIED_SET_POINT] (
    @clientID                 bigint
  , @spEdServiceCode          int
  , @spEdFreqCode             int
  , @minsPerFreq              int
  , @planInEffectStartDate    date
  , @planInEffectEndDate      date
  , @totalMinutesExpected     int
  , @totalMinutesSatisfied    int
) 
RETURNS int
AS
BEGIN

declare @minMinsPerFreqDaily   as int = 0
declare @minMinsPerFreqWeekly  as int = 0 
declare @minMinsPerFreqMonthly as int = 0
declare @minMinsPerFreq        as int = 0
declare @idx                   as bigint = null

/* Only SAI is supported at this time.  */

if (@spEdServiceCode != 330) return @totalMinutesSatisfied

/* Only daily, weekly, monthly frequencies are supported at this time. */

if (@spEdFreqCode not in (10,20,30)) return @totalMinutesSatisfied

select top 1 
    @idx                   = t1.id
  , @minMinsPerFreqDaily   = isnull(t1.minMinsPerFreqDaily,  0)
  , @minMinsPerFreqWeekly  = isnull(t1.minMinsPerFreqWeekly, 0)
  , @minMinsPerFreqMonthly = isnull(t1.minMinsPerFreqMonthly,0)
from dbo.Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points as t1
where (
      (t1.clientID = @clientID)

  /* TODO : Add date filter when we start collecting dates.  Start and end dates
            will be compared to plan start and end dates */

  and (t1.active   = 1)
)

/* If no record found exit */

if (@idx is null) return @totalMinutesSatisfied

/* Get the appropriate setpoint value */

if      (@spEdFreqCode = 10) set @minMinsPerFreq = @minMinsPerFreqDaily
else if (@spEdFreqCode = 20) set @minMinsPerFreq = @minMinsPerFreqWeekly
else if (@spEdFreqCode = 30) set @minMinsPerFreq = @minMinsPerFreqMonthly
else set @minMinsPerFreq = 0

/* If the setpoint is 0 exit */

if (@minMinsPerFreq = 0) return @totalMinutesSatisfied

/* If the mins per frequency reaches or crosses setpoint then consider 
 * mins satisfied = mins expected
 */

if (@minsPerFreq >= @minMinsPerFreq)
begin
  return @totalMinutesExpected
end

return @totalMinutesSatisfied

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXEC ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_APPLY_MINS_CONSIDERED_SATISFIED_SET_POINT] TO [webuser]
GO
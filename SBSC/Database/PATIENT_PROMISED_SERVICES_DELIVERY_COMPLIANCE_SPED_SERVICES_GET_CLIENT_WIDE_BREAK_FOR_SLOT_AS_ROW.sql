USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_CLIENT_WIDE_BREAK_FOR_SLOT_AS_ROW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_CLIENT_WIDE_BREAK_FOR_SLOT_AS_ROW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_CLIENT_WIDE_BREAK_FOR_SLOT_AS_ROW] (
    @clientID        bigint
  , @planStartDate   date
  , @planEndDate     date
  , @spEdFreqCode    int
  , @minsPerFreq     int
  , @dosStart        datetime
  , @dosEnd          datetime
) 
RETURNS table
AS
return
(     
  select top 1
    meb2.totMins
  from dbo.CLIENT_SCHOOL_SESSION_CLIENT_WIDE_CALC_DATES_NOT_IN_SESSION (@clientID, @planStartDate, @planEndDate) as cwb
  
  cross apply (
    select top 1 
      meb1.totMins 
    from dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK_AS_ROW (@dosStart, @dosEnd, @spEdFreqCode, @minsPerFreq) as meb1
  ) as meb2
  where ( 
    ((@dosStart >= cwb.startDate) and (@dosEnd <= cwb.endDate)) /* Eliminates duplicate break assignment */
  )
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_CLIENT_WIDE_BREAK_FOR_SLOT_AS_ROW] TO [webuser]
GO
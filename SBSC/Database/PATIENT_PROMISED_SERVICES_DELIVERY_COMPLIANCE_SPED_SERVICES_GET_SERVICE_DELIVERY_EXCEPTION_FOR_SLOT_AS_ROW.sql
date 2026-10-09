USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_DELIVERY_EXCEPTION_FOR_SLOT_AS_ROW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_DELIVERY_EXCEPTION_FOR_SLOT_AS_ROW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_DELIVERY_EXCEPTION_FOR_SLOT_AS_ROW] (
    @clientID        bigint
  , @patID           bigint
  , @planStartDate   date
  , @planEndDate     date
  , @spEdServiceCode int
  , @spEdFreqCode    int
  , @minsPerFreq     int
  , @dosStart        datetime
  , @dosEnd          datetime
) 
RETURNS table
AS
return
(     
  select distinct top 1 /* Distict to deal with possible dups from merges */       
      numMins = ppsde.numMinsMissing
    , ppsdear.detailSlotSubFromMinutesExpected
    , ppsdear.detailSlotAddToMinutesSatisfied
  from dbo.PATIENTS_Promised_Services_Delivery_Exceptions              as ppsde
  join dbo.PATIENTS_Promised_Services_Delivery_Exception_Added_Reasons as ppsdear on ppsdear.id = ppsde.deliveryExceptionAddedReasonID
  where (
            (ppsde.clientID        = @clientID)
        and (ppsde.patID           = @patID)               
	    and (ppsde.planStartDate   = @planStartDate)
        and (ppsde.planEndDate     = @planEndDate)				     		  							                                                         
	    and (ppsde.spEdServiceCode = @spEdServiceCode)
        and (ppsde.spEdFreqCode    = @spEdFreqCode)
        and (ppsde.minsPerFreq     = @minsPerFreq)
		and (ppsde.dosStart        = @dosStart)
		and (ppsde.dosEnd          = @dosEnd)
	    and (ppsde.active = 1)
  )
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_DELIVERY_EXCEPTION_FOR_SLOT_AS_ROW] TO [webuser]
GO
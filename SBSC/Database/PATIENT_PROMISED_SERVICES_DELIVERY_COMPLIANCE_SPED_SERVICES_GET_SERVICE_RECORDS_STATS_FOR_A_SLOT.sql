USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_STATS_FOR_A_SLOT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_STATS_FOR_A_SLOT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_STATS_FOR_A_SLOT] (
    @clientID                      bigint
  , @patID                         bigint
  , @pracID                        bigint = null
  , @spEdServiceCode               int
  , @dosStart                      datetime
  , @dosEnd                        datetime
  , @patAbsentMinsAreSatisfiedMins bit =  1
) 
RETURNS table
AS
return
(     

/* Note: Nulls are returned if no service records have been entered yet
 * calling routines need to account for this (use outer apply)
 */

select 
  
    numMinsSatisfiedTot = sum(t1.numMinsSatisfied)
  , numPatAbsentTot     = sum(t1.numPatAbsent)
  , numPracAbsentTot    = sum(t1.numPracAbsent)  
  , numSvcRecs          = count(t1.id)

from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_DATA_FOR_A_SLOT (
      @clientID
    , @patID 
    , @pracID
    , @spEdServiceCode 
    , @dosStart 
    , @dosEnd 
    , @patAbsentMinsAreSatisfiedMins ) as t1
group by 
    t1.clientID
  , t1.patID
) 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_STATS_FOR_A_SLOT] TO [webuser]
GO
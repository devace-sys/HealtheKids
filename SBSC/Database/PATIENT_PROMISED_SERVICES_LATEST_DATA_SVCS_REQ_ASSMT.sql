USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA_SVCS_REQ_ASSMT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA_SVCS_REQ_ASSMT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_LATEST_DATA_SVCS_REQ_ASSMT] (
    @clientID              bigint
  , @patID                 bigint
  , @planInEffectStartDate date
  , @planInEffectEndDate   date  
)    

RETURNS 
TABLE 
AS
RETURN
(

select 
    pps1.clientID
  , pps1.patID
  , numOfHealthSvcsReqAssmt        = count(pps1.spEdServiceCode) /* Any sped service */
  , numOfMentalHealthSvcsReqAssmt  = sum(iif (pps1.spEdServiceCode in (510, 515, 525, 530, 535),1,0))
  , numOfOTSvcsReqAssmt            = sum(iif (pps1.spEdServiceCode in (450),1,0))
  , numOfPTSvcsReqAssmt            = sum(iif (pps1.spEdServiceCode in (460),1,0))
  , numOfSpeechSvcsReqAssmt        = sum(iif (pps1.spEdServiceCode in (415,710),1,0))  /* EAW: Removed 730 replaced with 710 */
  , numOfOMSvcsReqAssmt            = sum(iif (pps1.spEdServiceCode in (730),1,0))  

from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA (
      @clientID
    , @patID
    , null
    , null
	, null
	, null
	, null
    , @planInEffectStartDate
    , @planInEffectEndDate
    , null
    , null) as pps1
group by 
    pps1.clientID
  , pps1.patID
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_LATEST_DATA_SVCS_REQ_ASSMT] TO [webuser]
GO

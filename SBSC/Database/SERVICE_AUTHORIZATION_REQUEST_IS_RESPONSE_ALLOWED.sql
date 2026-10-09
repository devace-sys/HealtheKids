USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_IS_RESPONSE_ALLOWED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUEST_IS_RESPONSE_ALLOWED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUEST_IS_RESPONSE_ALLOWED] (

    @requestIsActive                        bit
  , @requestIsClosed                        bit
  , @viewingOrEnteringUserResponseRequired  bit
  , @responseEntryAllowedByRa               bit
  , @viewingOrEnteringUserIsRa              bit
  , @responseEntryAllowedByRdp              bit
  , @viewingOrEnteringUserIsRdp             bit
  , @responseEntryAllowedByLEAAdmin         bit
  , @viewingOrEnteringUserIsLEAAdmin        bit
  , @responseEntryAllowedByPCALStaff        bit
  , @viewingOrEnteringUserIsPCALStaff       bit

) 
RETURNS BIT
WITH SCHEMABINDING 
AS     
BEGIN    

  if (@requestIsActive = 0) return 0
  if (@requestIsClosed = 1) return 0
  
  if (@viewingOrEnteringUserResponseRequired = 1) return 1
  
  if ((@responseEntryAllowedByRa        = 1) and (@viewingOrEnteringUserIsRa        = 1)) return 1
  if ((@responseEntryAllowedByRdp       = 1) and (@viewingOrEnteringUserIsRdp       = 1)) return 1
  if ((@responseEntryAllowedByLEAAdmin  = 1) and (@viewingOrEnteringUserIsLEAAdmin  = 1)) return 1
  if ((@responseEntryAllowedByPCALStaff = 1) and (@viewingOrEnteringUserIsPCALStaff = 1)) return 1

  return 0

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_IS_RESPONSE_ALLOWED] TO [webuser]
GO

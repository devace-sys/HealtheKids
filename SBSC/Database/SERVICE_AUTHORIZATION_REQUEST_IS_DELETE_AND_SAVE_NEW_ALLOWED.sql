USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_IS_DELETE_AND_SAVE_NEW_ALLOWED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUEST_IS_DELETE_AND_SAVE_NEW_ALLOWED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUEST_IS_DELETE_AND_SAVE_NEW_ALLOWED] (
    @requestIsActive                        bit
  , @requestIsClosed                        bit  
  , @currentResponseCode                    bigint
  , @deleteAndSaveNewAllowedByRa            bit
  , @viewingOrEnteringUserIsRa              bit
  , @deleteAndSaveNewAllowedByRdp           bit
  , @viewingOrEnteringUserIsRdp             bit
  , @deleteAndSaveNewAllowedByLEAAdmin      bit
  , @viewingOrEnteringUserIsLEAAdmin        bit
  , @deleteAndSaveNewAllowedByPCALStaff     bit
  , @viewingOrEnteringUserIsPCALStaff       bit

) 
RETURNS BIT
WITH SCHEMABINDING 
AS     
BEGIN    

  if (@requestIsActive = 0) return 0
  if (@requestIsClosed = 1) return 0
  if (@currentResponseCode != 2000) return 0 /* Only pending allowed */

  if ((@deleteAndSaveNewAllowedByRa        = 1) and (@viewingOrEnteringUserIsRa        = 1)) return 1
  if ((@deleteAndSaveNewAllowedByRdp       = 1) and (@viewingOrEnteringUserIsRdp       = 1)) return 1
  if ((@deleteAndSaveNewAllowedByLEAAdmin  = 1) and (@viewingOrEnteringUserIsLEAAdmin  = 1)) return 1
  if ((@deleteAndSaveNewAllowedByPCALStaff = 1) and (@viewingOrEnteringUserIsPCALStaff = 1)) return 1

  return 0

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_IS_DELETE_AND_SAVE_NEW_ALLOWED] TO [webuser]
GO

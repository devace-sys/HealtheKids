USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_VALID_CSIS_SSID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION IS_VALID_CSIS_SSID
GO    

CREATE FUNCTION [dbo].[IS_VALID_CSIS_SSID] (
  @SSID nvarchar(50)
)
RETURNS BIT
WITH SCHEMABINDING 
AS
BEGIN
  /* SSID is a 10 digit number.  Leading 0s are expected. */
  if (@SSID is null) return 0
  if (ltrim(rtrim(@SSID)) not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') return 0
  return 1   
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[IS_VALID_CSIS_SSID] TO [webuser]
GO

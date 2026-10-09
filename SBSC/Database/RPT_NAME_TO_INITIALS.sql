USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_NAME_TO_INITIALS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_NAME_TO_INITIALS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_NAME_TO_INITIALS](
    @firstName nvarchar(100)
  , @lastName nvarchar(100))
RETURNS NVARCHAR(2)
WITH SCHEMABINDING 
AS     
BEGIN    
  return trim(left(isnull(@firstName,N' '),1)) + trim(left(isnull(@lastName,N' '),1))
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_NAME_TO_INITIALS] TO [webuser]
GO

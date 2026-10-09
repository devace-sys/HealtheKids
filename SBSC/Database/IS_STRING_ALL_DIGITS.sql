USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_STRING_ALL_DIGITS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION IS_STRING_ALL_DIGITS
GO    

CREATE FUNCTION [dbo].[IS_STRING_ALL_DIGITS] (
  @value nvarchar(255)
)
RETURNS BIT
WITH SCHEMABINDING 
AS
BEGIN
  set @value = ltrim(rtrim(isnull(@value,'')))
  if (@value = '') return 0
  if (@value not LIKE '%[^0-9]%') return 1
  return 0    
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[IS_STRING_ALL_DIGITS] TO [webuser]
GO

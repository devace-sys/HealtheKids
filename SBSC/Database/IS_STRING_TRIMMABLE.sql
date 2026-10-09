USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_STRING_TRIMMABLE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION IS_STRING_TRIMMABLE
GO    

CREATE FUNCTION [dbo].[IS_STRING_TRIMMABLE] (
  @value nvarchar(255)
)
RETURNS BIT
WITH SCHEMABINDING 
AS
BEGIN
  if (@value is null) return 0
  if (32 in (ASCII(@value),  ASCII(REVERSE(@value)))) return 1
  return 0    
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[IS_STRING_TRIMMABLE] TO [webuser]
GO

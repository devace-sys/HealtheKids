USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FLAG_STRING_TO_BIT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FLAG_STRING_TO_BIT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[FLAG_STRING_TO_BIT](@valueIn varchar(256), @nullOrEmptyIsFalse bit = 0) RETURNS bit 
with schemabinding 
AS    
BEGIN    
  set @valueIn  = lower(trim(isnull(@valueIn,'')))
  if ((@valueIn = '') and (@nullOrEmptyIsFalse = 0)) return null
  if (@valueIn in ('yes', 'y', 'true',  't', '1'))   return 1
  if (@valueIn in ('no',  'n', 'false', 'f', '0'))   return 0
  return null
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[FLAG_STRING_TO_BIT] TO [webuser]
GO

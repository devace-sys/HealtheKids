USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BIT_TO_YN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BIT_TO_YN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[BIT_TO_YN](@bitin bit) RETURNS nvarchar(1) 
WITH SCHEMABINDING 
AS    
BEGIN    
  declare @flagOut as nvarchar(1)    
  if (@bitin is null) return null
  if (@bitin = 1) set @flagOut = 'Y' 
  else set @flagOut = 'N'     
  return @flagOut     
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[BIT_TO_YN] TO [webuser]

GO
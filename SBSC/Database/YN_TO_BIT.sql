USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.YN_TO_BIT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.YN_TO_BIT
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[YN_TO_BIT](@ynin nvarchar(1)) RETURNS bit 
with schemabinding 
AS    
BEGIN    
  declare @flagOut as bit    
  if (@ynin is not null) set @ynin = upper(@ynin)    
  if (@ynin= 'Y') set @flagOut = 1 else set @flagOut = 0     
  return @flagOut     
END    
GO

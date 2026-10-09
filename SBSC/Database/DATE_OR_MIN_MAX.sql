USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_OR_MIN_MAX') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_OR_MIN_MAX
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DATE_OR_MIN_MAX](@datein DATETIME, @minmax AS INT) RETURNS DATETIME AS     
BEGIN    
  
  if (@datein IS NOT NULL)                  return @datein
  if ((@datein IS NULL) AND (@minmax = -1)) return dbo.CONST_MIN_DATETIME()  
  if ((@datein IS NULL) AND (@minmax =  1)) return dbo.CONST_MAX_DATETIME()  
  return null
END    
    
GO

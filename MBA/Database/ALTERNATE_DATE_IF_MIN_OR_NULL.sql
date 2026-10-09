USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ALTERNATE_DATE_IF_MIN_OR_NULL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ALTERNATE_DATE_IF_MIN_OR_NULL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[ALTERNATE_DATE_IF_MIN_OR_NULL](@dateIn DATETIME, @altDate DATETIME) 
RETURNS DATETIME
AS     
BEGIN    
  
  DECLARE @dateOut as DATETIME
  
  SET @dateOut = @dateIn
  
  IF (@dateIn IS NULL)                     SET @dateOut = @altDate    
  IF (@dateIn <= dbo.CONST_MIN_DATETIME()) SET @dateOut = @altDate
  
  RETURN @dateOut
  
END    
GO

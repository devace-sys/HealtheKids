USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_END') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_END
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[DATE_END](@refDate DATETIME) 
RETURNS DATETIME
WITH SCHEMABINDING 
 AS     
BEGIN    
  IF @refDate IS NULL SET @refDate = GETDATE()    
  DECLARE @endDate AS DATETIME    
  SET @endDate = CONVERT(DATETIME,(CONVERT(varchar(8), @refDate, 112) + ' 23:59:59'))    
  RETURN @endDate    
END    
GO

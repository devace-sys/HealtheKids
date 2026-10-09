USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_IS_PAST_CURRENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_IS_PAST_CURRENT
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[DATE_IS_PAST_CURRENT](@refDate DATETIME)
RETURNS INT AS     
BEGIN    
  IF @refDate IS NULL RETURN 0    
  RETURN dbo.DATE_IS_PAST(GETDATE(),@refDate)      
END    
GO

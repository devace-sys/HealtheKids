USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PAD_LEFT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PAD_LEFT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_PAD_LEFT](@strIn AS VARCHAR(100), @padLen AS INT, @padChar AS NVARCHAR(1)) 
RETURNS VARCHAR(100) 
WITH SCHEMABINDING 
AS     
    
/***************************************************************************    
 * RPT_PAD_LEFT */    
/**    
 * Pads left side of strIn with padChar x padLen.
 * Padding technique courtesy of Cade Roux
 * http://stackoverflow.com/q/121864 
 *
 * @param  strIn         string in
 * @param  padChar       character to pad with
 * @param  padLen        amount of padding     
 * @return               string in padded with padChar x padLen
 ***************************************************************************/            
    
BEGIN    
  DECLARE @strOut AS VARCHAR(100)
  SET @strOut = ''
  SET @strOut = REPLICATE(@padChar, @padLen - LEN(@strIn)) + @strIn 
  RETURN @strOut
END  
GO

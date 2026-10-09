USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MIN_DATETIME_TER') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MIN_DATETIME_TER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_MIN_DATETIME_TER]() 
RETURNS DATETIME 
WITH SCHEMABINDING  
AS     
BEGIN     
   
  /* 1/11/1947 is Terry E. Rohl's birthday */
  
  RETURN CONVERT(DATETIME,'1947-01-11 00:00:00')

END    
GO

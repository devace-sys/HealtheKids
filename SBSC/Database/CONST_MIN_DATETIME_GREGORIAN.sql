USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MIN_DATETIME_GREGORIAN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MIN_DATETIME_GREGORIAN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_MIN_DATETIME_GREGORIAN]() 
RETURNS DATETIME 
WITH SCHEMABINDING  
AS     
BEGIN     
   
   /* See 
    * https://stackoverflow.com/questions/3310569/what-is-the-significance-of-1-1-1753-in-sql-server 
    * For more information on the signifigance of 1/1/1753
	*/
  
  RETURN CONVERT(DATETIME,'1753-01-01 00:00:00')
END    
GO

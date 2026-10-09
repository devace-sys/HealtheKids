USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_DIRECT_SUPERVISION_REQUIRED_START_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_DIRECT_SUPERVISION_REQUIRED_START_DATE 
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

 CREATE FUNCTION [dbo].[CONST_DIRECT_SUPERVISION_REQUIRED_START_DATE]() RETURNS DATE WITH SCHEMABINDING  
AS     
BEGIN     
  RETURN CONVERT(DATE,'7/1/2015')    
END    
GO
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MAX_DAILY_PRAC_MIN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MAX_DAILY_PRAC_MIN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Max for most pracs is 8 hrs (480 mins) */    

CREATE FUNCTION [dbo].[CONST_MAX_DAILY_PRAC_MIN]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 480 END    
GO

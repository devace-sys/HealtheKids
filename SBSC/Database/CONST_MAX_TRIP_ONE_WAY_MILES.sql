USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MAX_TRIP_ONE_WAY_MILES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MAX_TRIP_ONE_WAY_MILES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Max one way trip should be 75 miles in most cases */    

CREATE FUNCTION [dbo].[CONST_MAX_TRIP_ONE_WAY_MILES]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 75 END    
GO

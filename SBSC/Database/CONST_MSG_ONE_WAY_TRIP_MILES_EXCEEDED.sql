USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MSG_ONE_WAY_TRIP_MILES_EXCEEDED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MSG_ONE_WAY_TRIP_MILES_EXCEEDED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_MSG_ONE_WAY_TRIP_MILES_EXCEEDED]() 
RETURNS VARCHAR(1000) WITH SCHEMABINDING 
AS 
BEGIN 
RETURN 'At least one trip is over 75 miles'
END    
GO

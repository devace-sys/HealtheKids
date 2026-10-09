USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MSG_PRAC_MAX_DAILY_MINS_REACHED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MSG_PRAC_MAX_DAILY_MINS_REACHED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_MSG_PRAC_MAX_DAILY_MINS_REACHED]() 
RETURNS VARCHAR(1000) WITH SCHEMABINDING 
AS 
BEGIN 
RETURN 'Including this You are recording more than 8 hours of work for {1}.'
END    
GO

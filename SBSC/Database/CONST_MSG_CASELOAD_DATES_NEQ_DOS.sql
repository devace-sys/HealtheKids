USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MSG_CASELOAD_DATES_NEQ_DOS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MSG_CASELOAD_DATES_NEQ_DOS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_MSG_CASELOAD_DATES_NEQ_DOS]() 
RETURNS VARCHAR(1000) WITH SCHEMABINDING 
AS 
BEGIN 
/* Note: This message has a variable placeholder. */
RETURN 'This patient has {1} services recorded from {2} to {3}.  Your {4} date {5} is outside of this range.'
END    
GO

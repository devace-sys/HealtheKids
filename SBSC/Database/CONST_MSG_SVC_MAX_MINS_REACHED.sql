USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MSG_SVC_MAX_MINS_REACHED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MSG_SVC_MAX_MINS_REACHED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_MSG_SVC_MAX_MINS_REACHED]() 
RETURNS VARCHAR(1000) WITH SCHEMABINDING 
AS 
BEGIN 
/* Note: This message has a variable placeholder. */
RETURN 'At least one of your services is more than {1} hours.'
END    
GO

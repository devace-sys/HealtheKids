USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY]() RETURNS smallint WITH SCHEMABINDING 
AS BEGIN RETURN 4 END    
GO

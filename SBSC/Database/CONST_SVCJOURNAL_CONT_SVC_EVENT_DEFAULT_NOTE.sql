USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SVCJOURNAL_CONT_SVC_EVENT_DEFAULT_NOTE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SVCJOURNAL_CONT_SVC_EVENT_DEFAULT_NOTE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_SVCJOURNAL_CONT_SVC_EVENT_DEFAULT_NOTE]() RETURNS varchar(100) WITH SCHEMABINDING 
AS BEGIN RETURN 'All defined and expected outcomes were met'
END    
GO

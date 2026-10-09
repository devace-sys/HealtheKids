USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SVC_TRACKING_CLASS_SPED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SVC_TRACKING_CLASS_SPED
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CONST_SVC_TRACKING_CLASS_SPED]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 100 END    
GO

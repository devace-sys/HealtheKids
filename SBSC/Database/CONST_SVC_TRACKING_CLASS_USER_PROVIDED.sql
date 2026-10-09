USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CONST_SVC_TRACKING_CLASS_USER_PROVIDED]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 300 END    
GO

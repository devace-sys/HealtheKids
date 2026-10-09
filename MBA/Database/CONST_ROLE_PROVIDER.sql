USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_ROLE_PROVIDER') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_ROLE_PROVIDER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_ROLE_PROVIDER]() RETURNS uniqueidentifier 
WITH SCHEMABINDING 
AS 
BEGIN 
RETURN CONVERT(uniqueidentifier,'75AEDF15-EC30-435B-8DE5-9BFF8A812418')
END    
GO

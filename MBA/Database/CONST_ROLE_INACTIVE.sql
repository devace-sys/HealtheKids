USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_ROLE_INACTIVE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_ROLE_INACTIVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_ROLE_INACTIVE]() RETURNS uniqueidentifier 
WITH SCHEMABINDING 
AS 
BEGIN 
RETURN CONVERT(uniqueidentifier,'E84AB903-36EE-4016-BD8E-3D6CA372E096')
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CONST_ROLE_INACTIVE] TO [webuser]
GO

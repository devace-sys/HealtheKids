USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SITE_IS_UNKNOWN_FLAG') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SITE_IS_UNKNOWN_FLAG
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SITE_IS_UNKNOWN_FLAG] (@siteName nvarchar(50), @siteCDS7 nchar(7)) 
RETURNS BIT 
AS    
BEGIN    
  set @siteName = trim(@siteName)       
  if ((@siteName = dbo.CONST_UNKNOWN_SCHOOL_NAME()) and (dbo.CDS_7_IS_X_CODE(@siteCDS7) = 1)) return 1
  return 0      
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SITE_IS_UNKNOWN_FLAG] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_BIT_TO_YN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_BIT_TO_YN
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[RPT_BIT_TO_YN](@flag AS BIT) 
RETURNS VARCHAR(3) 
WITH SCHEMABINDING
AS     
BEGIN    
  declare @yn as varchar(3)    
  if (@flag = 1) set @yn = 'Yes' else set @yn = 'No'    
  return @yn    
END  
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT EXECUTE ON  [dbo].[RPT_BIT_TO_YN] TO [webuser]
GO

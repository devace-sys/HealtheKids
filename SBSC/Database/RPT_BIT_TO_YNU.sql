USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_BIT_TO_YNU') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_BIT_TO_YNU
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[RPT_BIT_TO_YNU](@flag AS BIT) 
RETURNS VARCHAR(7) 
WITH SCHEMABINDING
AS     
BEGIN
  declare @yn as varchar(7)    
  if (@flag = 1) set @yn = 'Yes'
  else if (@flag = 0) set @yn = 'No'    
  else set @yn = 'Unknown'
  return @yn    
END  
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT EXECUTE ON  [dbo].[RPT_BIT_TO_YNU] TO [webuser]
GO

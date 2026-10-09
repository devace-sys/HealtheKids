USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_BIT_TO_YNB') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_BIT_TO_YNB
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_BIT_TO_YNB](@flag AS BIT) 
RETURNS VARCHAR(7) 
WITH SCHEMABINDING
AS     
BEGIN
  declare @ynb as varchar(7)    
  if      (@flag = 1) set @ynb = 'Yes'
  else if (@flag = 0) set @ynb = 'No'    
  else                set @ynb = ''
  return @ynb    
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_BIT_TO_YNB] TO [webuser]
GO

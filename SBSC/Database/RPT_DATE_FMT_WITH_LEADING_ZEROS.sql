USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_DATE_FMT_WITH_LEADING_ZEROS](@value as datetime) 
RETURNS VARCHAR(10) 
WITH SCHEMABINDING 
AS     

/***************************************************************************    
 * RPT_DATE_FMT_WITH_LEADING_ZEROS */    
/**    
 * Returns the same format as RPT_DATE_FMT but provides leading zeros
 * for date parts less than 9.
 *
 * @param  value         datetime in
 * @return               date as string mm/dd/yyyy
 ***************************************************************************/            

BEGIN      
  declare @dateOut as varchar(50) = ''
  if (@value is null) return @dateOut
  set @dateOut = format(@value,'MM/dd/yyyy')
  return @dateOut
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_DATE_FMT_WITH_LEADING_ZEROS] TO [webuser]
GO

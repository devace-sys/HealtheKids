USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE] (@value DATE) RETURNS INT 
WITH SCHEMABINDING
AS     
BEGIN    

  /* Courtesy of https://stackoverflow.com/a/40515900 
   * The choice of 1899-12-30 is to handle the differences between how excel and sql 
   * handle 1900-01-01 and leap years.
   * More on that https://www.wambooli.com/blog/?p=3809. */

  if (@value is null) return -1
  declare @refDate as date = convert(date,'1899-12-30')
  return datediff(DD,@refDate,@value)          

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE] TO [webuser]
GO
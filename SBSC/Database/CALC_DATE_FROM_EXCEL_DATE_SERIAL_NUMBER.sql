USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER] (@value int) RETURNS date
WITH SCHEMABINDING
AS     
BEGIN    

  /* Courtesy of https://stackoverflow.com/a/13850777
   * The choice of 1899-12-30 is to handle the differences between how excel and sql 
   * handle 1900-01-01 and leap years.
   * More on that https://www.wambooli.com/blog/?p=3809. */

  if (@value is null) return null
  if (@value = 0) return null
  declare @refDate as date = convert(date,'1899-12-30')
  return convert(date,(dateadd(d,@value,@refDate)))

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER] TO [webuser]
GO
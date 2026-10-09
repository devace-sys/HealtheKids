USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_CREATE_FROM_PARTS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_CREATE_FROM_PARTS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION DATE_CREATE_FROM_PARTS (@mm   as int,     
                                        @dd   as int,
                                        @yyyy as int)

returns datetime
WITH SCHEMABINDING   

/***************************************************************************    
 * DATE_CREATE_FROM_PARTS */    
/**    
 * Creates a date from date parts. 
 * 
 * Date calculation portion courtesey of Charles Bretana
 * http://stackoverflow.com/a/267016
 *
 * Theory of Operation from Charles
 * --------------------------------
 *
 * "The calculation relies on the fact that SQL Server's internal 
 * representation for datetime and smalldatetime values is a two part value
 * the first part of which is an integer representing the number of days 
 * since 1 Jan 1900, and the second part is a decimal fraction representing 
 * the fractional portion of one day (for the time).
 * So the integer value 0 (zero) always translates directly into 
 * Midnight morning of 1 Jan 1900." 
 *
 * @param    mm      Month (1-12)
 * @param    dd      Day   (1-31)
 * @param    yyyy    Year  (1900-9999)
 * @return           Datetime containing mm-dd-yyyy or null if there 
 *                   was a problem.
 ***************************************************************************/            
     
as           
begin    
  
  declare @newdate as datetime
  
  /*-------------------------------
   * Catch most parameter issues
   * but not all
   *------------------------------*/

  if (@mm   is null) return null
  if (@dd   is null) return null
  if (@yyyy is null) return null
  if (@mm < 1)       return null
  if (@mm > 12)      return null
  if (@dd < 1)       return null
  if (@dd > 31)      return null  
  if (@yyyy < 1900)  return null
  if (@yyyy > 9999)  return null
  
  /*-------------------------------
   * Compute new date 
   *------------------------------*/

  set @newdate =  DateAdd(day, @dd - 1, 
                    DateAdd(month, @mm - 1, 
                      DateAdd(Year, @yyyy - 1900, 0)))

  /*-------------------------------
   * The date calculation will not
   * catch issues with invalid
   * days in a month.  It will
   * return the nearest possible
   * day however.
   *
   * For example:
   *
   *   mm = 2, dd = 29, yyyy = 2013
   *   results in 3/1/2013
   *
   * So we check the results here
   *------------------------------*/

  if datepart (mm,   @newdate)  != @mm   return null
  if datepart (dd,   @newdate)  != @dd   return null
  if datepart (yyyy, @newdate)  != @yyyy return null
  
  return @newdate
  
end    
    
GO

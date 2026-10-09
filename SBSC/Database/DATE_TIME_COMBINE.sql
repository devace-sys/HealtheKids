USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_TIME_COMBINE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_TIME_COMBINE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION DATE_TIME_COMBINE (
  @dateIn datetime
, @timeIn time
)

returns datetime
WITH SCHEMABINDING   

/***************************************************************************    
 * DATE_TIME_COMBINE */    
/**    
 * Creates a datetime from datetime with no time and time
 * Based on https://blog.sqlauthority.com/2020/07/12/how-to-combine-time-and-date-in-sql-server-interview-question-of-the-week-285/
 *
 ***************************************************************************/            
     
as           
begin    
  if (@dateIn is null) set @dateIn = convert(date,getdate())
  if (@timeIn is null) set @timeIn = convert(time,'00:00')
  return DATEADD(DAY,DATEDIFF(DAY, 0, @dateIn),CAST(@timeIn AS DATETIME))
end    
    
GO

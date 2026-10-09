USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_MONTH_START_END') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_MONTH_START_END
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[DATE_MONTH_START_END] (@refDate datetime, @startEnd smallint)     
returns datetime    
WITH SCHEMABINDING 
    
/***************************************************************************    
 * DATE_MONTH_START_END */    
/**    
 * Returns the start or end of month date for the given refDate and value of
 * startEnd.  If refDate is not provided, the current date is used.  If
 * startEnd is not provided we default to start.  If startEnd is not a valid
 * option we default to start.
 *    
 * Start and end of month calulations courtesy of pinaldave
 * http://blog.sqlauthority.com/2007/08/18/sql-server-find-last-day-of-any-month-current-previous-next/
 *
 * @param  refDate         Reference date 
 * @param  startEnd        0 = start
 *                         1 = end
 * @return                 datetime    
 ***************************************************************************/            
     
as           
begin    
    
/*-------------------------------    
 * Set defaults if needed
 *------------------------------*/    

if @refDate  is null set @refDate  = getdate()
if @startEnd is null set @startEnd = 0
if @startEnd < 0     set @startEnd = 0
if @startEnd > 1     set @startEnd = 0   

/*-------------------------------    
 * Calculate start or end of
 * month
 *------------------------------*/ 
 
declare @dateOut as datetime

if (@startEnd = 0)
  -- Start of month
  set @dateOut = dateadd(dd,-(day(@refDate)-1),@refDate)
else
  -- End of month
  set @dateOut = dateadd(s,-1,dateadd(mm, datediff(m,0,@refDate)+1,0))

return @dateOut
    
end    
    
GO

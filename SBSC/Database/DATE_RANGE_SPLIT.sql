USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_RANGE_SPLIT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_RANGE_SPLIT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DATE_RANGE_SPLIT] (@startDate datetime,
                                          @endDate   datetime)
returns @datesplit TABLE(id int identity(1,1) PRIMARY KEY,
                         startDate  datetime,
                         endDate    datetime,
                         monthYear  varchar(8)) AS

/***************************************************************************
 * DATE_RANGE_SPLIT */
/**
 * For a given start and end date range split it into individual date 
 * ranges partitioned by month/year and return these values.
 *  
 * For example if the date range 1/1/2010 to 3/31/2010 was passed in
 * we would split this range into three partitions.
 *
 *   1.  1/1/2010 - 1/31/2010
 *   2.  2/1/2010 - 2/28/2010
 *   3.  3/1/2010 - 3/31/2010
 *
 * Note: The day component of the date is disregarded, so if you
 * pass in 1/15/2010 to 3/2/2010 it will result in the same output
 * as shown above.
 *
 * @param  startDate       Start date    
 * @param  endDate         End date    
 * @return                 Table
 ***************************************************************************/  

begin

declare @startMonth   as int
declare @endMonth     as int

/*-------------------------------    
 * If the input parameters are null
 * or if @startDate > @endDate     
 * get out    
 *------------------------------*/       
      
if ((@startDate is null) or (@endDate is null) or (@startDate > @endDate)) return     
                                                   
/*-------------------------------    
 * Compute the # of months in the
 * given date range    
 *------------------------------*/

set @startMonth = month(@startDate)
set @endMonth   = month(@endDate)
       
 /*-------------------------------    
  * If the date range spans years
  * accommodate this.    
  *------------------------------*/   
     
if (year(@startDate) != year(@endDate))
begin
  declare @cntmon as int
  declare @years as int
  set @cntmon     = 12 - month(@startDate) + (month(@endDate)) + 1
  set @years = datepart(yy,@enddate) - datepart(yy,@startDate)
  set @cntmon = @cntmon + ((@years - 1) * 12)
  set @startMonth = 1
  set @endMonth   = @cntmon
end

/*-------------------------------    
 * Go through each month
 * and create our output records
 * The number of months determines
 * the number of records
 *------------------------------*/   

declare @sDate     as datetime
declare @eDate     as datetime
declare @refDate   as datetime
declare @monthYear as varchar(9)  

set @refDate = @startDate

while (@startMonth <= @endMonth)
begin
  
  set @sDate     = dbo.DATE_MONTH_START_END(@refDate,0)
  set @eDate     = dbo.DATE_MONTH_START_END(@refDate,1)  
  set @monthYear = convert(varchar(3), datename(month,   @refDate)) + ' ' + 
                   convert(varchar(4), datepart(yyyy, @refDate))
                      
  insert into @datesplit values (@sDate, @eDate, @monthyear)
         
  set @refDate      =  dateadd(month,1,@refDate)
  set @startMonth   =  @startMonth + 1
     
end
   
return
end

GO

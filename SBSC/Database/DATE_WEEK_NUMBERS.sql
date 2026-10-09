USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_WEEK_NUMBERS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_WEEK_NUMBERS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[DATE_WEEK_NUMBERS] (@refDate datetime) 
    
returns @recs TABLE ([ReferenceDate]        datetime, 
                     [FirstDateOfYear]      datetime,
                     [FirstDateOfMonth]     datetime,
                     [LastDateOfMonth]      datetime,
                     [LastDateOfYear]       datetime,
                     [WeekNumberMinYear]    int,
                     [WeekNumberMinMonth]   int, 
                     [WeekNumberCurrent]    int, 
                     [WeekNumberMaxMonth]   int,
                     [WeekNumberMaxYear]    int,
                     [IsFirstWeekOfYear]    bit,
                     [IsFirstWeekOfMonth]   bit,
                     [IsLastWeekOfMonth]    bit,
                     [IsLastWeekOfYear]     bit
                     )   
    
/***************************************************************************    
 * DATE_WEEK_NUMBERS */    
/**    
 *
 * @param  refDate         Reference date 
 * @return                 Table of values
 ***************************************************************************/            
     
as           
begin    
    
declare @yearVal             as int
declare @yearStr             as varchar(4)
declare @firstDateOfMonthVal as datetime
declare @lastDateOfMonthVal  as datetime
declare @firstDateOfYearVal  as datetime
declare @firstDateOfYearStr  as varchar(1000)
declare @lastDateOfYearVal   as datetime
declare @lastDateOfYearStr   as varchar(1000)
declare @weekNumMinYear      as int
declare @weekNumMaxYear      as int
declare @weekNum             as int
declare @weekNumMinMonth     as int
declare @weekNumMaxMonth     as int
declare @isFirstWeekOfMonth  as bit
declare @isFirstWeekOfYear   as bit
declare @isLastWeekOfMonth   as bit
declare @isLastWeekOfYear    as bit


/*-------------------------------    
 * Set defaults if needed
 *------------------------------*/    

if (@refDate is null) set @refDate = getdate()

/*-------------------------------    
 * Init
 *------------------------------*/    

set @isFirstWeekOfYear  = 0
set @isFirstWeekOfMonth = 0
set @isLastWeekOfMonth  = 0
set @isLastWeekOfYear   = 0

/*-------------------------------    
 * Calculate dates
 *------------------------------*/    

set @yearVal             = DATEPART(year, @refDate)
set @yearStr             = convert(varchar(4),@yearVal)
set @firstDateOfYearStr  = '1/1/' + @yearStr + ' 00:00:00'
set @firstDateOfYearVal  = convert(datetime,@firstDateOfYearStr)
set @lastDateOfYearStr   = '12/31/' + @yearStr + ' 23:59:59'
set @lastDateOfYearVal   = convert(datetime,@lastDateOfYearStr)
set @firstDateOfMonthVal = dbo.DATE_MONTH_START_END (@refDate,0)
set @lastDateOfMonthVal  = dbo.DATE_MONTH_START_END (@refDate,1)

/*-------------------------------    
 * Calculate week numbers
 *------------------------------*/    

set @weekNumMinYear  = 1
set @weekNumMinMonth = DATEPART(week, @firstDateOfMonthVal)
set @weekNum         = DATEPART(week, @refDate)
set @weekNumMaxMonth = DATEPART(week, @lastDateOfMonthVal)
set @weekNumMaxYear  = DATEPART(week, @lastDateOfYearVal)

/*-------------------------------    
 * Calculate flags
 *------------------------------*/    

if (@weekNum = @weekNumMinYear)  set @isFirstWeekOfYear  = 1
if (@weekNum = @weekNumMinMonth) set @isFirstWeekOfMonth = 1
if (@weekNum = @weekNumMaxMonth) set @isLastWeekOfMonth  = 1
if (@weekNum = @weekNumMaxYear)  set @isLastWeekOfYear   = 1

/*-------------------------------    
 * Create row
 *------------------------------*/ 

insert into
  @recs 
values( 
  @refDate,
  @firstDateOfYearVal,
  @firstDateOfMonthVal,
  @lastDateOfMonthVal,  
  @lastDateOfYearVal,
  @weekNumMinYear,
  @weekNumMinMonth,
  @weekNum,
  @weekNumMaxMonth,
  @weekNumMaxYear,
  @isFirstWeekOfYear,
  @isFirstWeekOfMonth,
  @isLastWeekOfMonth,
  @isLastWeekOfYear)


/*-------------------------------    
 * Return row
 *------------------------------*/ 
 
return    

end    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON [dbo].[DATE_WEEK_NUMBERS] TO [webuser]
GO
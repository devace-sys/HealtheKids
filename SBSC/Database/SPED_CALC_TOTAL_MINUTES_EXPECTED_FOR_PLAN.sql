USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_PLAN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_PLAN
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_PLAN] (
    @startDate             datetime
  , @endDate               datetime   
  , @spEdFreqCode          bigint
  , @minsPerFreq           int
)   

returns int
as
begin

/*============================================================
 * Init
 *===========================================================*/  

declare @totMins      as int = 0
declare @numOfPeriods as int = 0

/*============================================================
 * Determine number of periods based on frequency
 *===========================================================*/  

/*================ Daily ================*/

if (@spEdFreqCode = 10)
begin
  
  /* Number of periods is total number of working days between start and end */
  
  select 
    @numOfPeriods = count(n) 
  from dbo.GET_START_END_DATES_BY_WORK_DAY(@startDate,@endDate) as t1

end

/*================ Weekly ================*/

else if (@spEdFreqCode = 20)
begin
  
  /* Number of periods is total number of working weeks between start and end */  
  
  select 
    @numOfPeriods = count(t1.n) 
  from dbo.GET_START_END_DATES_BY_WORK_WEEK ( @startDate, @endDate, 1) as t1 

end

/*================ Monthly ================*/

else if (@spEdFreqCode = 30)
begin

  /* Number of periods is total number of working months between start and end */  

  select 
    @numOfPeriods = count(t1.n) 
  from dbo.GET_START_END_DATES_BY_WORK_MONTH ( @startDate, @endDate) as t1 

end

/*================ Yearly ================*/

/* Expected minutes has to be delivered between single start and end date range */

else if (@spEdFreqCode = 40)
begin
  
  /* The expected minutes have to be delivered between a single start and end date range
   * despite the name of the freqency, so the number of periods has to be 1.*/

  set @numOfPeriods = 1
end

/*================ Other ================*/

else
begin
  
  /* The expected minutes have to be delivered between a single start and end date range
   * so the number of periods has to be 1.*/

 set @numOfPeriods = 1
end

/*============================================================
 * Calculate total number of minutes expected
 *===========================================================*/  

set @totMins = (@numOfPeriods * @minsPerFreq)

/*============================================================
 * Done
 *===========================================================*/  

return @totMins

end 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_PLAN] TO [webuser]
GO
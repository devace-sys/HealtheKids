/* TODO: This needs to be refactored out and replaced with the
 * SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK_AS_ROW 
 * It has already been refactored out of the sped delivery compliance
 * routines but is still in use for the non_sped_services routines.
 * The non_sped services routines are not very widely used as of this comment.
 */

USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK] (
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

declare @totMins          as int = 0
declare @numOfPeriods     as int = 0
declare @numOfWorkingDays as int = 0
declare @multiDayBreak    as bit = 0

/*============================================================
 * Break calculations are only performed for daily, weekly
 * and monthly.
 *===========================================================*/  

if (@spEdFreqCode not in (10,20,30)) return 0

/*============================================================
 * Get number of working days between start and end date
 *===========================================================*/  

select 
  @numOfWorkingDays = count(n) 
from dbo.GET_START_END_DATES_BY_WORK_DAY(@startDate,@endDate) as t1

if (@numOfWorkingDays <= 0 ) return 0

/*============================================================
 * Determine if this is a single or multi day break
 *===========================================================*/  

if (@numOfWorkingDays > 1) 
  set @multiDayBreak = 1 
else 
  set @multiDayBreak = 0

/*============================================================
 * Determine number of periods based on frequency
 *===========================================================*/  

/*================ Daily ================*/

if (@spEdFreqCode = 10)
begin
  
  /* Number of periods is total number of working days between start and end.  We use our previous calculation */
  
  select @numOfPeriods = @numOfWorkingDays 

end

/*================ Weekly ================*/

else if (@spEdFreqCode = 20)
begin
  
  if (@multiDayBreak = 1)
  begin
    
	/* Number of periods is total number of working weeks between start and end that 
	   have at least 2 or more working days */  
    
	select 
      @numOfPeriods = count(t1.n) 
    from dbo.GET_START_END_DATES_BY_WORK_WEEK ( @startDate, @endDate, 0) as t1 
    where (t1.numDays > 1) 
   
  end
  else
  begin
     
	/* Single day break for a weekly period is not counted. */      
	
    set @numOfPeriods = 0
  
  end
end

/*================ Monthly ================*/

else if (@spEdFreqCode = 30)
begin
  
  if (@multiDayBreak = 1)
  begin
  
    /* Number of periods is total number of FULL working months between start and end */  

    select 
      @numOfPeriods = count(t1.n) 
    from dbo.GET_START_END_DATES_BY_WORK_MONTH ( @startDate, @endDate) as t1 
    where (t1.numDays between 19 and 31) /* Low end of range from avg # of working days for a month https://www.speeli.com/what-is-the-average-amount-of-workdays-in-a-month/ */
 
  end
  else
  begin

    /* Single day break for a monthly period is not counted. */      
	
	set @numOfPeriods = 0
 
  end

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
 
GRANT EXECUTE ON  [dbo].[SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK] TO [webuser]
GO
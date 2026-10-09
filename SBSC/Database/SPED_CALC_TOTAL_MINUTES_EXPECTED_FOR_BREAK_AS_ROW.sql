USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK_AS_ROW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK_AS_ROW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK_AS_ROW] (
    @startDate             datetime
  , @endDate               datetime   
  , @spEdFreqCode          bigint
  , @minsPerFreq           int
)   

returns table
as
return
(
with
cte_p0
as
(
  /*============================================================
   * We start by assuming 0.  We need to return 1 row in all 
   * cases so this provides that anchor.
   *===========================================================*/  

  select top 1 totMins = 0
)
,
cte_p1
as
(
  select 
    /* Passing init value through */
	
	p0.totMins 
    
	/* If we get a null then the calculations for multi day break could not be performed so we assume a false. */
	
	, multiDayBreak = isnull(p1_c.multiDayBreak,0)
    
	/* If we get a null then the calculations number of working days could not be performed due to invalid data 
	 * and we provide a sentinal value to indicate this so we can handle it futher down. */

    , numOfWorkingDays = isnull(p1_c.numOfWorkingDays,-1) 

  from cte_p0 as p0

  outer apply (
    select 

        p1_b.numOfWorkingDays
      
	  /*============================================================
       * Determine if this is a single or multi day break
       *===========================================================*/  

	  , multiDayBreak = iif ((p1_b.numOfWorkingDays > 1),1,0) 
	from
    (
      /*============================================================
       * Get number of working days between start and end date
       *===========================================================*/  
	  
	  select 
        numOfWorkingDays = count(p1_a.n) 
      from dbo.GET_START_END_DATES_BY_WORK_DAY(@startDate,@endDate) as p1_a
    ) as p1_b
    where 
      (p1_b.numOfWorkingDays > 0) /* Only valid for 1 or more days.  Guards against start and end date being transposed. */
  ) as p1_c
)
,
cte_p2
as
(
select 
 
   /* Still our initial value */	
	p1.totMins 
	
  /* Result of previous calculation */
  , p1.numOfWorkingDays
  
  /* Result of previous calculation */
  , p1.multiDayBreak
  
  /*============================================================
   * Determine number of periods based on frequency
   *===========================================================*/  

  , numOfPeriods = 
   
    /* Earlier computations were invalid or 0 so fall through with a 0 */ 

    iif ((p1.numOfWorkingDays <= 0)
	
	/* Fall through if no working days */

	, (0) 
	
	/* Otherwise we have a valid # of working days so proceed. */
	
	, ( case 
	  
	  /*================ Daily ================*/

	  when (@spEdFreqCode = 10) then 
	  /* Number of periods is total number of working days between start and end.  We use our previous calculation */
	  p1.numOfWorkingDays   
      
	  /*================ Weekly ================*/

	  when (@spEdFreqCode = 20) then
        iif(  (p1.multiDayBreak = 1)
	        /* Mutiple days.  Number of periods is total number of working weeks 
			  between start and end that have at least 2 or more working days */  

		  , ( select count(ww.n) from dbo.GET_START_END_DATES_BY_WORK_WEEK ( @startDate, @endDate, 0) as ww where (ww.numDays > 1) ) 
            /* Single day break for a weekly period is not counted. */
          , ( 0	)     
	    )
      
	  /*================ Monthly ================*/
	 
	  when (@spEdFreqCode = 30) then
	    iif( (p1.multiDayBreak = 1)
	      
		   /* Multiple days.  Number of periods is total number of FULL working months between start and end 
		    * Low end of range from avg # of working days for a month https://www.speeli.com/what-is-the-average-amount-of-workdays-in-a-month/ 
			*/
		  
		  , ( select count(wm.n) from dbo.GET_START_END_DATES_BY_WORK_MONTH ( @startDate, @endDate) as wm where (wm.numDays between 19 and 31) )
		  
		  /* Single day break for a monthly period is not counted. */  
		  
		  , (0)		     
	    )
      
	  /*============================================================
       * Break calculations are only performed for daily, weekly
       * and monthly.  Other periods need to resolve to 0 minutes.
       *===========================================================*/  

	  else 0 
	  end
	) /* case */
  ) /* iif*/
from cte_p1 as p1
--where (p1.numOfWorkingDays > 0)
)

/*============================================================
 * Calculate total number of minutes expected and return
 *===========================================================*/  

select top 1 
    totMins = (p2.numOfPeriods * @minsPerFreq)
  /*, p2.multiDayBreak
  , p2.numOfPeriods
  , p2.numOfWorkingDays
  , startDatePassed   = @startDate
  , endDatePassed     = @endDate
  , freqCodePassed    = @spEdFreqCode
  , minsPerFreqPassed = @minsPerFreq*/
from cte_p2 as p2 
) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK_AS_ROW] TO [webuser]
GO
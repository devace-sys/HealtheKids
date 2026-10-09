USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_OVERLAP_TIME_AB_CD') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_OVERLAP_TIME_AB_CD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_OVERLAP_TIME_AB_CD] (
    @timeA  time(0)
  , @timeB  time(0)
  , @timeC  time(0)
  , @timeD  time(0)
)
returns table 
WITH SCHEMABINDING

 /***************************************************************************    
  * CALC_OVERLAP_TIME_AB_CD */    
 /**    
  * Return where @timeA, @timeB overlaps @timeC, @timeD and the number of 
  * minutes of overlap.
  *
  * @return table 
  ***************************************************************************/   

as return
(

with

/*###########################################################################
  # Calculate differences between @timeA, @timeB, @timeC, @timeD
  ###########################################################################*/
  
cte_pass_1
as
(
  select @timeA as startTime, @timeB as endTime, DATEDIFF(minute, @timeA, @timeB) as numMins  /* B - A */
  union all
  select @timeC as startTime, @timeB as endTime, DATEDIFF(minute, @timeC, @timeB) as numMins  /* B - C */
  union all
  select @timeC as startTime, @timeD as endTime, DATEDIFF(minute, @timeC, @timeD) as numMins  /* D - C */
  union all
  select @timeA as startTime, @timeD as endTime, DATEDIFF(minute, @timeA, @timeD) as numMins  /* D - A */
)
,

/*###########################################################################
  # Select difference rows generated from p1 if there is an overlap
  ###########################################################################*/

cte_pass_2
as
(
  select startTime, endTime, numMins from cte_pass_1 where ((@timeA <= @timeD) and (@timeB >= @timeC))
)
,

/*###########################################################################
  # Select the difference row that has the lowest number of minutes
  # This is where the overlap is
  ###########################################################################*/

cte_pass_3
as
(
  select top 1 startTime, endTime, numMins from cte_pass_2 order by numMins asc
)

select top 1 startTime,endTime,numMins from cte_pass_3

)
go

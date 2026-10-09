USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_TIME_SLOTS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_TIME_SLOTS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_TIME_SLOTS] (
    @startTime      time(0)
  , @endTime        time(0)
  , @minuteInterval int
  , @refID1         bigint
  , @refID2         bigint
)

returns @recs table (
    timeSlotNum    int    identity(1,1)
  , refID1         bigint 
  , refID2         bigint
  , startTime      time(0)
  , endTime        time(0) ) 
  
as
begin

declare @baseDate       as date
declare @startDate      as date
declare @endDate        as date
declare @startDateTime  as datetime
declare @endDateTime    as datetime

/*============================================================
 * Exit if input values are clearly garbage
 *============================================================*/  

if (@minuteInterval is null) return
if (@startTime      is null) return
if (@endTime        is null) return
if (@startTime > @endTime)   return
if (@minuteInterval <= 0)    return
if (@minuteInterval > 60)    return

/*============================================================
 * Strip seconds off start and end times
 *============================================================*/  

set @startTime = convert(time(0),convert(varchar(5), @startTime, 108))
set @endTime   = convert(time(0),convert(varchar(5), @endTime,   108))

/*============================================================
 * Create date/time versions of start and end time and add
 * todays date as the date component.  We need the date 
 * component to detect if we overflow into the next day.
 *============================================================*/  

set @baseDate       = convert(date,getdate())
set @startDate      = @baseDate
set @endDate        = @baseDate

set @startDateTime = convert(datetime,convert(varchar,@startDate) + ' ' + convert(varchar, @startTime))
set @endDateTime   = convert(datetime,convert(varchar,@endDate)   + ' ' + convert(varchar, @endTime))

/*============================================================
 * Generate time slots
 *============================================================*/  

;
with
cte_time_sequence
as
(
  /* First row */

  select     
      @startDateTime                                   as startTime
    , dateadd(minute, @minuteInterval, @startDateTime) as endTime

  union all  

  select      
      endTime                                      as startTime
    , dateadd(minute, @minuteInterval, endTime)    as endTime
  from cte_time_sequence
  where (endTime < @endDateTime) 
)

insert into @recs
select top 1441
    @refID1                    as refID1
  , @refID2                    as refID2  
  , convert(time(0),startTime) as startTime
  , convert(time(0),endTime)   as endTime
from cte_time_sequence    
option (MAXRECURSION 1441);

return
end
go

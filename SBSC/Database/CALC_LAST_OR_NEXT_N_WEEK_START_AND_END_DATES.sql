USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_LAST_OR_NEXT_N_WEEK_START_AND_END_DATES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_LAST_OR_NEXT_N_WEEK_START_AND_END_DATES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_LAST_OR_NEXT_N_WEEK_START_AND_END_DATES] ( 
  @refDate   datetime 
, @numWeeks  int
, @direction char(1) 
)

returns @dates table (
    [IDX]                 int
  , [RELATIVE_POSITION]   int
  , [START_DATE]          date
  , [END_DATE]            date
  , [WEEK_NUM_START_DATE] int
  , [WEEK_NUM_END_DATE]   int
) 
  
as
begin

if (@refDate   is null) set @refDate   = getdate()
if (@numWeeks  is null) set @numWeeks  = 52
if (@direction is null) set @direction = 'L'

if (@numWeeks < 0)               return
if (@direction not in ('L','N')) return

declare @offSet as int = 1
declare @idx    as int = 1

while (@idx <= @numWeeks)
begin
  insert into @dates 
  select top 1
      q1.*
    , [WEEK_NUM_START_DATE] = DATEPART(week,q1.START_DATE)
    , [WEEK_NUM_END_DATE]   = DATEPART(week,q1.END_DATE)
  from
  (
    select top 1  
        [IDX]               = @idx
	  , [RELATIVE_POSITION] = (@offSet - 1)
      , [START_DATE]        = DATEADD(wk, (@offSet-1), DATEADD(DAY, 1-DATEPART(WEEKDAY, @refDate), DATEDIFF(dd, 0, @refDate)))
      , [END_DATE]          = DATEADD(wk, (@offset),   DATEADD(DAY, 0-DATEPART(WEEKDAY, @refDate), DATEDIFF(dd, 0, @refDate))) 
  ) as q1
    
  if (@direction = 'L')
    set @offset = (@offset -1)
  else 
   set @offset = (@offset + 1)

  set @idx    = (@idx + 1)
end

return
end
go

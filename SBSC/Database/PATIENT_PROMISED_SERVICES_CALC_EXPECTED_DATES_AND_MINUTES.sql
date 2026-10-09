USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_CALC_EXPECTED_DATES_AND_MINUTES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_CALC_EXPECTED_DATES_AND_MINUTES
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_CALC_EXPECTED_DATES_AND_MINUTES] (
    @startDate             datetime
  , @endDate               datetime   
  , @spEdFreqCode          bigint
  , @minsPerFreq           int
)   

returns @recs table  (    
    n                           int
  , startDate                   datetime
  , endDate                     datetime
  , expectedMinutes             int
  --, expectedMinutesRunningTotal int
  , possibleDataEntryError      bit
  unique clustered (n)
)     
as
begin

declare @periods as PatientPromisedServicesDatePeriods

declare @possibleDataEntryError as bit = 0

-- Daily

if (@spEdFreqCode = 10)
begin
  if (@minsPerFreq >= 480) set @possibleDataEntryError = 1
  insert into @periods (n, startDate, endDate, expectedMinutes, possibleDataEntryError)
  select t1.n, t1.startDate, t1.endDate, expectedMinutes = @minsPerFreq, @possibleDataEntryError
  from dbo.GET_START_END_DATES_BY_WORK_DAY (@startDate, @endDate) as t1  
  OPTION(recompile)
end

-- Weekly

else if (@spEdFreqCode = 20)
begin
  if (@minsPerFreq >= 2400) set @possibleDataEntryError = 1
  insert into @periods (n, startDate, endDate, expectedMinutes,possibleDataEntryError)
  select t1.n, t1.startDate, t1.endDate, expectedMinutes = @minsPerFreq, @possibleDataEntryError
  from dbo.GET_START_END_DATES_BY_WORK_WEEK (@startDate, @endDate,1) as t1 
  OPTION(recompile)
end

-- Monthly

else if (@spEdFreqCode = 30)
begin
  if (@minsPerFreq >= 9600) set @possibleDataEntryError = 1
  insert into @periods (n, startDate, endDate, expectedMinutes, possibleDataEntryError)
  select t1.n, t1.startDate, t1.endDate, expectedMinutes = @minsPerFreq, @possibleDataEntryError
  from dbo.GET_START_END_DATES_BY_WORK_MONTH ( @startDate, @endDate) as t1 
  OPTION(recompile)
end

-- Yearly (expected minutes has to be delivered between single start and end date range)

else if (@spEdFreqCode = 40)
begin
  insert into @periods (n, startDate, endDate, expectedMinutes, possibleDataEntryError)
  select n=1, startDate=@startDate, endDate=@endDate, expectedMinutes=@minsPerFreq, @possibleDataEntryError 
end

-- Other (expected minutes has to be delivered between single start and end date range)

else
begin
  insert into @periods (n, startDate, endDate, expectedMinutes, possibleDataEntryError)
  select n=1, startDate=@startDate, endDate=@endDate, expectedMinutes=@minsPerFreq, @possibleDataEntryError 
end

insert into @recs
select 
    t1.n
  , t1.startDate
  , t1.endDate
  , t1.expectedMinutes 
--  , expectedMinutesRunningTotal = sum(t1.expectedMinutes) over(order by t1.n rows unbounded preceding)
  , t1.possibleDataEntryError
from @periods as t1
OPTION(recompile)

return 

end 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_CALC_EXPECTED_DATES_AND_MINUTES] TO [webuser]
GO
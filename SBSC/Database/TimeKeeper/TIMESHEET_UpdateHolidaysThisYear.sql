USE [TimeKeeper]
GO


DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_UpdateHolidaysThisYear]
GO

CREATE PROCEDURE [dbo].[TIMESHEET_UpdateHolidaysThisYear]
AS  
  
BEGIN    

declare @today date;

SELECT @today=GETDATE()

if (
  DATEPART(
  month,
  @today
  ) != 1
  OR
  DATEPART(
  day,
  @today
  ) != 1
)

    RETURN

declare @Sep1DayOfWeek int, @Nov1DayOfWeek int, @currentYear int

select @currentYear=DATEPART(
  year,
  @today
  )

SELECT @Sep1DayOfWeek=DATEPART(
  weekday,
  CAST ( @currentYear AS varchar) +
  '-09-01'
  )  --4

declare @FirstMondaySep date

SELECT @FirstMondaySep = 
CASE
  WHEN @Sep1DayOfWeek > 2 THEN
   DATEADD(
     day,
     9 - @Sep1DayOfWeek,
     CAST ( @currentYear AS varchar) +
     '-09-01'
     )
  ELSE
   DATEADD(
     day,
     2 - @Sep1DayOfWeek,
     CAST ( @currentYear AS varchar) +
     '-09-01'
     )
  END

  -- NOTE; these two formulas are both correct, but it kinda feels wrong that they are "6" apart, instead of 7.

SELECT @Nov1DayOfWeek=DATEPART(
  weekday,
  CAST ( @currentYear AS varchar) +
  '-11-01'
  )  --4

declare @FirstThursNov date

SELECT @FirstThursNov = 
CASE
  WHEN @Nov1DayOfWeek > 5 THEN
   DATEADD(
     day,
     12 - @Nov1DayOfWeek,
     CAST ( @currentYear AS varchar) +
     '-11-01'
     )
  ELSE
   DATEADD(
     day,
     5 - @Nov1DayOfWeek,
     CAST ( @currentYear AS varchar) +
     '-11-01'
     )
  END


  ;with holid_j_incremented as (
    select *, DATEADD(year, 1, LegalHolidayRecurringDate) "date_incremented" from
    [dbo].[TimeKeeperHolidays] holid_j
    WHERE id != 3 /* labor day */ AND id != 4 /* thanksgiving */ 
  ),
  holid_j_incremented_dayofweek as (
    select *, DATEPART(weekday, "date_incremented") "holiday_weekday"
    FROM holid_j_incremented
  ),
  holid_j_incremented_observed as (
    SELECT
      *,
      "holiday_observed" =
        CASE WHEN "holiday_weekday" = 1
             THEN DATEADD(day, 1, "date_incremented")
             WHEN "holiday_weekday" = 7
             THEN DATEADD(day, -1, "date_incremented")
             ELSE "date_incremented"
        END
    FROM holid_j_incremented_dayofweek
  )
  
UPDATE holid_i
SET
  DateOfHolidayObserved = "holiday_observed",
  LegalHolidayRecurringDate = "date_incremented"
FROM
[dbo].[TimeKeeperHolidays] holid_i
JOIN
  holid_j_incremented_observed s1
ON
holid_i.id = s1.ID
AND holid_i.id != 3  /* labor day */ AND holid_i.id != 4 /* thanksgiving */ 


UPDATE [dbo].[TimeKeeperHolidays]
SET DateOfHolidayObserved = @FirstMondaySep
WHERE id = 3 /* labor day */

UPDATE [dbo].[TimeKeeperHolidays]
SET DateOfHolidayObserved = DATEADD( week,2,@FirstThursNov )
WHERE id = 4 /* thanksgiving */  

END
GO

GRANT EXECUTE ON [dbo].[TIMESHEET_UpdateHolidaysThisYear] TO [webuser]
GO



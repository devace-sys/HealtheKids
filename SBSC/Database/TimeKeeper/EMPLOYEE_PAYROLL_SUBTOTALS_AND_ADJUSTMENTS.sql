USE [TimeKeeper]
GO


DROP FUNCTION if exists [dbo].[EMPLOYEE_PAYROLL_SUBTOTALS_AND_ADJUSTMENTS]
GO


CREATE FUNCTION [dbo].[EMPLOYEE_PAYROLL_SUBTOTALS_AND_ADJUSTMENTS](
@startDate datetime, /* date */
@endDate   datetime  /* date */
)
returns @empDetail table (Period_Start       date,
                          Period_End         date,				                
						  Last_Name          varchar(100),
						  First_Name         varchar(100),
						  EmployeeId        bigint,

              --IsDelinquentDTKUser bit,	
              --Verified_On        varchar(150),
              --Verification_Counts    int,
 

                          Company            varchar(40),
						  Emp_Type           varchar(30),
						  Job_Title          varchar(50),					
						  Hours_Reported     decimal(10,2),
              Work_Hours_Reported     decimal(10,2),
						  UnPaid_TimeOff     decimal(10,2),
						  Paid_break         decimal(10,2),			                    	                       
						  Make_Up_Time       decimal(10,2),		
						  Regular_Hours      decimal(10,2),
						  Missing_Time       decimal(10,2),
						  PayRegular_Hours   decimal(10,2),
						  PaySick_Hours      decimal(10,2),
						  PayVacation        decimal(10,2),
						  PayHoliday_Hours   decimal(10,2),
						  PayOver_Time       decimal(10,2),
						  PayDouble_Time     decimal(10,2),				                    			                              
						  Total_Hours_To_Pay decimal(10,2),
 						  Unpaid_Work_Hours  decimal(10,2)



                                                  ,[col3(_col_label)] varchar(18)
                                                  ,col3 int
                                                  ,[col2(_col_label)] varchar(18)
                                                  ,col2 int
                                                  ,[col1(_col_label)] varchar(18)
                                                  ,col1 int

              ,IsCompanySubTotal  bit,
              Dollar_Adjustments decimal(10,2),
              Dollar_Adjustments_Notes varchar(500)          
              )
as			              						 	
begin
INSERT INTO @empDetail
SELECT *, 

/*
            MAX( [col3(_col_label)] )
                                                  , MAX( col3 )
                                                  , MAX( [col2(_col_label)] )
                                                  , MAX( col2 )
                                                  ,MAX( [col1(_col_label)] )
                                                  , MAX(col1)
  */

0, 0, ''

 FROM [dbo].[EMPLOYEE_PAYROLL_PORTED](
@startDate,
@endDate
)

INSERT INTO @empDetail
SELECT
              MAX(Period_Start), -- expect 1
              MAX(Period_End), -- expect 1				                
						  null,--Last_Name          varchar(100),
						  null,--First_Name         varchar(100),
						  null,--Employee_ID        bigint,

						  --null,
			 			  --null,
                                                  --null,


              Company + ' - TOTAL',
						  null, --Emp_Type           varchar(30),
						  null, --Job_Title          varchar(50),							
						  SUM(Hours_Reported),
              SUM(Work_Hours_Reported),
						  SUM(UnPaid_TimeOff),
						  SUM(Paid_break),
						  SUM(Make_Up_Time),
						  SUM(Regular_Hours),
						  SUM(Missing_Time),
						  SUM(PayRegular_Hours),
						  SUM(PaySick_Hours),
						  SUM(PayVacation),
						  SUM(PayHoliday_Hours),
						  SUM(PayOver_Time),
						  SUM(PayDouble_Time),
						  SUM(Total_Hours_To_Pay),
 						  SUM(Unpaid_Work_Hours),


           MAX( [col3(_col_label)] )
                                                  , MAX( col3 )
                                                  , MAX( [col2(_col_label)] )
                                                  , MAX( col2 )
                                                  ,MAX( [col1(_col_label)] )
                                                  , MAX( col1 ) 

              ,1,
              0,
              ''

FROM [dbo].[EMPLOYEE_PAYROLL_PORTED](
@startDate,
@endDate
)
GROUP BY Company

/* calendar logic goes here */


declare @six_plus_three_comm decimal(10,2)

SELECT @six_plus_three_comm = ISNULL( SUM(SpEdCare_Share) * 0.03 , 0 )
FROM [spedmon].[dbo].InvoicesLastMonth() WHERE NEW_CLIENT_MARKER = '0'

SELECT @six_plus_three_comm += ISNULL( SUM(SpEdCare_Share) * 0.06 , 0)
FROM [spedmon].[dbo].InvoicesLastMonth() WHERE NEW_CLIENT_MARKER != '0'

/* TODO: i don't remember the syntax for a pivot, so I ran this twice */

--SELECT CAST( @startDate AS VARCHAR) + ' - ' + CAST (@endDate as VARCHAR) "Pay Period"

Declare @thisPaycheckDate date
SET @thisPaycheckDate=DATEADD(day,6,@endDate)

--SELECT @thisPaycheckDate [PaycheckDate this cycle]

DECLARE @FirstDayOfPeriodStartMonth DATE
Set @FirstDayOfPeriodStartMonth = DATEADD(day,1,DATEADD(ss, -1, DATEADD(month, DATEDIFF(month, 0, @startDate), 0)))

DECLARE @FirstDayOfPriorMonth DATE
Set @FirstDayOfPriorMonth = DATEADD(month,-1,@FirstDayOfPeriodStartMonth)

--DECLARE @FirstDayOfPeriodEndMonth DATE
--Set @FirstDayOfPeriodStartMonth = DATEADD(day,1,DATEADD(ss, -1, DATEADD(month, DATEDIFF(month, 0, @endDate), 0)))

declare @sunday date = DATEADD(
  day, (8 - (DATEPART(WEEKDAY, @FirstDayOfPriorMonth) )) % 7, @FirstDayOfPriorMonth
) --first_sunday_this_month

declare @friday date

declare @period_sundays_this_PeriodStartMonth table(idx int identity(1,1), "day" date)

--declare @period_sundays_this_PeriodEndMonth table(idx int identity(1,1), "day" date)

declare @paycheck_dates_this_PeriodEndMonth table(idx int identity(1,1), "day" date)

--SELECT @FirstDayOfPeriodStartMonth as [first day of PeriodStartMonth]
--SELECT @FirstDayOfPriorMonth as [first day of PriorMonth]
--SELECT @sunday as [first sunday of PriorMonth]

while (1=1)
BEGIN
  if ((DATEPART(month, @sunday) > DATEPART(month, @endDate)) and (DATEPART(year, @sunday) = DATEPART(year, @endDate))) break
  if (DATEPART(year, @sunday) > DATEPART(year, @endDate)) break

  if ( DATEDIFF(day, '2020-10-11', @sunday) % 14 = 0 )
    begin
    INSERT INTO @period_sundays_this_PeriodStartMonth SELECT @sunday --WHERE DATEDIFF(day, '2020-10-11', @startdate) % 14 = 0
    WHERE DATEPART(month,@sunday) = DATEPART(month,@startDate)

    SELECT @friday=DATEADD(day, 19, @sunday)
    INSERT INTO @paycheck_dates_this_PeriodEndMonth SELECT @friday --DATEADD(day, 19, @sunday)
    --  WHERE (DATEPART(month, DATEADD(day, -2, @sunday)) = DATEPART(month, @sunday))
    WHERE DATEPART(month,@friday) = DATEPART(month,@endDate)
    --raiserror(@sunday, 11, 1)
    SET @sunday = DATEADD(day, 14, @sunday)
    end
  else
    begin
    SET @sunday = DATEADD(day, 7, @sunday)
    end
END

--SELECT "day" [period sundays for PeriodStartMonth] FROM @period_sundays_this_PeriodStartMonth
--SELECT "day" [paycheck dates for PeriodEndMonth] FROM @paycheck_dates_this_PeriodEndMonth

declare @secondPaycheckDateInPeriodEndMonth date, @lastPaycheckDateInPeriodEndMonth date
SELECT @secondPaycheckDateInPeriodEndMonth="day" from @paycheck_dates_this_PeriodEndMonth WHERE idx = 2
SELECT @lastPaycheckDateInPeriodEndMonth=MAX("day") from @paycheck_dates_this_PeriodEndMonth

--SELECT @secondPaycheckDateInPeriodEndMonth [secondPaycheckDateInPeriodEndMonth]
--SELECT @lastPaycheckDateInPeriodEndMonth [lastPaycheckDateInPeriodEndMonth]

UPDATE ud
  SET Dollar_Adjustments_Notes = 'Please add sales commissions',
      Dollar_Adjustments =  ISNULL(Dollar_Adjustments + @six_plus_three_comm , 0)
  FROM @empDetail ud
  WHERE ud.EmployeeId = 1
  AND
    (
    --DATEPART(day, @startDate) > 15
    --@startdate = (SELECT "day" from @pay_sundays_this_month WHERE idx = 2)
    --DATEADD(day, -2, @startdate) = (SELECT "day" from @pay_fridays_this_month WHERE idx = 2)
    @secondPaycheckDateInPeriodEndMonth = @thisPaycheckDate
  )


/*

UPDATE @empDetail
  SET Dollar_Adjustments_Notes = 'Please deduct insurance premium',
      Dollar_Adjustments =  ISNULL( Dollar_Adjustments - 95.10, 0 )

  WHERE (EmployeeId = 71 OR EmployeeId = 72)
  -- don't like the fact this is hard-coded here, but they never asked for a screen for this

  AND
    (
    --DATEPART(day, @startDate) > 15
    --@startdate = (SELECT MAX("day") from @pay_sundays_this_month)
    @lastPaycheckDateInPeriodEndMonth = @thisPaycheckDate
  )

*/

UPDATE @empDetail
  SET Dollar_Adjustments = ISNULL( p_adj.adjustment_amount, 0),
      Dollar_Adjustments_Notes  = p_adj.adjustment_notes_reason
FROM
@empDetail e_d
JOIN [dbo].[PayrollAdjustments] p_adj
ON
 p_adj.period_startdate = CAST(@startDate as date)
 AND
 p_adj.eid = e_d.EmployeeId 

return
end
GO

GRANT select on  [dbo].[EMPLOYEE_PAYROLL_SUBTOTALS_AND_ADJUSTMENTS] to webuser
GO


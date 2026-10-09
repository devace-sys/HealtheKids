USE [TimeKeeper]
GO


/****** Object:  UserDefinedFunction [dbo].[EMPLOYEE_PAYROLL_PORTED]    Script Date: 10/23/2020 11:01:03 AM ******/
DROP FUNCTION if exists [dbo].[EMPLOYEE_PAYROLL_PORTED]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[EMPLOYEE_PAYROLL_PORTED](
@startDate datetime,
@endDate   datetime--,
--@allowOverTime bit,
--@allowDoubleTime bit
)
returns @empPayroll table(
                          Period_Start       date,
                          Period_End         date,				                
						  Last_Name          varchar(100),
						  First_Name         varchar(100),
						  Employee_ID        bigint,

              --IsDelinquentDTKUser bit,
              --Verified_On        varchar(150),
              --Verification_Counts    int,

                          Company            varchar(10),
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
              )			              
/******************************************************************************    
 * EMPLOYEE_PAYROLL_PORTED*/    
/**    
 * Calculates the total hours to be paid for each employee in a given date range
 * two week period.
 *
 * @startDate          Start date of the pay period
 * @endDate            End date of the pay period   
 * @return             Table
 *
 * In Employee table if Office is 1 then company = SBSC
 *								  2 then company = MBA
 *								  0 then not an employee any more	
 * Terry's emp_id is 1 so Emp_ID 1 is not included in payroll.	
 *
 *******************************************************************************/   			              	
as			              						 	
begin
/*---------------------------------------------------------
 * Make sure the input parameters are passed 
 *--------------------------------------------------------*/ 
 if ((@startDate is null) or (@endDate is null)) 
    return
/*---------------------------------------------------------
 * Temp table to store the hours categorized in to holiday,
 * sick,paid vacation,paid break,unpaid time,makeup time
 * and regular hours.
 *--------------------------------------------------------*/
declare
      @temp table (id int identity(1,1) PRIMARY KEY,
                   emp        bigint,
                   FirstName  varchar(100),
			       LastName   varchar(100),
			       date       date,
			       task       varchar(100),
			       hours      decimal(10,2),
			       regHours   decimal(10,2),			 
			       holHours   decimal(10,2),
			       sickHours  decimal(10,2),
			       paidVaca   decimal(10,2),
			       paidBreak  decimal(10,2),
			       unPaidTimeOff decimal(10,2),
			       makeUpTime decimal(10,2))
			       
insert into @temp
select /*e.Emp_ID*/ e.id, p.firstName, p.lastName,ed.Date,ed.Task,Hours_reported,ed.Regular_Hours,ed.PayHoliday_Hours,ed.PaySick_Hours,
      ed.PayVacation,ed.Paid_break,ed.UnPaid_TimeOff,ed.Make_Up_Time
 from Employees as e
 INNER JOIN [TimeKeeper].dbo.People p
      ON p.id = e.personID
  left join EMPLOYEE_DETAIL_PORTED(null,@startDate,@endDate) as ed on ed.Employee_ID = e.id		   
 
declare @exempt table (id int identity(1,1) primary key,
                         emp_id      bigint) 
/*---------------------------------------------------------				      
 * store the list of salaried employees from Employees table 
 * in to @exempt table.
 *--------------------------------------------------------*/                                              
insert into @exempt 
     select id /* emp_id */ from dbo.Employees 
      where isExempt = 1
       
 --Temp table to store the list of full time employees.
declare @fullTime table (id int identity(1,1) primary key,
                         emp_id      bigint)                         
/*---------------------------------------------------------				      
 * store the list of full time employees from Employees table 
 * in to @fullTime table.
 *--------------------------------------------------------*/                                               
insert into @fullTime 
     select id /* emp_id */ from dbo.Employees 
      where partTime    = 0

--Temp table to store the list of Independent contractors.
declare @independent table (id int identity(1,1) primary key,
                         emp_id      bigint)                         
/*---------------------------------------------------------				      
 * store the list of independent contractors from Employees table 
 * in to @independent table.
 *--------------------------------------------------------*/                                               
insert into @independent
     select id /* emp_id */ from dbo.Employees  
      where  
                      isSalaried = 0 AND isExempt = 1 AND applyFLSARules = 0
      
--Temp table to store the list of Parttime employees.
declare @partTime table (id int identity(1,1) primary key,
                         emp_id      bigint)                         
/*---------------------------------------------------------				      
 * store the list of parttime employees from Employees table 
 * in to @partTime table.
 *--------------------------------------------------------*/                                               
insert into @partTime
     select id  
       from dbo.Employees  
      where partTime = 1                       
				      
declare @count      as bigint
declare @regHours   as decimal(10,2)
--declare @payRegHours   as decimal(10,2)
declare @hours      as decimal(10,2)
declare @emp        as bigint
declare @id         as bigint
declare @date       as datetime


/*---------------------------------------------------------				      
 * store the TimeEntries grouped by employee and date from 
 * @temp table in to @temp2 table.
 *--------------------------------------------------------*/
declare
@temp2 table(id int identity(1,1) PRIMARY KEY,
			       emp        bigint,
                   FirstName  varchar(100),
			       LastName   varchar(100),
			       date       date,
			       hours      decimal(10,2),
			       regHours   decimal(10,2),			 
			       holHours   decimal(10,2),
			       sickHours  decimal(10,2),
			       paidVaca   decimal(10,2),
			       paidBreak  decimal(10,2),
			       unPaidTimeOff decimal(10,2),
			       makeUpTime decimal(10,2))

insert into @temp2 
     select Emp,FirstName,LastName,date,sum(hours),sum(reghours),sum(holHours),sum(sickHours),sum(paidVaca),sum(paidBreak),
            sum(unPaidTimeOff),sum(makeUpTime)
       from @temp
   group by emp,FirstName,LastName,date
   order by emp,date

set @id = 1

select @count  = COUNT(*) from @temp2

declare @id_1    as bigint 
declare @count_1 as bigint 
declare @fname   as varchar(100)                 
declare @lname   as varchar(100)
  
  /*
while @id <= @count
begin
	  
	select @date  = date 
	  from @temp2
	 where ID = @id    
 * Autopopulate the time entries for holiday for full 
 * time employees. Only populate entries for the employees
 * who have not entered their time for the holiday. 
 *--------------------------------------------------------

    if (@date in (select date from dbo.holidays(DATENAME(year,@date))))		
		begin  
		  select @count_1 = COUNT(*) from @fullTime
          set @id_1 = 1               
          while @id_1 <= @count_1 
            begin              
              select @emp = emp_id from @fullTime where id = @id_1
              if @emp not in (select emp from @temp2 where date = @date)
              begin                           
		        select @fname='FirstName',@lname='LastName' from dbo.Employees where id = @emp
                insert into @temp2 values (@emp,@fname,@lname,@date,0,0,8,0,0,0,0,0)
              end  
              set @id_1 = @id_1 + 1
            end			   
		end		

   set @id = @id + 1
end	
  
  */



select @count = COUNT(*) from @temp2
set @id       = 1
declare @doubleTime as decimal(10,2)
declare @overTime   as decimal(10,2)
declare @totalHours as decimal(10,2)
--declare @company    as varchar(10)
declare @empType    as varchar(30)
DECLARE @office     as smallint
/*-----------------------------------------------------------
 * Temp table with columns overTime and double time to store
 * the hours for overTime and doubleTime for hourly employees.
 *-----------------------------------------------------------*/
declare
@temp3 table (emp         bigint,
			  firstName   varchar(100),
			  lastName    varchar(100),
			  --Company     varchar(10),
			  date        date,
			  hours       decimal(10,2),
			  regHours    decimal(10,2),
			  overTime    decimal(10,2),
			  doubleTime  decimal(10,2), 
			  holHours    decimal(10,2),
			  sickHours   decimal(10,2),
			  paidVaca    decimal(10,2),
			  paidBreak   decimal(10,2),
			  unPaidTimeOff  decimal(10,2),
			  makeUpTime  decimal(10,2))
			 
while @id <= @count
begin
   set @doubleTime = 0
   set @overTime   = 0
  
 select @emp = emp ,@regHours = regHours,
        @totalHours = regHours+holHours+sickHours+paidvaca+paidBreak
   from @temp2 
  where id = @id  
       
/*-----------------------------------------------------
 * If anybody worked more than 12 hours in a day then 
 * doubleTime = hours - 12 for only hourly employees.
 *-----------------------------------------------------*/
 if @emp not in (select emp_id from @exempt) and @emp not in (select emp_id from @independent)
 begin
  if @totalHours > 12
    begin
       set @doubleTime = @totalHours - 12
       set @reghours = @regHours - @doubleTime
       set @totalHours = 12
    end
/*--------------------------------------------------------   
 * If anybody worked more than 8 hours in a day then 
 * overTime = hours - 8 for hourly employees.
 *--------------------------------------------------------*/      
  if @totalHours > 8
    begin
      set @overTime = @totalHours - 8
      set @reghours = @regHours - @overtime
    end
  
 end
               
 insert into @temp3
        select T.emp,T.FirstName,T.LastName, T.date,T.hours,@regHours,@overTime,@doubleTime,
               T.holHours,T.sickHours,T.paidVaca,t.paidBreak,T.unPaidTimeOff,T.makeUpTime
          from @temp2 T 
         where id = @id          
 set @id = @id + 1 
 end
 
declare
      @temp4 table (
			        lastName    varchar(100),
			        firstName   varchar(100),
			        emp         bigint,
			        Emp_Type    varchar(30),
			        hours       decimal(10,2),	
			        unPaidTimeOff  decimal(10,2),
			        paidBreak   decimal(10,2),
			        makeUpTime  decimal(10,2),	
			        regHours    decimal(10,2),
			        missingTime decimal(10,2),
			        payRegHours decimal(10,2),
			        sickHours   decimal(10,2),
			        paidVaca    decimal(10,2),
			        holHours    decimal(10,2),	
			        overTime    decimal(10,2),
			        doubleTime  decimal(10,2),    	  			  
                    totalHours  decimal(10,2),
                    unpaidWorkHours decimal(10,2))              
                             
 insert into @temp4 ( lastName,firstName,emp,hours,unPaidTimeOff,paidBreak,
                      makeUpTime,regHours,missingtime,payRegHours,sickHours,
                      paidVaca,holHours,overTime,doubleTime,totalHours,unpaidWorkHours)    
     select  
		     lastName,
		     firstName,
		     emp,
             --Company,  
		     sum(hours),
		     sum(unPaidTimeOff),
		     sum(paidBreak),             
             sum(makeUpTime), 
             sum(regHours),
             0,
             sum(regHours)+ sum(paidBreak)+ sum(makeUpTime),
             sum(sickHours),
             sum(paidVaca),
             sum(holHours),
             sum(overTime),
             sum(doubleTime),                    
            (sum(regHours)  + sum(overTime) + sum(doubleTime)+ sum(holHours) +
             sum(sickHours) + sum(paidVaca) + sum(paidBreak) + sum(makeUpTime)),
             0
       from @temp3 
   group by firstName,lastName,emp --,company
   order by lastName,firstName   
 /*-----------------------------------------------------
 * If anybody worked in weekend and their total work 
 * hours are more than 40 in a week then those hours 
 * which are over 40 are overTime for hourly employees. 
 *-----------------------------------------------------*/

declare
 @temp5 table(id int identity(1,1) primary key,
              emp       bigint,
              workhours decimal(10,2))              
           
declare @weekDate as datetime
set @weekDate = @startDate
set @id = 1
while (dateadd(dd,6,@weekDate) <= @endDate)
begin
    insert into @temp5 
       select emp,(sum(regHours)+sum(holHours)+sum(sickHours)+sum(paidVaca)+sum(paidBreak)) 
         from @temp3 
        where date between @weekDate and dateadd(dd,6,@weekDate)
        and emp not in (select emp_id from @exempt)
        and emp not in (select emp_id from @independent)
       group by emp 
 select @count = count(*) from @temp5
 while @id <= @count
   begin
      select @emp = emp,@hours =workHours from @temp5 where id = @id
      if @hours > 40   
      begin   
        set @overTime = @hours - 40
        update @temp4 set overTime = overTime + @overTime,regHours = regHours - @overTime,payRegHours = payRegHours - @overTime
        where emp = @emp
      end 
      set @id = @id + 1  
 end
    set @weekDate = dateadd(dd,7,@weekDate)
    set @id       = @id - 1  
end



/*----------------------------------------------------------      
 * For any salaried employee if Pay regular hours or total hours worked  
 * greater than 80 in a pay period(2 weeks) make them 80, or 40 hours for 1 week
 *-----------------------------------------------------------*/

 /*  SALARIED AND EXEMPT ARE NOT THE SAME THING!!!!  */

 
declare @unpaidTimeOff    as decimal(10,2)


declare @firstName as varchar(20)
declare @lastName  as varchar(20)

IF (datediff(dd,@startdate,@enddate) = 6)
  BEGIN
   set @id = 1
   select @count = count(*) from @exempt
   --declare @firstName as varchar(20)
   --declare @lastName  as varchar(20)
    while @id <= @count  
   begin
      select @emp   = emp_id from @exempt where id = @id
              
     -- Calculate the missing time
      if ((@hours+@unpaidTimeOff) < 40) 
        update @temp4 set missingTime = 40-(@hours+unPaidTimeOff)--(regHours+paidvaca+sickHours+holHours+unPaidTimeOff)
         where emp = @emp  
               
      select
       @hours = payRegHours+paidvaca+sickHours+holHours--,
       --@payRegHours = payRegHours
      from @temp4 where emp = @emp 
      
      --if payRegHours greater than 80 make it 80.
      if (@hours >= 40)
        update @temp4
          set payRegHours = 40-(paidvaca+sickHours+holHours),
              unpaidWorkHours = @hours - 40,
              totalHours = totalHours - @hours + 40
              
        where emp = @emp 
      
/*---------------------------------------------------------				      
 * Insert a row for salaried employee who have not entered 
 * any time during the pay period 
 *--------------------------------------------------------*/    
       
      if (@emp not in (select emp from @temp4))
        begin
          select @firstName = 'firstname - no entry',@lastName = 'lastname' 
            from dbo.Employees 
           where id = @emp
          insert into @temp4 values(@lastName,@firstName,@emp,'SBSC',null,0,0,0,0,0,40,40,0,0,0,0,0,40)  
        end
      set @id = @id + 1
     end
END

IF (datediff(dd,@startdate,@enddate) = 13)
  BEGIN
   set @id = 1
   select @count = count(*) from @exempt
   --declare @firstName as varchar(20)
   --declare @lastName  as varchar(20)
    while @id <= @count  
   begin
      select @emp   = emp_id from @exempt where id = @id
              
     -- Calculate the missing time
      if ((@hours+@unpaidTimeOff) < 80) 
        update @temp4 set missingTime = 80-(@hours+unPaidTimeOff)--(regHours+paidvaca+sickHours+holHours+unPaidTimeOff)
         where emp = @emp  
               
      select
       @hours = payRegHours+paidvaca+sickHours+holHours--,
       --@payRegHours = payRegHours
      from @temp4 where emp = @emp 
      
      --if payRegHours greater than 80 make it 80.
      if (@hours >= 80)
        update @temp4
          set payRegHours = 80-(paidvaca+sickHours+holHours),
              unpaidWorkHours = @hours - 80,
              totalHours = totalHours - @hours + 80
              
        where emp = @emp 
      
/*---------------------------------------------------------				      
 * Insert a row for salaried employee who have not entered 
 * any time during the pay period 
 *--------------------------------------------------------*/    
       
      if (@emp not in (select emp from @temp4))
        begin
          select @firstName = 'firstname - no entry',@lastName = 'lastname' 
            from dbo.Employees 
           where id = @emp
          insert into @temp4 values(@lastName,@firstName,@emp,'SBSC',null,0,0,0,0,0,80,80,0,0,0,0,0,80)  
        end
      set @id = @id + 1
     end
END

--http://www.spectrum-research.com/V2/california_overtime_law.asp


/*---------------------------------------------------------				      
 * For any fulltime employee if total hours less than 80
 * add the difference to missingtime  
 *--------------------------------------------------------*/    
IF (datediff(dd,@startdate,@enddate) = 6)
  BEGIN
   set @id = 1
   set @hours = 0
   set @count = 0
   select @count = count(*) from @fullTime
   while @id <= @count  
   begin
      select @emp   = emp_id from @fullTime where id = @id
      select @hours = totalHours,@unpaidTimeOff = unPaidTimeOff from @temp4 
       where emp    = @emp 
      if ((@hours + @unpaidTimeOff) < 40)
         update @temp4 set missingTime = 40 - (@hours + unPaidTimeOff) where emp = @emp 
      set @id = @id + 1   
    end     
   end

IF (datediff(dd,@startdate,@enddate) = 13)
  BEGIN
   set @id = 1
   set @hours = 0
   set @count = 0
   select @count = count(*) from @fullTime
   while @id <= @count  
   begin
      select @emp   = emp_id from @fullTime where id = @id
      select @hours = totalHours,@unpaidTimeOff = unPaidTimeOff from @temp4 
       where emp    = @emp 
      if ((@hours + @unpaidTimeOff) < 80)
         update @temp4 set missingTime = 80 - (@hours + unPaidTimeOff) where emp = @emp 
      set @id = @id + 1   
    end     
   end
/*---------------------------------------------------------				      
 * Set the employee types
 *--------------------------------------------------------*/         
update @temp4 set Emp_Type = 'Hourly-Parttime'
where emp in (select id /* emp_id */ from dbo.Employees  
               where partTime = 1 --and jobTitle not like '%Independent%'
                     and isSalaried = 0
               ) 

update @temp4 set Emp_Type = 'Exempt' 
where emp in (select id /* emp_id */ from dbo.Employees 
                where --Hourly = 0 and office != 0 and Emp_ID != 1
                       isExempt = 1
                       AND applyFLSARules = 0
              )

update @temp4 set Emp_Type = 'Hourly-FullTime'
where emp in (select id from @fulltime) 
      and emp not in (select id /* emp_id */ from dbo.Employees  
               where partTime = 0
                     and isSalaried = 0
               )

update @temp4 set Emp_Type = 'Independent' --,company = company+'_Ind'
where emp in (select id /* emp_id */ from dbo.Employees  
               where  
                      isSalaried = 0 AND isExempt = 1 AND applyFLSARules = 0 -- ????
               ) 


declare @saturday1 as datetime
declare @saturday1_daysAgo as int

declare @saturday2 as datetime
declare @saturday2_daysAgo as int

declare @saturday3 as datetime
declare @saturday3_daysAgo as int


select
  @saturday3=dateadd(
    day,
    ( -1 * (
    datepart(
      WEEKDAY, @endDate
    ) % 7) ) ,
    @endDate
  )

select @saturday3_daysAgo=DATEDIFF(day, @saturday3, @endDate)

select
  @saturday2=dateadd(
    day,
    -7,
    @saturday3
  )

select @saturday2_daysAgo=DATEDIFF(day, @saturday2, @endDate)

select
  @saturday1=dateadd(
    day,
    -7,
    @saturday2
  )

select @saturday1_daysAgo=DATEDIFF(day, @saturday1, @endDate)

insert into @empPayroll
     select @startDate, @endDate, t.lastName,t.firstName,t.emp,

                      --c4de.isDelinquientDTK,  
                      --Verified_On,
                      --Verified_Counts,
  
                      O."name", /* Company, */ t.Emp_Type,'jobTitle',isnull(hours,0),isnull(hours,0) - isnull(unPaidTimeOff,0),isnull(unPaidTimeOff,0),isnull(paidBreak,0),
                      isnull(makeUpTime,0),isnull(regHours,0),isnull(missingtime,0),isnull(payRegHours,0),isnull(sickHours,0),
                      isnull(paidVaca,0),isnull(holHours,0),isnull(overTime,0),isnull(doubleTime,0),isnull(totalHours,0),isnull(unpaidWorkHours,0)

                      , convert(varchar, @saturday3 , 107), CASE WHEN v3.dateVerified IS NOT NULL THEN 1 ELSE 0 END
                      , convert(varchar, @saturday2 , 107), CASE WHEN v2.dateVerified IS NOT NULL THEN 1 ELSE 0 END
                      , convert(varchar, @saturday1 , 107), CASE WHEN v1.dateVerified IS NOT NULL THEN 1 ELSE 0 END
            
       from @temp4 t join
       Employees E on E.id = t.emp
       AND e.noPayroll = 0

       JOIN Organizations O
       ON O.id = e.organizationID

       left join (select employeeId, MAX(dateVerified) dateVerified FROM [dbo].[TIMESHEET_FindEmployeeVerificationsByDateRange](
         dateadd(day, -6, @saturday3), @saturday3
       ) GROUP BY employeeId) v3 on v3.employeeId = E.id

       left join (select employeeId, MAX(dateVerified) dateVerified FROM [dbo].[TIMESHEET_FindEmployeeVerificationsByDateRange](
         dateadd(day, -6, @saturday2), @saturday2
       ) GROUP BY employeeId) v2 on v2.employeeId = E.id

       left join (select employeeId, MAX(dateVerified) dateVerified FROM  [dbo].[TIMESHEET_FindEmployeeVerificationsByDateRange](
         dateadd(day, -6, @saturday1), @saturday1
       ) GROUP BY employeeId) v1 on v1.employeeId = E.id
                                                                                               
     order by
     o."name"  ASC, 
     lastName  asc,
     firstName asc,
     emp       asc

  return

end	
GO

GRANT SELECT ON [EMPLOYEE_PAYROLL_PORTED] TO Webuser
GO
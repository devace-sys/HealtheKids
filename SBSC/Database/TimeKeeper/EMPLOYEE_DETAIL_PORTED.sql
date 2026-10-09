/*

Considerations for improvment, these are possible gotchas ported over from the original TTFN code
These are not required for this release
=================================================================================================
 

  1. Time entries should possibly capture employee details at the time (part time/full time status, exempt status, payrate, etc)
  2. The payroll udf retrieves CURRENT details about an employee and relies on that data for its logic
  3. If an employee details change during a payroll period... you will have one or more time entry records where their previous details should be applied and are not

*/


use TimeKeeper
GO


DROP FUNCTION if exists [dbo].[EMPLOYEE_DETAIL_PORTED]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[EMPLOYEE_DETAIL_PORTED](
@emp       bigint,
@startDate datetime,
@endDate   datetime
)
returns @empDetail table (Employee_ID        bigint,
					      First_Name         varchar(100),
			              Last_Name          varchar(100),
			              Emp_Type           varchar(30),
			              Job_Title          varchar(50),
			              Date               date,
			              Task               varchar(100),
			              Client             varchar(50),
			              Hours_reported     decimal(10,2),
						  Regular_Hours      decimal(10,2),
						  PayHoliday_Hours      decimal(10,2),
			              PaySick_Hours         decimal(10,2),
			              PayVacation          decimal(10,2),
			              Paid_break         decimal(10,2),
			              UnPaid_TimeOff     decimal(10,2),			                       
			              Make_Up_Time       decimal(10,2),
			              Notes              nvarchar(max),
			              startTime          datetime,
			              endTime            datetime)              	             
/******************************************************************************    
 * EMPLOYEE_DETAIL_PORTED*/    
/**    
 * Displays the detail list of employee time entries in a given date range 
 *
 * @emp                Employee ID
 * @startDate          Start date of the pay period
 * @endDate            End date of the pay period   
 * @return             Table
 *******************************************************************************/   			              	
as			              						 	
begin
/*---------------------------------------------------------
 * Make sure the input parameters are passed 
 *--------------------------------------------------------*/ 
 if (@startDate is null) or (@endDate is null) 
    return
 
  declare @salariedFulltime table (id int identity(1,1) primary key,
                                     emp_id      bigint)   
/*---------------------------------------------------------				      
 * store the list of salaried and fulltime  employees from
 *  Employees table in to @salariedFulltime table.
 *--------------------------------------------------------*/                                              
insert into @salariedFulltime 
     select id /* emp_id */ from dbo.Employees 
      where partTime    = 0
            --and office != 0	
            --and Emp_ID != 1
            AND isSalaried = 1         
             
/*---------------------------------------------------------
 * Temp table to store the hours categorized in to holiday,
 * sick,paid vacation,paid break,unpaid time,makeup time
 * and regular hours.
 *--------------------------------------------------------*/ 
 declare
      @temp table (emp        bigint,
                   FirstName  varchar(100),
			       LastName   varchar(100),
			       Emp_Type   varchar(30),
			       Job_Title  varchar(50),
			       date       date,
			       task       varchar(max),
			       Client     varchar(50),
			       hours      decimal(10,2),
			       regHours   decimal(10,2),			 
			       holHours   decimal(10,2),
			       sickHours  decimal(10,2),
			       paidVaca   decimal(10,2),
			       paidBreak  decimal(10,2),
			       unPaidTime decimal(10,2),
			       makeUpTime decimal(10,2),
			       Notes      varchar(max),
			       startTime  datetime,
			       endTime    datetime)
			 
declare @temp2 table (id int identity(1,1) PRIMARY KEY,
					            employee    bigint,
					            FirstName   varchar(100),
			                    LastName    varchar(100),
			                    Job_Title   varchar(50),
					            date        date,
				                hours       decimal(10,2),
				                task        bigint,				               
				                task_detail varchar(max),
				                Client      varchar(50),
				                Entry_Note  varchar(max),
				                StartTime   datetime,
			                    EndTime     datetime)				      
/*---------------------------------------------------------				      
 * Store the rows from TimeEntries table with date range 
 * between the given dates in to @temp2 table.
 *--------------------------------------------------------*/				      
insert into @temp2 
     select

        TED.employeeID,

        p.firstName,

        p.LastName,

        CAST(TED.employeeID as varchar) + ' job title',  -- TODO....

        "timeOfTask",

        convert(decimal(10,2),round(numberMinutes,2)) / 60,

        TET.id,

        TET."name",

        O."name" ClientName,

        TE.note,
        TE.StartEntryDateTime,
        TE.EndEntryDateTime

     FROM 
		[TimeKeeper].[dbo].[TimeEntry_Day] TED
		INNER JOIN [TimeKeeper].[dbo].[TimeEntries] TE
			ON TE.timeEntryDayID = TED.id
		LEFT JOIN [TimeKeeper].[dbo].[TimeEntry_Tasks] TET
			ON TET.id = TE.timeEntrytaskID
		LEFT JOIN [TimeKeeper].[dbo].[Organizations] O
			ON O.id = TE.orgClientID

    INNER JOIN [TimeKeeper].dbo.Employees e
      ON e.id = TED.employeeID
    INNER JOIN [TimeKeeper].dbo.People p
      ON p.id = e.personID

    where
      /* Date */

      --(
      -- ( timeOfTask >= @startDate and CAST(timeOfTask AS date) <= @endDate )
      --OR
       ( TED.dateForTimeEntry >= @startDate and TED.dateForTimeEntry <= @endDate )
      --)

      and ( employeeID = @emp OR @emp IS NULL )

declare @count      as bigint
declare @task       as bigint
declare @holHours   as decimal(10,2)
declare @sickHours  as decimal(10,2)
declare @unPaid     as decimal(10,2)
declare @paidVaca   as decimal(10,2)
declare @paidBreak  as decimal(10,2)
declare @makeUpTime as decimal(10,2)
declare @regHours   as decimal(10,2)
declare @hours      as decimal(10,2)
declare @id         as bigint
declare @date       as datetime
declare @emp_1      as bigint


set @id = 1
select @count  = COUNT(*) from @temp2

while @id <= @count
begin
  --print 'while ' + CAST(@id as varchar)
	set @holHours   = 0
	set @sickHours  = 0
	set @regHours   = 0
	set @paidVaca   = 0
	set @paidBreak  = 0
	set @unPaid     = 0
	set @makeUpTime = 0
	  
	select @task  = Task,
	       @hours = hours,
	       @date  = date,
	       @emp_1 = employee 
	from @temp2
	where ID = @id


	--if @emp_1 in (select emp_id from @salariedFulltime)
	--  begin
	    --if (@task = 1)--and (@date in (select date from spedmon.dbo.holidays(DATENAME(year,@date)))
      if (@task = 163)
	      set @holHours   =  @hours
	    --if @task =  3
      else if (@task = 10213) 
	      set @sickHours  =  @hours
      else if (@task = 161) 
	    --if @task =  2 
	      set @paidVaca   =  @hours
           
	    else if (@task in /* (4,105,106) */ (164,165,166) -- and @emp_1 not in (select emp_id from @salaried)
       )
	       set @unPaid     =  @hours
	     
	--if (@emp_1 in (select emp_id from @salaried) and (@task = 4))
	--   set @unpaid = @hours
	 
	--if @task in  (5,103,104) 
      else if (@task = 160)
	      set @paidBreak  =  @hours     
	    else if @task = 58
	       set @makeUpTime =  @hours     
	--if ((@task > 5) and (@task not in (58,105,106,103,104)))
      else
	       set @regHours   =  @hours
  --end
	
	insert into @temp 
	     select employee,FirstName,LastName,'',Job_Title,date,task_detail,Client,hours,@regHours,@holHours,@sickHours,
	            @paidVaca,@paidBreak,@unPaid,@makeUpTime,Entry_note,isnull(StartTime,''),isnull(EndTime,'')
	       from @temp2 
	      where id = @id
    set @id = @id + 1
end	

/*---------------------------------------------------------				      
 * Set the employee types
 *--------------------------------------------------------*/  

update @temp set Emp_Type = 'Hourly-Parttime'
 where emp in (select id /* emp_id */ from dbo.Employees  
               where partTime = 1 --and jobTitle not like '%Independent%'
                     and isSalaried = 0
               )  

update @temp set Emp_Type = 'Exempt' 
 where emp in (select id /* emp_id */ from dbo.Employees 
                where --Hourly = 0 and office != 0 and Emp_ID != 1
                       isExempt = 1
                       AND applyFLSARules = 0
              ) 

update @temp set Emp_Type = 'Hourly-FullTime'
  where emp in (select id /* emp_id */ from dbo.Employees  
               where partTime = 0
                     and isSalaried = 0
               )
               
update @temp set Emp_Type = 'Independent'
 where emp in (select id /* emp_id */ from dbo.Employees  
               where  
                      isSalaried = 0 AND isExempt = 1 AND applyFLSARules = 0 -- ????
               )   


if @emp is null
  insert into @empDetail
     select * from @temp
     order by 
     lastname asc,
     firstname asc,
     date
else     
 insert into @empDetail
     select * from @temp
      where emp = @emp
      order by 
      date 
return     

end
GO


/*
SELECT * FROM [dbo].[EMPLOYEE_DETAIL_PORTED](
70,
'10/11/20',
'10/24/20'
) ORDER BY Date ASC

SELECT SUM(Hours_reported) reported, SUM(Regular_Hours) Regular, SUM FROM [dbo].[EMPLOYEE_DETAIL_PORTED](
70,
'10/11/20',
'10/24/20'
) ORDER BY Date ASC


*/

GRANT SELECT ON [EMPLOYEE_DETAIL_PORTED] TO Webuser
GO
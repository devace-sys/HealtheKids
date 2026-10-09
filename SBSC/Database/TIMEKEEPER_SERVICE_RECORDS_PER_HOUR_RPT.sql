USE spedmon
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('TIMEKEEPER_SERVICE_RECORDS_PER_HOUR_RPT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TIMEKEEPER_SERVICE_RECORDS_PER_HOUR_RPT
GO


CREATE FUNCTION [dbo].TIMEKEEPER_SERVICE_RECORDS_PER_HOUR_RPT ( 
    @userID                  bigint
  , @userGroup               int   
  , @userRank                int
  , @startDate               date
  , @endDate                 date
)

RETURNS TABLE AS RETURN (

with

cte_p1
as
(
  select 
      employeeFirstName = p.firstName
    , employeeLastName  = p.lastName
    , employeeID        = e.id
    , userID            = u.userrid
  from Timekeeper.dbo.People     as p 
  join TimeKeeper.dbo.Employees  as e  on e.personID = p.id
  join users.dbo.Users           as u  on u.UserName = p.spedMonUserName  /* This is NOT ideal*/
  join users.dbo.UsersInRoles    as ur on ur.UserID  = u.UserId
  join users.dbo.RoleData        as rd on rd.RoleId  = ur.RoleId

  where ( 
        (e.employeeStatus = 0) /* Limit to current employees */
    and (rd.id in (3,4))       /* Limit to input staff and work leaders*/
  )  
)
,

cte_p2
as
(
  select 
      p1.* 
	, timeEntryDate          = ted.dateForTimeEntry  
	, timeEntryStartDateTime = te.StartEntryDateTime /* Used to determine starting entry date/time for service records */
	, timeEntryEndDateTime   = te.EndEntryDateTime   /* Used to determine ending ending entry date/time for service records */
	, timeEntryTask          = tet.[name]           
	, timeEntryNumMins       = te.numberMinutes	
	, timeEntryWorkBatch     = isnull(te.FileNameReference,'')
	, timeEntryNote          = isnull(te.note,'')
	, timeEntryID            = te.id
  from cte_p1                         as p1
  join TimeKeeper.dbo.TimeEntry_Day   as ted on ted.employeeID    = p1.employeeID
  join TimeKeeper.dbo.TimeEntries     as te  on te.timeEntryDayID = ted.id
  join TimeKeeper.dbo.TimeEntry_Tasks as tet on tet.id            = te.timeEntrytaskID
  where (
        (ted.dateForTimeEntry between @startDate and @endDate) /* Limit to time entry dates */
    and (tet.id in (26,20222,20236))                           /* Limit to applicable tasks*/
	
  )
)
,

cte_p3
as
(
select 
    p2.* 
  , sres.*
from cte_p2 as p2
cross apply (
  select 
    svcRecsNumEntered = count(sr.id)
  from spedmon.dbo.SERVICE_RECORDS as sr  
  where (

        /* Uses [USER_ID_CREATED_IDX] index. */
		((sr.userID = p2.userID)

    and (sr.created between p2.timeEntryStartDateTime and p2.timeEntryEndDateTime)
    and (sr.id is not null))
  )
) as sres
)
,

cte_p4
as
(
  select 
      id = timeEntryID
	, [name]    = p3.employeeFirstName + ' ' + p3.employeeLastName
	, workDay   = p3.timeEntryDate
	, startTime = convert(time(0),p3.timeEntryStartDateTime)
	, endTime   = convert(time(0),p3.timeEntryEndDateTime)
	, p3.timeEntryTask
	, p3.timeEntryWorkBatch
	, p3.timeEntryNumMins
	, p3.svcRecsNumEntered
	, entriesPerMinute = round ( iif( (p3.timeEntryNumMins != 0) /* Guard against div by 0 */
	                                 , (convert(real,svcRecsNumEntered) / convert(real,p3.timeEntryNumMins))
		                             , 0)
							  ,2)    
	, p3.timeEntryNote
	, p3.employeeID
	, p3.userID
	, p3.timeEntryID
  from cte_p3 as p3
)

select top ( SPEDMON.dbo.CONST_MAX_ROWS() )
    p4.* 
  , workDayStr   = SPEDMON.dbo.RPT_DATE_FMT(p4.workDay)
  , startTimeStr = SPEDMON.dbo.RPT_TIME_FMT(p4.startTime,0)
  , endTimeStr   = SPEDMON.dbo.RPT_TIME_FMT(p4.endTime,0)
from cte_p4 as p4
order by 
    p4.[name]
  , p4.workDay
  , p4.startTime
)
GO

 
GRANT SELECT ON  [dbo].[TIMEKEEPER_SERVICE_RECORDS_PER_HOUR_RPT] TO [webuser]
GO

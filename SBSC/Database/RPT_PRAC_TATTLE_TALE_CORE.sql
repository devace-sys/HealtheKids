USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_PRAC_TATTLE_TALE_CORE]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_PRAC_TATTLE_TALE_CORE]
GO

USE [spedmon]
GO

CREATE FUNCTION [dbo].[RPT_PRAC_TATTLE_TALE_CORE] (
    @userID               bigint
  , @userGroup            int
  , @userRank             int
  , @clientID             bigint
  , @repID                bigint
  , @rptGroupID           bigint
  , @groupSvcClassNameID  bigint
  , @pracID               bigint
  , @refDate              datetime
)

returns @recs table (
    clientName             varchar(256)
  , reportingGroup         varchar(256)
  , pracName               varchar(100)
  , dispGroup              varchar(256)
  , practiceFamily         varchar(256)
  , dateAddedStr           varchar(50)
  , employmentRelationship varchar(256)
  , departmentHeadStr      varchar(50)
  , lastDateSvcsEnteredStr varchar(50)
  , svcsLastEnteredDaysAgo      int
  , numPatsOnCaseload           int
  , hasAssociatedUserAccountStr varchar(50)
  , lastLoggedOnToSpEdCareOnStr varchar(50)
  , comments               varchar(max)
  , totalNumSvcs          int
  , [c1]                  int
  , [c1(_col_label)]      varchar(50)
  , [c2]                  int
  , [c2(_col_label)]      varchar(50)
  , [c3]                  int
  , [c3(_col_label)]      varchar(50)
  , [c4]                  int
  , [c4(_col_label)]      varchar(50)
  , [c5]                  int
  , [c5(_col_label)]      varchar(50)
  , [c6]                  int
  , [c6(_col_label)]      varchar(50)
  , [c7]                  int
  , [c7(_col_label)]      varchar(50)
  , [c8]                  int
  , [c8(_col_label)]      varchar(50)
  , [c9]                  int
  , [c9(_col_label)]      varchar(50)
  , [c10]                 int
  , [c10(_col_label)]     varchar(50)
  , [c11]                 int
  , [c11(_col_label)]     varchar(50)
  , [c12]                 int
  , [c12(_col_label)]     varchar(50)
  , [c13]                 int
  , [c13(_col_label)]     varchar(50)

  , repName               varchar(256)
  , clientBreaks          varchar(max)

  , lastDateSvcsEntered    date

  , repID                  int
  , clientID               int
  , groupSvcClassNameID    int
  , pracID                 int
  , dispGroupID            int
  , reptGroupID            int

)
begin

declare @today             as datetime
declare @startDate         as datetime
declare @endDate           as datetime

declare @dates as table (
    idx                 int
  , startDate           datetime
  , endDate             datetime
  , monthYearStr        varchar(50)
  , monthYearStrNoCrLf  varchar(50)
  unique clustered (idx)
)

declare @clients as table (
    clientID      int
  , clientName    varchar(256)
  , repID         bigint
  , repName       varchar(256)  
  , clientBreaks  varchar(max)
  unique clustered (clientID)
)

declare @expectedClientWideBreaks as table (    
    clientID       int
  , startDate      datetime
  , endDate        datetime
  , numDays        int
  , idx            bigint identity(1,1)

  unique clustered (clientID,startDate,endDate,idx)
)

declare @pracs as table (
    clientID                 int
  , groupSvcClassNameID      bigint
  , practiceFamily           varchar(256)
  , pracID                   int
  , pracName                 varchar(256)
  , dateAdded                date
  , dateAddedStr             varchar(50)
  , dateAddedDaysAgo         int
  , dispGroupID              int
  , dispGroup                varchar(256)
  , employmentRelationshipID bigint
  , employmentRelationship   varchar(256)
  , departmentHead           bit
  , departmentHeadStr        varchar(50)
  , reptGroupID              int
  , reptGroup                varchar(256)
  , totalNumSvcs             int default(0)
  , lastDateSvcsEntered      date       
  , lastDateSvcsEnteredStr   varchar(50) 
  , svcsLastEnteredDaysAgo   int
  , numPatsOnCaseload        int
  , hasAssociatedUserAccount    bit
  , hasAssociatedUserAccountStr varchar(50)
  , lastLoggedOnToSpEdCareOn    datetime
  , lastLoggedOnToSpEdCareOnStr varchar(50)
  , comments                    varchar(max)
  unique clustered (clientID, pracID)
)

declare @pracsAndCounts as table (    
    pracID                        int
  , dateIdx                       int
  , numOfSvcsRecorded             int
  , monthStartsDaysAfterPracAdded int
  unique clustered (pracID, dateIdx)
)

/*============================================================
 * Init and set defaults
 *===========================================================*/  

set @today = getdate()
if (@refDate is null) set @refDate = @today

/*============================================================
 * Calculate start and end dates with respect to @refDate 
 * for our rolling 13 month window
 *===========================================================*/  

set @endDate   = convert(date,@refDate)
set @startDate = convert(date,(dbo.CALC_OLDEST_DOS_ALLOWED(@endDate)))

/*============================================================
 * Calculate start and end dates for each month in the 
 * rolling 13 month window
 *===========================================================*/  

insert into @dates (
    idx
  , startDate
  , endDate
  , monthYearStr
  , monthYearStrNoCrLf 
)
select 
    idx = cdr.n
  , cdr.startDate
  , cdr.endDate
  , monthYearStr = dbo.RPT_DATE_FMT_MONTH_YEAR(cdr.startDate,1)
  , monthYearStrNoCrLf = dbo.RPT_DATE_FMT_MONTH_YEAR(cdr.startDate,0)
from dbo.CALC_START_END_DATES_BY_MONTH (@startDate,@endDate) as cdr

/*============================================================
 * Get clients and reps
 *===========================================================*/  

insert into @clients (
    clientID
  , clientName
  , repID
  , repName
  , clientBreaks
)
select 
    clientID     = clc.CLIENT_ID
  , clientName   = clc.CLIENT_NAME 
  , repID        = clc.REP_ID
  , repName      = clc.REP_NAME
  , clientBreaks = ''
from dbo.CLIENTS_Client_Active_LEA as clc
where (
      (1=1)
  and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
  and ((@repID    is null) or (clc.REP_ID    = @repID))
)

/*============================================================
 * Get client wide breaks for time period
 *===========================================================*/  

insert into @expectedClientWideBreaks (
    clientID
  , startDate
  , endDate
  , numDays
)
select 
    clc.clientID 
  , ssa2.startDate
  , ssa2.endDate
  , numDays = datediff(day,ssa2.startDate,ssa2.endDate)
from @clients as clc
cross apply (
  select distinct 
	  ssa1.startDate
    , ssa1.endDate	
  from dbo.CLIENT_SCHOOL_SESSION_CLIENT_WIDE_CALC_DATES_NOT_IN_SESSION (clc.clientID, @startDate, @endDate) as ssa1
) as ssa2

/*============================================================
 * Generate summary text for client wide breaks
 *===========================================================*/  

update clc
  set clc.clientBreaks = isnull(cwb2.breakSchedule,'')
from @clients as clc
cross apply (
  select 
    breakSchedule = 'Services are not expected during the following district breaks ' + (char(13)+char(10)) + STRING_AGG('* ' + dbo.RPT_DATE_FMT(cwb1.startDate) + iif((cwb1.numDays > 1),' to ' + dbo.RPT_DATE_FMT(cwb1.endDate),''),(char(13)+char(10)) )
  from @expectedClientWideBreaks as cwb1 
  where (cwb1.clientID = clc.clientID)  
) as cwb2

/*============================================================
 * Get practitioners 
 *===========================================================*/  

insert into @pracs (
    clientID
  , groupSvcClassNameID
  , practiceFamily
  , pracID
  , pracName
  , dateAdded
  , dateAddedDaysAgo
  , dispGroupID
  , dispGroup
  , employmentRelationshipID
  , employmentRelationship
  , departmentHead
  , departmentHeadStr
  , reptGroupID
  , reptGroup
  , numPatsOnCaseload
  , hasAssociatedUserAccount
  , hasAssociatedUserAccountStr
  , lastLoggedOnToSpEdCareOn
  , lastLoggedOnToSpEdCareOnStr
  , comments
)
select 
    rcv2.clientID
  , rcv2.groupSvcClassNameID    
  , rcv2.practiceFamily         
  , rcv2.pracID                 
  , rcv2.pracName               
  , rcv2.dateAdded              
  , dateAddedDaysAgo = 0
  , rcv2.dispGroupID   
  , dispGroup  = rcv2.dispGroupName
  , rcv2.employeeRelationshipID
  , rcv2.employmentRelationship 
  , rcv2.departmentHead        
  , departmentHeadStr = dbo.RPT_BIT_TO_YN( rcv2.departmentHead)
  , rcv2.reptGroupID           
  , reptGroup = rcv2.reptGroupName
  , rcv2.numPatsOnCaseload 
  , rcv2.hasAssociatedUserAccount
  , hasAssociatedUserAccountStr = dbo.RPT_BIT_TO_YN(rcv2.hasAssociatedUserAccount)
  , rcv2.lastLoggedOnToSpEdCareOn
  , rcv2.lastLoggedOntoSpEdCareOnStr
  , comments = ''
from @clients as clc
cross apply (
  select 
    rvc1.* 
  from dbo.RPT_PRACTITIONERS_REVIEW_CORE (@userID,@userGroup,@userRank,clc.clientID, @pracID, null, @rptGroupID, @groupSvcClassNameID, null, null, 1) as rvc1
) as rcv2

  
/*============================================================
 * Get # of service records entered but not deleted or cifd
 * for period
 *===========================================================*/  

insert into @pracsAndCounts (
    pracID
  , dateIdx
  , numOfSvcsRecorded
)
select 
    pracs.pracID
  , svcs.dateIdx
  , svcs.numOfSvcsRecorded
from @pracs as pracs
cross apply (
  select 
      dateIdx           = cdr.idx
    , numOfSvcsRecorded = isnull(sr2.numOfSvcsRecorded,0)
  from @dates as cdr
  
  outer apply (
    select 
	  numOfSvcsRecorded = count(sr1.id)
	from dbo.SERVICE_RECORDS as sr1
    where (
      ( 
	        (sr1.clientID = pracs.clientID)
        and (sr1.pracID   = pracs.pracID)
        and (sr1.patID is not null)
        and (sr1.dos between cdr.startDate and cdr.endDate)
	  )
	  and (sr1.state not in (99,199))
	)
	group by
	    sr1.clientID
	  , sr1.pracID	  
  ) as sr2  
) as svcs

/*============================================================
 * Calc month starts days after prac added
 *===========================================================*/  

update pac
  set pac.monthStartsDaysAfterPracAdded = datediff(day,pracs.dateAdded,cdr.startDate) 
from @pracs          as pracs
join @pracsAndCounts as pac on pac.pracID = pracs.pracID
join @dates          as cdr on cdr.idx    = pac.dateIdx

/*============================================================
 * Get latest dos entered regardless of period
 *===========================================================*/  

update pracs
  set pracs.lastDateSvcsEntered = sr2.latestDos
from @pracs as pracs
cross apply (
  select 
	  latestDos = max(sr1.dos)
  from dbo.SERVICE_RECORDS as sr1
  where (
      ( 
	        (sr1.clientID = pracs.clientID)
        and (sr1.pracID   = pracs.pracID)
        and (sr1.patID is not null)
        and (sr1.dos   is not null)
	  )
	  and (sr1.state not in (99,199))
  )
  group by
	  sr1.clientID
	, sr1.pracID
) as sr2
	
/*============================================================
 * Compute total svcRecsRecorded for each prac for period
 *===========================================================*/  

update pracs
  set pracs.totalNumSvcs = pac2.totNumSvcsRecorded
from @pracs as pracs
cross apply (
  select 
    totNumSvcsRecorded = sum(pac1.numOfSvcsRecorded) 
  from @pracsAndCounts as pac1
  where pac1.pracID = pracs.pracID
) as pac2


/*============================================================
 * Update pracs.  
 * Get report friendly versions of date added, last date
 * svcs entered, etc 
 *===========================================================*/  

update @pracs 
set 
   dateAddedStr            = dbo.RPT_DATE_FMT(dateAdded)
 , dateAddedDaysAgo        = datediff(day,dateAdded,convert(date,@today))
 , lastDateSvcsEnteredStr  = iif ((lastDateSvcsEntered is null),'No Services Entered',dbo.RPT_DATE_FMT(lastDateSvcsEntered))
 , svcsLastEnteredDaysAgo  = iif ((lastDateSvcsEntered is null),-1,datediff(day,lastDateSvcsEntered,@today))

/*============================================================
 * Generate comments for practioners
 *===========================================================*/  

update pracs
set
  comments = iif( (svcsNotExpected.OnDates is not null)
                 ,'* Practitioner started during this period.  Services not expected for : ' + svcsNotExpected.OnDates + (char(13)+char(10)) 
				 , ''
				 )
from @pracs  as pracs
cross apply (
  select 
    OnDates = STRING_AGG(cdr.monthYearStrNoCrLf,',')
  from @pracsAndCounts as pac 
  join @dates          as cdr on cdr.idx    = pac.dateIdx
  where ((pac.pracID = pracs.pracID) and (pac.monthStartsDaysAfterPracAdded < 0))
) as svcsNotExpected

update @pracs
set 
  comments = comments + '* No services entered for this period.' + char(13) + char(10)
where (
      (totalNumSvcs = 0)
  and (svcsLastEnteredDaysAgo != -1)  /* Has entered svcs in past*/
)

update @pracs
set 
  comments = comments + '* Practitioner was added over a year ago and no services have been entered for at least six months.' + char(13) + char(10)

where (
      (svcsLastEnteredDaysAgo >= 180)
  and (dateAddedDaysAgo >= 365) 
)

update @pracs
set 
  comments = comments + '* Practitioner was added less than a year ago and no services have not been entered for at least six months.' + char(13) + char(10)

where (
      (svcsLastEnteredDaysAgo >= 180)
  and (dateAddedDaysAgo < 365) 
)


/*============================================================
 * Output
 *===========================================================*/  

insert into @recs (    
    clientName
  , reportingGroup
  , pracName
  , dispGroup
  , practiceFamily
  , dateAddedStr
  , employmentRelationship 
  , departmentHeadStr
  , lastDateSvcsEnteredStr
  , svcsLastEnteredDaysAgo
  , numPatsOnCaseload
  , hasAssociatedUserAccountStr
  , lastLoggedOnToSpEdCareOnStr
  , comments  
  , totalNumSvcs
  , [c1]  
  , [c1(_col_label)] 
  , [c2] 
  , [c2(_col_label)] 
  , [c3] 
  , [c3(_col_label)] 
  , [c4] 
  , [c4(_col_label)] 
  , [c5] 
  , [c5(_col_label)]  
  , [c6] 
  , [c6(_col_label)] 
  , [c7] 
  , [c7(_col_label)] 
  , [c8] 
  , [c8(_col_label)]
  , [c9] 
  , [c9(_col_label)] 
  , [c10] 
  , [c10(_col_label)] 
  , [c11] 
  , [c11(_col_label)] 
  , [c12] 
  , [c12(_col_label)] 
  , [c13]
  , [c13(_col_label)] 

  , repName
  , clientBreaks

  , lastDateSvcsEntered

  , repID      
  , clientID
  , groupSvcClassNameID
  , pracID  
  , dispGroupID 
  , reptGroupID 

)
select     
    clients.clientName
  , pracs.reptGroup
  , pracs.pracName
  , pracs.dispGroup
  , pracs.practiceFamily
  , pracs.dateAddedStr
  , pracs.employmentRelationship
  , pracs.departmentHeadStr
  , pracs.lastDateSvcsEnteredStr
  , pracs.svcsLastEnteredDaysAgo
  , pracs.numPatsOnCaseload
  , pracs.hasAssociatedUserAccountStr
  , pracs.lastLoggedOnToSpEdCareOnStr
  , pracs.comments

  , pracs.totalNumSvcs
  , cd1.*
  , cd2.*
  , cd3.*
  , cd4.*
  , cd5.*
  , cd6.*
  , cd7.*
  , cd8.*
  , cd9.*
  , cd10.*
  , cd11.*
  , cd12.*
  , cd13.*

  , clients.repName
  , clients.clientBreaks

  , pracs.lastDateSvcsEntered

  , clients.repID
  , clients.clientID
  , pracs.groupSvcClassNameID
  , pracs.pracID
  , pracs.dispGroupID
  , pracs.reptGroupID

from @clients as clients  
join @pracs   as pracs    on pracs.clientID = clients.clientID

/* Month 1 (Current month with respect to @refDate) */

cross apply (
  select 
      [c1]             = pc.numOfSvcsRecorded
    , [c1(_col_label)] = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 1))
) as cd1

/* Month 2 */

cross apply (
  select top 1
      [c2]              = pc.numOfSvcsRecorded
    , [c2(_col_label)]  = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 2))
) as cd2

/* Month 3 */

cross apply (
  select top 1
      [c3]              = pc.numOfSvcsRecorded
    , [c3(_col_label)]  = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 3))
) as cd3

/* Month 4 */

cross apply (
  select top 1 
      [c4]              = pc.numOfSvcsRecorded  
    , [c4(_col_label)] = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 4))
) as cd4

/* Month 5 */

cross apply (
  select top 1
      [c5]              = pc.numOfSvcsRecorded   
    , [c5(_col_label)]  = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 5))
) as cd5

/* Month 6 */

cross apply (
  select top 1
      [c6]              = pc.numOfSvcsRecorded    
    , [c6(_col_label)]  = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 6))
) as cd6

/* Month 7 */

cross apply (
  select top 1 
      [c7]              = pc.numOfSvcsRecorded   
    , [c7(_col_label)]  = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 7))
) as cd7

/* Month 8 */

cross apply (
  select top 1
      [c8]              = pc.numOfSvcsRecorded 
    , [c8(_col_label)]  = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 8))
) as cd8

/* Month 9 */

cross apply (
  select top 1
      [c9]              = pc.numOfSvcsRecorded
    , [c9(_col_label)]  = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 9))
) as cd9

/* Month 10 */

cross apply (
  select top 1
      [c10]              = pc.numOfSvcsRecorded   
    , [c10(_col_label)]  = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 10))
) as cd10

/* Month 11 */

cross apply (
  select top 1
      [c11]              = pc.numOfSvcsRecorded    
    , [c11(_col_label)] = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 11))
) as cd11

/* Month 12 */

cross apply (
  select top 1
      [c12]              = pc.numOfSvcsRecorded     
    , [c12(_col_label)]  = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 12))
) as cd12

/* Month 13 */

cross apply (
  select top 1 
      [c13]              = pc.numOfSvcsRecorded     
    , [c13(_col_label)]  = cdr.monthYearStr
  from @pracsAndCounts as pc 
  join @dates          as cdr on cdr.idx = pc.dateIdx
  where 
    ((pc.pracID = pracs.pracID) and (pc.dateIdx = 13))
) as cd13

return

end      
GO
  
USE [spedmon]
GO

GRANT SELECT ON  [dbo].[RPT_PRAC_TATTLE_TALE_CORE] TO [webuser]
GO
  

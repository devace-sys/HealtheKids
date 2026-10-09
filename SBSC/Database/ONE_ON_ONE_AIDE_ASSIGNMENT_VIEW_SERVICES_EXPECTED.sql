USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_SERVICES_EXPECTED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_SERVICES_EXPECTED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_SERVICES_EXPECTED]    
(@clientID    INT,
 @patID       INT,
 @startDate   DATETIME,
 @endDate     DATETIME,
 
 @includeBS   BIT,
 @startDateBS DATETIME,
 @endDateBS   DATETIME,
 
 @includeDS   BIT,
 @startDateDS DATETIME,
 @endDateDS   DATETIME,
 
 @includeAS   BIT,
 @startDateAS DATETIME,
 @endDateAS   DATETIME

 )    

RETURNS TABLE

 /***************************************************************************    
  * ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_SERVICES_EXPECTED */    
 /**    
  * Returns a table of expected services 
  *    
  * @param  clientID        Required.  ID of client. 
  * @param  pracID          Required.  ID of practitioner.    
  * @param  patID           Required.  ID of patient.
  * @param  startDate       Required.  Start of month.
  * @param  endDate         Required.  End of month
  * @param  includeBS       Required.
  * @param  startDateBS     Required.
  * @param  endDateBS       Required.
  * @param  includeDS       Required.
  * @param  startDateDS     Required.
  * @param  endDateDS       Required.
  * @param  includeAS       Required.
  * @param  startDateAS     Required.
  * @param  endDateAS       Required.  
  * @return                 Table of expected service data   
  ***************************************************************************/     
  
AS RETURN
(

with

/*============================================================
 * All dates for before school services for appropriate 
 * date range limited to overall date range
 *============================================================*/

cte_dates_bs
as
(
  select * 
  from dbo.DATE_SEQUENCE(@startDateBS, @endDateBS) 
  where ([date] between @startDate and @endDate) and (@includeBS = 1)
) 
,

/*============================================================
 * All dates for during school services for appropriate 
 * date range limited to overall date range
 *============================================================*/

cte_dates_ds
as
(
  select * 
  from dbo.DATE_SEQUENCE(@startDateDS, @endDateDS) 
  where ([date] between @startDate and @endDate) and (@includeDS = 1)
) 
,

/*============================================================
 * All dates for after school services for appropriate 
 * date range limited to overall date range
 *============================================================*/

cte_dates_as
as
(
  select * 
  from dbo.DATE_SEQUENCE(@startDateAS, @endDateAS) 
  where ([date] between @startDate and @endDate) and (@includeAS = 1)
) 
,

/*============================================================
 * Details before school
 *============================================================*/

cte_details_bs
as
(
  select 
    tmtrs.*,
    [whenFlags] = 1
  from cte_dates_bs as dts    
  cross apply
  (
    select
      *            
    from dbo.RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_DETAIL (@clientID,
                                                             @patID,
                                                             null, 
                                                             dts.date, 
                                                             dbo.CONST_SERVICES_TREATMENT(),
                                                             dbo.CONST_SERVICES_TMT_WHEN_BS(),
                                                             null,
                                                             1,
                                                             1)  
  ) as tmtrs  

)

,

/*============================================================
 * Details during school
 *============================================================*/

cte_details_ds
as
(
  select 
    tmtrs.*,
    [whenFlags] = 2
  from cte_dates_ds as dts    
  cross apply
  (
    select
      *            
    from dbo.RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_DETAIL (@clientID,
                                                             @patID,
                                                             null, 
                                                             dts.date, 
                                                             dbo.CONST_SERVICES_TREATMENT(),
                                                             dbo.CONST_SERVICES_TMT_WHEN_DS(),
                                                             null,
                                                             1,
                                                             1)  
  ) as tmtrs  

)
,

/*============================================================
 * Details after school
 *============================================================*/

cte_details_as
as
(
  select 
    tmtrs.*,   
    [whenFlags] = 4
  from cte_dates_as as dts    
  cross apply
  (
    select
      *            
    from dbo.RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_DETAIL (@clientID,
                                                             @patID,
                                                             null, 
                                                             dts.date, 
                                                             dbo.CONST_SERVICES_TREATMENT(),
                                                             dbo.CONST_SERVICES_TMT_WHEN_AS(),
                                                             null,
                                                             1,
                                                             1)  
  ) as tmtrs  

)
,

/*============================================================
 * Details Combined Pass 1
 *============================================================*/

cte_details_combined_pass_1
as
(
  select
    
    whenFlags,
    dos,    
    dbo.RPT_DATE_FMT(dos)        as [attendanceDay], 
    dayTypeName                  as [attendanceDayType], 
    
    inIEP,
    pracID,
    PracName                     as [pracName],
    pracNote                     as [pracNote],
    NumMinsExpd                  as [numMinsExpd],
    NumDailyMinsExpd             as [numDailyMinsExpd],
    NumDailyMinsRecv             as [numDailyMinsRecv],
    SvcSlotProc                  as [svcSlotProc],
    NumSlotClaimsWaiting         as [numSlotClaimsWaiting],
    NumSlotClaimsSent            as [numSlotClaimsSent],
    NumSvcsRecv                  as [numSvcsRecv],
    isnull(SchNumPeriods,  0)    as [SchNumPeriods],
    isnull(SchFirstPeriod, 0)    as [SchPerFirst],
    isnull(SchLastPeriod,  0)    as [SchPerLast], 
    
    isnull(SchPer0Min,     0)    as [SchPer0Min],
    isnull(SchPer1Min,     0)    as [SchPer1Min],
    isnull(SchPer2Min,     0)    as [SchPer2Min],
    isnull(SchPer3Min,     0)    as [SchPer3Min],
    isnull(SchPer4Min,     0)    as [SchPer4Min],
    isnull(SchPer5Min,     0)    as [SchPer5Min],
    isnull(SchPer6Min,     0)    as [SchPer6Min],
    isnull(SchPer7Min,     0)    as [SchPer7Min],
    isnull(SchPer8Min,     0)    as [SchPer8Min],
    isnull(SchPer9Min,     0)    as [SchPer9Min],
    isnull(SchPer10Min,    0)    as [SchPer10Min],
  
    isnull(SchPass0to1Min, 0)    as [SchPas0Min],
    isnull(SchPass1to2Min, 0)    as [SchPas1Min],
    isnull(SchPass2to3Min, 0)    as [SchPas2Min],
    isnull(SchPass3to4Min, 0)    as [SchPas3Min],
    isnull(SchPass4to5Min, 0)    as [SchPas4Min],  
    isnull(SchPass5to6Min, 0)    as [SchPas5Min],
    isnull(SchPass6to7Min, 0)    as [SchPas6Min],
    isnull(SchPass7to8Min, 0)    as [SchPas7Min],
    isnull(SchPass8to9Min, 0)    as [SchPas8Min],
    isnull(SchPass9to10Min,0)    as [SchPas9Min],
    
    calendarName,
    scheduleName,
    calendarID,
    scheduleID,
    dayTypeID,
    SvcNameID

  
  from
  (
    select * from cte_details_bs
    union all
    select * from cte_details_ds
    union all
    select * from cte_details_as
  ) as q1
  where dayTypeName is not null
)
,

/*============================================================
 * Details Combined Pass 2
 *============================================================*/

cte_details_combined_pass_2
as
(
  select * from cte_details_combined_pass_1 where numMinsExpd != 0
)

/*============================================================
 * Return rows
 *============================================================*/  

select top (dbo.CONST_MAX_ROWS()) * from cte_details_combined_pass_2 order by dos, whenFlags

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_SERVICES_EXPECTED] TO [webuser]
GO

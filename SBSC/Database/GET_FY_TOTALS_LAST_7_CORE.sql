USE SPEDMON
GO

/*-------------------------------
* Exists/Drop
*------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_FY_TOTALS_LAST_7_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_FY_TOTALS_LAST_7_CORE
GO

CREATE FUNCTION [dbo].[GET_FY_TOTALS_LAST_7_CORE] ( )

returns @recs TABLE (
    CLIENT_ID               bigint
  , CLIENT_NAME             nvarchar(max)
  , CLIENT_CDS              nchar(7)
  , CLIENT_NPI              nchar(10)
  , COMPANY_NAME            varchar(100)
  , REP_NAME                varchar(255)
  , LEA_RECOVERY_BUDGET     decimal(18,2)
  , LEA                     bit
  , OK_TO_REPORT_UP_TO_DATE date  
  , FY0                     varchar(20)
  , FY0_TOT_SVCS            money
  , FY0_TOT_ADJS            money
  , FY0_TOT_STATE_FEES      money
  , FY0_TOT_DISB            numeric (18,8)
  
  , FY1                     varchar(20)
  , FY1_TOT_SVCS            money
  , FY1_TOT_ADJS            money
  , FY1_TOT_STATE_FEES      money
  , FY1_TOT_DISB            numeric (18,8)
  
  , FY2                     varchar(20)
  , FY2_TOT_SVCS            money
  , FY2_TOT_ADJS            money
  , FY2_TOT_STATE_FEES      money
  , FY2_TOT_DISB            numeric (18,8)
  
  , FY3                     varchar(20)
  , FY3_TOT_SVCS            money
  , FY3_TOT_ADJS            money
  , FY3_TOT_STATE_FEES      money
  , FY3_TOT_DISB            numeric (18,8)
  
  , FY4                     varchar(20)
  , FY4_TOT_SVCS            money
  , FY4_TOT_ADJS            money
  , FY4_TOT_STATE_FEES      money
  , FY4_TOT_DISB            numeric (18,8)
  
  , FY5                     varchar(20)
  , FY5_TOT_SVCS            money
  , FY5_TOT_ADJS            money
  , FY5_TOT_STATE_FEES      money
  , FY5_TOT_DISB            numeric (18,8)

  , FY6                     varchar(20)
  , FY6_TOT_SVCS            money
  , FY6_TOT_ADJS            money
  , FY6_TOT_STATE_FEES      money
  , FY6_TOT_DISB            numeric (18,8)
    
  unique clustered (CLIENT_ID)  
)
AS
BEGIN


declare @baseRptData as table (
    IDX                     bigint identity (1,1)
  , CLIENT_ID               bigint
  , CLIENT_NAME             nvarchar(max)
  , CLIENT_CDS              nchar(7)
  , CLIENT_NPI              nchar(10)
  , COMPANY_NAME            varchar(100)
  , REP_NAME                varchar(255)
  , LEA_RECOVERY_BUDGET     decimal(18,2)
  , LEA                     bit
  , WHAT_FY                 int
  , FY_DEFINITION           varchar(20)
  , FY_START                date
  , FY_END                  date
  , OK_TO_REPORT_UP_TO_DATE date
  , TOT_SVCS                money
  , TOT_ADJS                money
  , TOT_STATE_FEES          money
  , TOT_DISB                numeric (18,8)

    unique    clustered (IDX)
  , unique nonclustered (CLIENT_ID, IDX)
)

declare @pivotedRptData as table (
    CLIENT_ID               bigint
  , CLIENT_NAME             nvarchar(max)
  , CLIENT_CDS              nchar(7)
  , CLIENT_NPI              nchar(10)
  , COMPANY_NAME            varchar(100)
  , REP_NAME                varchar(255)
  , LEA_RECOVERY_BUDGET     decimal(18,2)
  , LEA                     bit  
  , OK_TO_REPORT_UP_TO_DATE date  
  , FY0                     varchar(20)
  , FY0_TOT_SVCS            money
  , FY0_TOT_ADJS            money
  , FY0_TOT_STATE_FEES      money
  , FY0_TOT_DISB            numeric (18,8)
  
  , FY1                     varchar(20)
  , FY1_TOT_SVCS            money
  , FY1_TOT_ADJS            money
  , FY1_TOT_STATE_FEES      money
  , FY1_TOT_DISB            numeric (18,8)
  
  , FY2                     varchar(20)
  , FY2_TOT_SVCS            money
  , FY2_TOT_ADJS            money
  , FY2_TOT_STATE_FEES      money
  , FY2_TOT_DISB            numeric (18,8)
  
  , FY3                     varchar(20)
  , FY3_TOT_SVCS            money
  , FY3_TOT_ADJS            money
  , FY3_TOT_STATE_FEES      money
  , FY3_TOT_DISB            numeric (18,8)
  
  , FY4                     varchar(20)
  , FY4_TOT_SVCS            money
  , FY4_TOT_ADJS            money
  , FY4_TOT_STATE_FEES      money
  , FY4_TOT_DISB            numeric (18,8)
  
  , FY5                     varchar(20)
  , FY5_TOT_SVCS            money
  , FY5_TOT_ADJS            money
  , FY5_TOT_STATE_FEES      money
  , FY5_TOT_DISB            numeric (18,8)

  , FY6                     varchar(20)
  , FY6_TOT_SVCS            money
  , FY6_TOT_ADJS            money
  , FY6_TOT_STATE_FEES      money
  , FY6_TOT_DISB            numeric (18,8)
    
  unique clustered (CLIENT_ID)  
)

insert into @baseRptData
select 

    t1.CLIENT_ID
  , t1.CLIENT_NAME
  , t1.CLIENT_CDS 
  , t1.CLIENT_NPI
  , t1.COMPANY_NAME
  , t1.REP_NAME
  , t1.LEA_RECOVERY_BUDGET
  , t1.LEA
  , t2.WHAT_FY     
  , t2.FY_DEFINITION
  , t2.FY_START    
  , t2.FY_END      
  , t2.OK_TO_PUBLISH as OK_TO_REPORT_UP_TO_DATE
  , t2.TOT_SVCS 
  , t2.TOT_ADJS
  , t2.TOT_STATE_FEES
  , t2.TOT_DISB    
from dbo.CLIENTS_Client_All as t1
join dbo.CLIENT_FY_TOTALS   as t2 on t2.CLIENT_ID = t1.CLIENT_ID
where (t2.WHAT_FY between 0 and 6)

/*============================================================
 * Initial populatation of pivot report table variable
 * with client id, client name, ok to report date, and
 * fiscal year definitions
 *============================================================*/  

insert into @pivotedRptData (
    CLIENT_ID
  , CLIENT_NAME
  , CLIENT_CDS
  , CLIENT_NPI
  , COMPANY_NAME
  , REP_NAME
  , LEA_RECOVERY_BUDGET
  , LEA 
  , OK_TO_REPORT_UP_TO_DATE
  , FY0
  , FY1
  , FY2
  , FY3
  , FY4
  , FY5
  , FY6)
select
   CLIENT_ID
 , CLIENT_NAME
 , CLIENT_CDS
 , CLIENT_NPI
 , COMPANY_NAME
 , REP_NAME
 , LEA_RECOVERY_BUDGET
 , LEA 
 , OK_TO_REPORT_UP_TO_DATE
 , [0] as FY0
 , [1] as FY1
 , [2] as FY2
 , [3] as FY3
 , [4] as FY4
 , [5] as FY5
 , [6] as FY6

from 
(
  select 
      CLIENT_ID
    , CLIENT_NAME
    , CLIENT_CDS
    , CLIENT_NPI
    , COMPANY_NAME
    , REP_NAME
    , LEA_RECOVERY_BUDGET
    , LEA
    , OK_TO_REPORT_UP_TO_DATE
    , WHAT_FY
    , FY_DEFINITION from @baseRptData     
) as q1
PIVOT
(
  MAX(FY_DEFINITION) FOR WHAT_FY IN ([0], [1], [2], [3], [4], [5], [6])
) pv

/*============================================================
 * Update of pivot report table variable
 * with service totals
 *============================================================*/  

update t1
set 
     t1.FY0_TOT_SVCS = t2.FY0
   , t1.FY1_TOT_SVCS = t2.FY1
   , t1.FY2_TOT_SVCS = t2.FY2
   , t1.FY3_TOT_SVCS = t2.FY3
   , t1.FY4_TOT_SVCS = t2.FY4
   , t1.FY5_TOT_SVCS = t2.FY5
   , t1.FY6_TOT_SVCS = t2.FY6

 from @pivotedRptData as t1
 join
 (
   SELECT 
         CLIENT_ID
       , [0] as FY0
       , [1] as FY1
       , [2] as FY2
       , [3] as FY3
       , [4] as FY4
       , [5] as FY5
       , [6] as FY6

     from          
     (
       select CLIENT_ID, WHAT_FY, TOT_SVCS from @baseRptData     
     ) as q1
     
     PIVOT
     (
         SUM(TOT_SVCS) FOR WHAT_FY IN ([0], [1], [2], [3], [4], [5], [6])
     ) pv
 ) as t2 on t2.CLIENT_ID = t1.CLIENT_ID
 
/*============================================================
 * Update of pivot report table variable
 * with adjustments
 *============================================================*/  
 
update t1
set 
     t1.FY0_TOT_ADJS = t2.FY0
   , t1.FY1_TOT_ADJS = t2.FY1
   , t1.FY2_TOT_ADJS = t2.FY2
   , t1.FY3_TOT_ADJS = t2.FY3
   , t1.FY4_TOT_ADJS = t2.FY4
   , t1.FY5_TOT_ADJS = t2.FY5
   , t1.FY6_TOT_ADJS = t2.FY6

 from @pivotedRptData as t1
 join
 (
   SELECT 
         CLIENT_ID
       , [0] as FY0
       , [1] as FY1
       , [2] as FY2
       , [3] as FY3
       , [4] as FY4
       , [5] as FY5
       , [6] as FY6

     from          
     (
       select CLIENT_ID, WHAT_FY, TOT_ADJS from @baseRptData     
     ) as q1
     
     PIVOT
     (
         SUM(TOT_ADJS) FOR WHAT_FY IN ([0], [1], [2], [3], [4], [5], [6])
     ) pv
 ) as t2 on t2.CLIENT_ID = t1.CLIENT_ID
 

/*============================================================
 * Update of pivot report table variable
 * with state fees
 *============================================================*/  
 
update t1
set 
     t1.FY0_TOT_STATE_FEES = t2.FY0
   , t1.FY1_TOT_STATE_FEES = t2.FY1
   , t1.FY2_TOT_STATE_FEES = t2.FY2
   , t1.FY3_TOT_STATE_FEES = t2.FY3
   , t1.FY4_TOT_STATE_FEES = t2.FY4
   , t1.FY5_TOT_STATE_FEES = t2.FY5
   , t1.FY6_TOT_STATE_FEES = t2.FY6

 from @pivotedRptData as t1
 join
 (
   SELECT 
         CLIENT_ID
       , [0] as FY0
       , [1] as FY1
       , [2] as FY2
       , [3] as FY3
       , [4] as FY4
       , [5] as FY5
       , [6] as FY6

     from          
     (
       select CLIENT_ID, WHAT_FY, TOT_STATE_FEES from @baseRptData     
     ) as q1
     
     PIVOT
     (
         SUM(TOT_STATE_FEES) FOR WHAT_FY IN ([0], [1], [2], [3], [4], [5], [6])
     ) pv
 ) as t2 on t2.CLIENT_ID = t1.CLIENT_ID
 

/*============================================================
 * Update of pivot report table variable
 * with disbursements
 *============================================================*/  
 
update t1
set 
     t1.FY0_TOT_DISB = t2.FY0
   , t1.FY1_TOT_DISB = t2.FY1
   , t1.FY2_TOT_DISB = t2.FY2
   , t1.FY3_TOT_DISB = t2.FY3
   , t1.FY4_TOT_DISB = t2.FY4
   , t1.FY5_TOT_DISB = t2.FY5
   , t1.FY6_TOT_DISB = t2.FY6

 from @pivotedRptData as t1
 join
 (
   SELECT 
         CLIENT_ID
       , [0] as FY0
       , [1] as FY1
       , [2] as FY2
       , [3] as FY3
       , [4] as FY4
       , [5] as FY5
       , [6] as FY6

     from          
     (
       select CLIENT_ID, WHAT_FY, TOT_DISB from @baseRptData     
     ) as q1
     
     PIVOT
     (
         SUM(TOT_DISB) FOR WHAT_FY IN ([0], [1], [2], [3], [4], [5], [6])
     ) pv
 ) as t2 on t2.CLIENT_ID = t1.CLIENT_ID
 
/*============================================================
 * Output rows
 *============================================================*/  

insert into @recs
select 
  * 
from @pivotedRptData 

RETURN

END
GO

GRANT SELECT ON  [dbo].[GET_FY_TOTALS_LAST_7_CORE] TO [webuser]
GO
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_PAID_CURR_AND_PREVIOUS_FY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_PAID_CURR_AND_PREVIOUS_FY
GO

/*-------------------------------
 * Create memory optimized
 * types for table variables
 *------------------------------*/
           
USE SPEDMON
GO

DROP TYPE IF EXISTS dbo.CLAIMS_PAID_BY_1PX_SUB_TOT_BY_PRAC_MEM;  
CREATE TYPE dbo.CLAIMS_PAID_BY_1PX_SUB_TOT_BY_PRAC_MEM
as table (
    PRACTITIONER_ID bigint
  , AMOUNT_DISBURSED money
	INDEX ix1 NONCLUSTERED ([PRACTITIONER_ID])
) WITH(MEMORY_OPTIMIZED = ON);

USE SPEDMON
GO

DROP TYPE IF EXISTS dbo.CLAIMS_PAID_BY_2PX_SUB_TOT_BY_PRAC_MEM;  
CREATE TYPE dbo.CLAIMS_PAID_BY_2PX_SUB_TOT_BY_PRAC_MEM
as table (
    PRACTITIONER_ID          bigint
  , REPORT_GROUP_NAME        nvarchar(max) 
  , AMOUNT_DISBURSED_P1      money 
  , AMOUNT_DISBURSED_P2      money
  , AMOUNT_DISBURSED_P3      money 
  , AMOUNT_DISBURSED_P4      money 
  , AMOUNT_DISBURSED_P5      money  
  INDEX ix1 NONCLUSTERED ([PRACTITIONER_ID])
) WITH(MEMORY_OPTIMIZED = ON);

GO

USE SPEDMON
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLAIMS_PAID_CURR_AND_PREVIOUS_FY] ( 
	     @userID            BigInt
	   , @userGroup         Int   
	   , @userRank          Int 
	   , @clientID          BigInt
	   , @repID             BigInt    
)
     
returns @recs table (
      label     varchar(500)	
	, totalP1   money
	, fyLabelP1 varchar(50)
    , totalP2   money
	, fyLabelP2 varchar(50)
	, totalP3   money
	, fyLabelP3 varchar(50)
	, totalP4   money
	, fyLabelP4 varchar(50)
	, totalP5   money
	, fyLabelP5 varchar(50)
 ) 
  
as
begin

declare @today          as date
declare @todayLastYear  as date
declare @today2YearsAgo as date
declare @today3YearsAgo as date
declare @today4YearsAgo as date

declare @period1Start  as datetime
declare @period1End    as datetime
declare @period2Start  as datetime
declare @period2End    as datetime
declare @period3Start  as datetime
declare @period3End    as datetime
declare @period4Start  as datetime
declare @period4End    as datetime
declare @period5Start  as datetime
declare @period5End    as datetime

declare @period1Label  as varchar(50)
declare @period2Label  as varchar(50)
declare @period3Label  as varchar(50)
declare @period4Label  as varchar(50)
declare @period5Label  as varchar(50)

declare @subTotalsP1   as dbo.CLAIMS_PAID_BY_1PX_SUB_TOT_BY_PRAC_MEM
declare @subTotalsP2   as dbo.CLAIMS_PAID_BY_1PX_SUB_TOT_BY_PRAC_MEM
declare @subTotalsP3   as dbo.CLAIMS_PAID_BY_1PX_SUB_TOT_BY_PRAC_MEM
declare @subTotalsP4   as dbo.CLAIMS_PAID_BY_1PX_SUB_TOT_BY_PRAC_MEM
declare @subTotalsP5   as dbo.CLAIMS_PAID_BY_1PX_SUB_TOT_BY_PRAC_MEM
declare @subTotalsAllP as dbo.CLAIMS_PAID_BY_2PX_SUB_TOT_BY_PRAC_MEM

set @today          = getdate()
set @todayLastYear  = dateadd(year,-1,@today)
set @today2YearsAgo = dateadd(year,-2,@today)
set @today3YearsAgo = dateadd(year,-3,@today)
set @today4YearsAgo = dateadd(year,-4,@today)

/* Clients we are going to work with */

declare @clients as table (
    CLIENT_ID         bigint
  , LEARecoveryBudget money
)

insert into @clients (
  CLIENT_ID
, LEARecoveryBudget
)
select 
   clc.CLIENT_ID 
 , cc.LEARecoveryBudget
from dbo.CLIENTS_Client_Active_LEA as clc
join dbo.CLIENTS_CLIENT            as cc on cc.CLIENT_ID = clc.CLIENT_ID
where (
    (1=1) 
and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
and ((@repID    is null) or (clc.REP_ID    = @repID))
)

/* Get period 1 dates */
select top 1
	@period1Start = CAST(cfy.FY_START AS DATETIME) + CAST('00:00:00' AS DATETIME)
  , @period1End   = CAST(cfy.FY_END AS DATETIME)   + CAST('23:59:00' AS DATETIME)
  , @period1Label = cfy.FY_DEFINITION
from dbo.COMPANY_FISCAL_YEARS as cfy
where (@today between cfy.FY_START and cfy.FY_END)
	
/* Get period 2 dates */

select top 1
    @period2Start = CAST(cfy.FY_START AS DATETIME) + CAST('00:00:00' AS DATETIME)
  , @period2End   = CAST(cfy.FY_END AS DATETIME)   + CAST('23:59:00' AS DATETIME)
  , @period2Label = cfy.FY_DEFINITION
from dbo.COMPANY_FISCAL_YEARS as cfy
where (@todayLastYear between cfy.FY_START and cfy.FY_END)

/* Get period 3 dates */

select top 1
    @period3Start = CAST(cfy.FY_START AS DATETIME) + CAST('00:00:00' AS DATETIME)
  , @period3End   = CAST(cfy.FY_END AS DATETIME)   + CAST('23:59:00' AS DATETIME)
  , @period3Label = cfy.FY_DEFINITION
from dbo.COMPANY_FISCAL_YEARS as cfy
where (@today2YearsAgo between cfy.FY_START and cfy.FY_END)

/* Get period 4 dates */

select top 1
    @period4Start = CAST(cfy.FY_START AS DATETIME) + CAST('00:00:00' AS DATETIME)
  , @period4End   = CAST(cfy.FY_END AS DATETIME)   + CAST('23:59:00' AS DATETIME)
  , @period4Label = cfy.FY_DEFINITION
from dbo.COMPANY_FISCAL_YEARS as cfy
where (@today3YearsAgo between cfy.FY_START and cfy.FY_END)

/* Get period 5 dates */

select top 1
    @period5Start = CAST(cfy.FY_START AS DATETIME) + CAST('00:00:00' AS DATETIME)
  , @period5End   = CAST(cfy.FY_END AS DATETIME)   + CAST('23:59:00' AS DATETIME)
  , @period5Label = cfy.FY_DEFINITION
from dbo.COMPANY_FISCAL_YEARS as cfy
where (@today4YearsAgo between cfy.FY_START and cfy.FY_END)

/* Get period 1 sub totals by prac (excluding adjustements and others) */

insert into @subTotalsP1 (PRACTITIONER_ID,AMOUNT_DISBURSED)
select 
    cp1.PRACTITIONER_ID  as PRACTITIONER_ID
  , cp1.AMOUNT_DISBURSED as AMOUNT_DISBURSED
from @clients as c
cross apply (
select    
   p1.PRACTITIONER_ID
 , AMOUNT_DISBURSED = sum(p1.AMOUNT_DISBURSED)
from RPT_CLAIMS_PAID_BY_DATE_CORE ( c.CLIENT_ID, @period1Start, @period1End, null, null) as p1
where (p1.ADJUSTEMENTS_AND_OTHER = 0)
group by 
  p1.PRACTITIONER_ID
) as cp1
 
/* Get period 2 sub totals by prac (excluding adjustements and others) */

insert into @subTotalsP2 (PRACTITIONER_ID,AMOUNT_DISBURSED)
select 
    cp2.PRACTITIONER_ID  as PRACTITIONER_ID
  , cp2.AMOUNT_DISBURSED as AMOUNT_DISBURSED
from @clients as c
cross apply (
select 
   p2.PRACTITIONER_ID
 , AMOUNT_DISBURSED = sum(p2.AMOUNT_DISBURSED)
from RPT_CLAIMS_PAID_BY_DATE_CORE ( c.CLIENT_ID, @period2Start, @period2End, null, null) as p2
where (p2.ADJUSTEMENTS_AND_OTHER = 0)
group by 
  p2.PRACTITIONER_ID
) as cp2

/* Get period 3 sub totals by prac (excluding adjustements and others) */

insert into @subTotalsP3 (PRACTITIONER_ID,AMOUNT_DISBURSED)
select 
    cp3.PRACTITIONER_ID  as PRACTITIONER_ID
  , cp3.AMOUNT_DISBURSED as AMOUNT_DISBURSED
from @clients as c
cross apply (
select 
   p3.PRACTITIONER_ID
 , AMOUNT_DISBURSED = sum(p3.AMOUNT_DISBURSED)
from RPT_CLAIMS_PAID_BY_DATE_CORE ( c.CLIENT_ID, @period3Start, @period3End, null, null) as p3
where (p3.ADJUSTEMENTS_AND_OTHER = 0)
group by 
  p3.PRACTITIONER_ID
) as cp3

/* Get period 4 sub totals by prac (excluding adjustements and others) */

insert into @subTotalsP4 (PRACTITIONER_ID,AMOUNT_DISBURSED)
select 
    cp4.PRACTITIONER_ID  as PRACTITIONER_ID
  , cp4.AMOUNT_DISBURSED as AMOUNT_DISBURSED
from @clients as c
cross apply (
select 
   p4.PRACTITIONER_ID
 , AMOUNT_DISBURSED = sum(p4.AMOUNT_DISBURSED)
from RPT_CLAIMS_PAID_BY_DATE_CORE ( c.CLIENT_ID, @period4Start, @period4End, null, null) as p4
where (p4.ADJUSTEMENTS_AND_OTHER = 0)
group by 
  p4.PRACTITIONER_ID
) as cp4

/* Get period 5 sub totals by prac (excluding adjustements and others) */

insert into @subTotalsP5 (PRACTITIONER_ID,AMOUNT_DISBURSED)
select 
    cp5.PRACTITIONER_ID  as PRACTITIONER_ID
  , cp5.AMOUNT_DISBURSED as AMOUNT_DISBURSED
from @clients as c
cross apply (
select 
   p5.PRACTITIONER_ID
 , AMOUNT_DISBURSED = sum(p5.AMOUNT_DISBURSED)
from RPT_CLAIMS_PAID_BY_DATE_CORE ( c.CLIENT_ID, @period5Start, @period5End, null, null) as p5
where (p5.ADJUSTEMENTS_AND_OTHER = 0)
group by 
  p5.PRACTITIONER_ID
) as cp5

/* Get all practitioners involved in all periods */

insert into @subTotalsAllP (PRACTITIONER_ID)
select distinct p1.PRACTITIONER_ID from @subTotalsP1 as p1
union
select distinct p1.PRACTITIONER_ID from @subTotalsP2 as p1
union
select distinct p1.PRACTITIONER_ID from @subTotalsP3 as p1
union
select distinct p1.PRACTITIONER_ID from @subTotalsP4 as p1
union
select distinct p1.PRACTITIONER_ID from @subTotalsP5 as p1

update @subTotalsAllP 
 set  AMOUNT_DISBURSED_P1 = 0
    , AMOUNT_DISBURSED_P2 = 0
	, AMOUNT_DISBURSED_P3 = 0
	, AMOUNT_DISBURSED_P4 = 0
	, AMOUNT_DISBURSED_P5 = 0
	, REPORT_GROUP_NAME = 'No Reporting Group Set'

/* Get reporting group for these pracs */

update allp
  set 
   allp.REPORT_GROUP_NAME   = gg.GROUP_NAME
from @subTotalsAllP          as allp
join dbo.PRACTITIONER_GROUPS as pg on pg.PRACTITIONER_ID = allp.PRACTITIONER_ID
join dbo.GROUP_Group         as gg on gg.GROUP_ID = pg.GROUP_ID
where ((pg.GROUP_TYPE in (3,5) and (gg.GROUP_TYPE in (3,5))))

/* Put p1 totals in */

update allp
  set allp.AMOUNT_DISBURSED_P1 = p1.AMOUNT_DISBURSED
from @subTotalsAllP          as allp
join @subTotalsP1            as p1 on p1.PRACTITIONER_ID = allp.PRACTITIONER_ID

/* Put p2 totals in*/

update allp
  set allp.AMOUNT_DISBURSED_P2 = p2.AMOUNT_DISBURSED
from @subTotalsAllP          as allp
join @subTotalsP2            as p2 on p2.PRACTITIONER_ID = allp.PRACTITIONER_ID

/* Put p3 totals in*/

update allp
  set allp.AMOUNT_DISBURSED_P3 = p3.AMOUNT_DISBURSED
from @subTotalsAllP          as allp
join @subTotalsP3            as p3 on p3.PRACTITIONER_ID = allp.PRACTITIONER_ID

/* Put p4 totals in*/

update allp
  set allp.AMOUNT_DISBURSED_P4 = p4.AMOUNT_DISBURSED
from @subTotalsAllP          as allp
join @subTotalsP4            as p4 on p4.PRACTITIONER_ID = allp.PRACTITIONER_ID

/* Put p5 totals in*/

update allp
  set allp.AMOUNT_DISBURSED_P4 = p5.AMOUNT_DISBURSED
from @subTotalsAllP          as allp
join @subTotalsP5            as p5 on p5.PRACTITIONER_ID = allp.PRACTITIONER_ID

insert into @recs
select 
  label     = q1.REPORT_GROUP_NAME
, totalp1   = dbo.BANKERS_ROUND(q1.totalp1,0)
, fyLabelP1 = @period1Label
, totalp2   = dbo.BANKERS_ROUND(q1.totalp2,0)
, fyLabelP2 = @period2Label
, totalp3   = dbo.BANKERS_ROUND(q1.totalp3,0)
, fyLabelP3 = @period3Label
, totalp4   = dbo.BANKERS_ROUND(q1.totalp4,0)
, fyLabelP4 = @period4Label
, totalp5   = dbo.BANKERS_ROUND(q1.totalp5,0)
, fyLabelP5 = @period5Label
from
(
  select 
    allp.REPORT_GROUP_NAME
  , totalp1 = sum(allp.AMOUNT_DISBURSED_P1)
  , totalp2 = sum(allp.AMOUNT_DISBURSED_P2)
  , totalp3 = sum(allp.AMOUNT_DISBURSED_P3)
  , totalp4 = sum(allp.AMOUNT_DISBURSED_P4)
  , totalp5 = sum(allp.AMOUNT_DISBURSED_P5)
  from @subTotalsAllP as allp
  group by 
    allp.REPORT_GROUP_NAME
) as q1
return

end
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_PAID_CURR_AND_PREVIOUS_FY] TO [webuser]
GO
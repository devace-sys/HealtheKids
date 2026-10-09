USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_SUMMARY] (  )    

RETURNS @recs TABLE (
    REASON         varchar(max)
  , W1_TO_W8_DATES varchar(512)
  , W1_TO_W8_SUM   int
  , W1_TO_W8_AVG   int
  , W1_TO_W8_STDEV int
  , W1             int
  , W2             int
  , W3             int
  , W4             int
  , W5             int
  , W6             int
  , W7             int
  , W8             int
  --, W9            int
  --, W10           int
  --, W11           int
 -- , W12           int
 -- , W13           int
 -- , W14           int
 -- , W15           int
 -- , W16           int
)
 
/***************************************************************************    
 * CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_SUMMARY */    
/**    
 ***************************************************************************/                         
     
AS 
BEGIN
 
declare @minStartDate as datetime
declare @maxEndDate   as datetime

declare @detailSlots as table (
     REASON     varchar(8000)
   , SLOT       int
   , START_DATE datetime
   , END_DATE   datetime
   , NUM_OF     int
)

declare @summarySlots as table (
     REASON         varchar(8000)
   , DATE_RANGE_STR varchar(512)
   , SUM_OF         int
   , AVG_OF         int
   , STDEV_OF       int
)

/* First get details for each week slot and denial reason and compute total */

insert into @detailSlots
select  
    ds.REASON
  , ds.SLOT
  , ds.START_DATE
  , ds.END_DATE 
  , NUM_OF = count(ds.ADJUDICATION_ID)
from dbo.CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DATA_CORE (null, 8 /* Change if we expand*/) as ds

group by

  ds.REASON
 ,ds.SLOT
 ,ds.START_DATE
 ,ds.END_DATE

order by 
    ds.REASON
  , ds.SLOT

/* Get the earliest and latest dates represented */

select 
    @minStartDate = min(ds.START_DATE)
  , @maxEndDate   = max(ds.END_DATE) 
from @detailSlots as ds

/* Generate summary data for each denial reason -- Pass 1 */

insert into @summarySlots (REASON, SUM_OF, AVG_OF, STDEV_OF)
select  
    ds.REASON
  , SUM_OF   = sum(ds.NUM_OF)
  , AVG_OF   = CEILING(isnull(avg(ds.NUM_OF),0))
  , STDEV_OF = CEILING(isnull(STDEV(ds.NUM_OF),0))
from @detailSlots as ds
group by 
  ds.REASON

/* Generate summary data for each denial reason -- Pass 2 */

update @summarySlots 
  set DATE_RANGE_STR = dbo.RPT_DATE_FMT(@minStartDate) 
                     + ' - ' 
					 + dbo.RPT_DATE_FMT(@maxEndDate)

/* Generate and return complete report */

insert into @recs
select  

    REASON           = ss.REASON 
  , W1_TO_W8_DATES   = ss.DATE_RANGE_STR
  , W1_TO_W8_SUM     = ss.SUM_OF
  , W1_TO_W8_AVG     = ss.AVG_OF
  , W1_TO_W8_STD_DEV = ss.STDEV_OF
  , W1   = isnull(c1.NUM_OF,0)
  , W2   = isnull(c2.NUM_OF,0)
  , W3   = isnull(c3.NUM_OF,0)
  , W4   = isnull(c4.NUM_OF,0)

  , W5   = isnull(c5.NUM_OF,0)
  , W6   = isnull(c6.NUM_OF,0)
  , W7   = isnull(c7.NUM_OF,0)
  , W8   = isnull(c8.NUM_OF,0)

  --, W9   = isnull(c9.NUM_OF,0)
  --, W10  = isnull(c10.NUM_OF,0)
  --, W11  = isnull(c11.NUM_OF,0)
  --, W12  = isnull(c12.NUM_OF,0)

  --, W13  = isnull(c13.NUM_OF,0)
  --, W14  = isnull(c14.NUM_OF,0)
  --, W15  = isnull(c15.NUM_OF,0)
  --, W16  = isnull(c16.NUM_OF,0)

from @summarySlots as ss

outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 1)  and (ds.REASON = ss.REASON))) as c1
outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 2)  and (ds.REASON = ss.REASON))) as c2
outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 3)  and (ds.REASON = ss.REASON))) as c3
outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 4)  and (ds.REASON = ss.REASON))) as c4

outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 5)  and (ds.REASON = ss.REASON))) as c5
outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 6)  and (ds.REASON = ss.REASON))) as c6
outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 7)  and (ds.REASON = ss.REASON))) as c7
outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 8)  and (ds.REASON = ss.REASON))) as c8

--outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 9)  and (ds.REASON = ss.REASON))) as c9
--outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 10) and (ds.REASON = ss.REASON))) as c10
--outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 11) and (ds.REASON = ss.REASON))) as c11
--outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 12) and (ds.REASON = ss.REASON))) as c12

--outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 13) and (ds.REASON = ss.REASON))) as c13
--outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 14) and (ds.REASON = ss.REASON))) as c14
--outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 15) and (ds.REASON = ss.REASON))) as c15
--outer apply (select top 1 ds.NUM_OF from @detailSlots as ds where ((ds.slot = 16) and (ds.REASON = ss.REASON))) as c16

order by 
  ss.REASON

return

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_SUMMARY] TO [webuser]
GO  

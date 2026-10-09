USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY_FOR_SELPA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY_FOR_SELPA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY_FOR_SELPA]
(
   @userID               bigint
 , @userGroup            int
 , @userRank             int 
 , @selpaCode            int
 , @startDate            date
 , @endDate              date
)
returns
table
as
return
(

with
cte_p1
as
(
  select 
    cbs2.* 
  from dbo.SELPA_RELATED_CLIENTS_VIEW_CORE(@selpaCode) as se
  cross apply (
    select 
	  cbs1.* 
	from dbo.RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY (@userID,@userGroup,@userRank,se.clientID,@startDate,@endDate) as cbs1
  ) as cbs2
)
,
cte_p2
as
(
  select 
      patsInBucketA = sum(p1.patsInBucketA)
    , patsInBucketB = sum(p1.patsInBucketB)
    , patsInBucketC = sum(p1.patsInBucketC)
    , totalPats     = sum(p1.totalPats)
  from cte_p1 as p1
)
,
cte_p3
as
(
select 
    p2.* 
  , startDate      = convert(date,users.dbo.APP_SETTING_GET_VALUE ('spedcare','cde','compliance','dates','global','current-window-start-date'))
  , endDate        = convert(date,users.dbo.APP_SETTING_GET_VALUE ('spedcare','cde','compliance','dates','global','current-window-end-date'))
from cte_p2 as p2
)
select 
    p3.* 
  , startDateStr    = dbo.RPT_DATE_FMT            (p3.startDate)
  , endDateStr      = dbo.RPT_DATE_FMT            (p3.endDate)
  , startDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD (p3.startDate)
  , endDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD (p3.endDate)
from cte_p3 as p3
)

GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY_FOR_SELPA TO [webuser]
GO
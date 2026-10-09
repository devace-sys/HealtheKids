USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY]
(
   @userID               bigint
 , @userGroup            int
 , @userRank             int 
 , @clientID             bigint
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
    patsInBucketC  = sum(iif(pps.inCDEBucketC = 1,1,0))
  , patsInBucketB  = sum(iif(pps.inCDEBucketB = 1,1,0))
  , patsInBucketA  = sum(iif(pps.inCDEBucketA = 1,1,0))
  , startDate      = convert(date,users.dbo.APP_SETTING_GET_VALUE ('spedcare','cde','compliance','dates','global','current-window-start-date'))
  , endDate        = convert(date,users.dbo.APP_SETTING_GET_VALUE ('spedcare','cde','compliance','dates','global','current-window-end-date'))

from dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_CORE(@clientID,@startDate,@endDate) as pps
)

select  
    p1.*
  , startDateStr    = dbo.RPT_DATE_FMT            (p1.startDate)
  , endDateStr      = dbo.RPT_DATE_FMT            (p1.endDate)
  , startDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD (p1.startDate)
  , endDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD (p1.endDate)
  , totalPats = (patsInBucketC + patsInBucketB + patsInBucketA)
from cte_p1 as p1

)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY TO [webuser]
GO
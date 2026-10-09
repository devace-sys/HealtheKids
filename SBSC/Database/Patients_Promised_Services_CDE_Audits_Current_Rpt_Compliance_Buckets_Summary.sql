USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Rpt_Compliance_Buckets_Summary') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_CDE_Audits_Current_Rpt_Compliance_Buckets_Summary
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patients_Promised_Services_CDE_Audits_Current_Rpt_Compliance_Buckets_Summary]
(
    @userID                        bigint
  , @userGroup                     int
  , @userRank                      int 
  , @clientID                      bigint
  , @patAbsentMinsAreSatisfiedMins bit = 1
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
    pps.clientID
  , patsInBucketC  = sum(iif(pps.inCDEBucketC = 1,1,0))
  , patsInBucketB  = sum(iif(pps.inCDEBucketB = 1,1,0))
  , patsInBucketA  = sum(iif(pps.inCDEBucketA = 1,1,0))  
from dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_View_Core (
   @clientID
  , null
  , @patAbsentMinsAreSatisfiedMins) as pps
group by 
  pps.clientID
)

select  
    p1.*
  , totalPats = (patsInBucketC + patsInBucketB + patsInBucketA)
from cte_p1 as p1

)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.Patients_Promised_Services_CDE_Audits_Current_Rpt_Compliance_Buckets_Summary TO [webuser]
GO
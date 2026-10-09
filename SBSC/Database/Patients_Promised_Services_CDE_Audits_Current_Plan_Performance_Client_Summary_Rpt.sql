USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_Client_Summary_Rpt') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_Client_Summary_Rpt
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_Client_Summary_Rpt] (
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
select top (dbo.CONST_MAX_ROWS())
    t1.clientID 
  , clientName     = clc.CLIENT_NAME
  , auditStartDate = dbo.RPT_DATE_FMT(t1.startDate)
  , auditEndDate   = dbo.RPT_DATE_FMT(t1.endDate)
  , t3.* 
from dbo.Patients_Promised_Services_CDE_Audits_Current as t1
join dbo.CLIENTS_Client                                as clc on clc.CLIENT_ID = t1.clientID
cross apply (
  select top 1 
      t2.patsInBucketC 
    , t2.patsInBucketB
    , t2.patsInBucketA
    , t2.totalPats
  from dbo.Patients_Promised_Services_CDE_Audits_Current_Rpt_Compliance_Buckets_Summary(
      @userID
	, @userGroup
	, @userRank
	, t1.clientID
	, @patAbsentMinsAreSatisfiedMins) as t2
) as t3
where (
      (1=1)
  and ((@clientID is null) or (t1.clientID = @clientID))
  and (t1.active = 1)
)
order by 
  clc.CLIENT_NAME
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_Client_Summary_Rpt TO [webuser]
GO
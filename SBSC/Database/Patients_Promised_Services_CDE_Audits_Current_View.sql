USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_View') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_CDE_Audits_Current_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patients_Promised_Services_CDE_Audits_Current_View] (    
    @userID                        bigint
  , @userGroup                     int   
  , @userRank                      int
  , @clientID                      bigint
  , @patAbsentMinsAreSatisfiedMins bit = 1
)
 
RETURNS TABLE      
    
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  

with
cte_p1
as
(
  select top 1 /* Always only one record */
       t1.*
	 , [name] = clc.CLIENT_NAME
  from dbo.Patients_Promised_Services_CDE_Audits_Current as t1
  join dbo.CLIENTS_Client                                as clc on clc.CLIENT_ID = t1.clientID
  where (
        (t1.clientID = @clientID)
	and (t1.active = 1)
  )
)
,
cte_p2
as
(
  select top 1 
      p1.* 
    , startDateStr    = dbo.RPT_DATE_FMT(p1.startDate)
    , endDateStr      = dbo.RPT_DATE_FMT(p1.endDate)
	, startDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(p1.startDate)
    , endDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD(p1.endDate)
    , totalPats       = isnull(bs2.totalPats,     0)
	, patsInBucketA   = isnull(bs2.patsInBucketA, 0)
	, patsInBucketB   = isnull(bs2.patsInBucketB, 0)
	, patsInBucketC   = isnull(bs2.patsInBucketC, 0)
  from cte_p1 as p1
  outer apply (
    select 
	    bs1.totalPats
      , bs1.patsInBucketA
	  , bs1.patsInBucketB
	  , bs1.patsInBucketC
    from dbo.Patients_Promised_Services_CDE_Audits_Current_Rpt_Compliance_Buckets_Summary (
	    @userID
	  , @userGroup
	  , @userRank
	  , @clientID
	  , @patAbsentMinsAreSatisfiedMins
	) as bs1
  ) as bs2
)
select top 1 
  p2.* 
from cte_p2 as p2
order by 
  p2.id desc

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patients_Promised_Services_CDE_Audits_Current_View] TO [webuser]
GO   



USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_For_SELPA_View') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_CDE_Audits_Current_For_SELPA_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patients_Promised_Services_CDE_Audits_Current_For_SELPA_View] (    
    @userID                        bigint
  , @userGroup                     int   
  , @userRank                      int
  , @selpaCode                     int
  , @patAbsentMinsAreSatisfiedMins bit = 1
)
 
RETURNS TABLE      
    
AS RETURN(      
    
with
cte_p1
as
(
  select 
      se.selpaCode
	, se.selpaName
	, t2.* 
  from dbo.SELPA_RELATED_CLIENTS_VIEW_CORE(@selpaCode) as se
  cross apply (
    select 
	    t1.startDate
	  , t1.endDate
	  , t1.patsInBucketA
	  , t1.patsInBucketB
	  , t1.patsInBucketC
	  , t1.totalPats 
	from dbo.Patients_Promised_Services_CDE_Audits_Current_View ( 
	    @userID
	  , @userGroup
	  , @userRank
	  , se.clientID
	  , @patAbsentMinsAreSatisfiedMins
	) as t1
  ) as t2
)
,
cte_p2
as
(
  select 
      p1.selpaCode
    , p1.selpaName
    , startDate     = min(p1.startDate)
    , endDate       = max(p1.endDate)
    , patsInBucketA = sum(p1.patsInBucketA)
    , patsInBucketB = sum(p1.patsInBucketB)
    , patsInBucketC = sum(p1.patsInBucketC)
    , totalPats     = sum(p1.totalPats)

  from cte_p1 as p1
  group by 
      p1.selpaCode
    , p1.selpaName
)

select 
    id     = p2.selpaCode 
  , [name] = p2.selpaName
  , p2.patsInBucketA
  , p2.patsInBucketB
  , p2.patsInBucketC
  , p2.startDate
  , p2.endDate
  , startDateStr    = dbo.RPT_DATE_FMT            (p2.startDate)
  , endDateStr      = dbo.RPT_DATE_FMT            (p2.endDate)
  , startDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD (p2.startDate)
  , endDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD (p2.endDate)

from cte_p2 as p2
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patients_Promised_Services_CDE_Audits_Current_For_SELPA_View] TO [webuser]
GO   



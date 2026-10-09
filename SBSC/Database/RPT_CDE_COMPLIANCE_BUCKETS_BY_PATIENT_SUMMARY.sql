USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_SUMMARY]
(
   @userID               bigint
 , @userGroup            int
 , @userRank             int 
 , @clientID             bigint
 , @startDate            date
 , @endDate              date
 , @inCdeBucket          varchar(10)
)
returns
table
as
return
(

select 
    t1.*
  , patName  = pap.CONCAT_NAME
  , patDOB    = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
  , patSSID   = isnull(pap.CSIS,N'')
   
from dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_CORE(@clientID,@startDate,@endDate) as t1
join dbo.PATIENTS_Patient                                                          as pap on pap.PATIENT_ID = t1.patID
where ( 
       (1=1)
  and ((@inCdeBucket is null) or (t1.inCdeBucket = @inCdeBucket))
)
)

GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_SUMMARY TO [webuser]
GO
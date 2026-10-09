USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_SUMMARY] (
    @userID               bigint 
  , @userGroup            int
  , @userRank             int 
  , @clientID             bigint
  , @siteID               bigint
)
returns
table
as
return
(
select top (5) /* Note: Keep top x in synch with number of active rows in pcrfp */

    /* Note: We need the clientIDStr and siteIDStr cols here because we need to pass back
	 * the parameter values that the view method either replaced or passed through.
	 */

    clientIDStr = iif ((@clientID is null), '' , (convert(varchar(50),@clientID)))
  , siteIDStr   = iif ((@siteID   is null), '' , (convert(varchar(50),@siteID)))

  , pcrfp.code 
  , pcrfp.[name]
  , numOfPats = isnull(pps3.numOfPats,0)
from dbo.PATIENTS_Promised_Services_Pcal_Compliance_Rating_For_Pat_Codes as pcrfp

outer apply (

  select 
      pps2.pcalComplianceRatingForPat
    , numOfPats = count(pps2.patID)
  from
  (
    select distinct   
        pps1.pcalComplianceRatingForPat
      , pps1.patID
    from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services as pps1
    where (
              (pps1.clientID = @clientID)        
  		  and ((@siteID IS NULL) or (pps1.siteID = @siteID))
          and (pps1.pcalComplianceRatingForPat = pcrfp.code)
    )
  ) as pps2
  group by 
    pps2.pcalComplianceRatingForPat
) as pps3
where 
  (pcrfp.active = 1)
order by 
  pcrfp.code desc
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_SUMMARY TO [webuser]
GO
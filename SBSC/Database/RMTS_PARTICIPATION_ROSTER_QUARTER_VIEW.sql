USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPATION_ROSTER_QUARTER_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPATION_ROSTER_QUARTER_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_PARTICIPATION_ROSTER_QUARTER_VIEW] (
    @userID         BIGINT    
  , @userGroup      BIGINT    
  , @userRank       INT
  , @clientID       BIGINT
  , @recordID       BIGINT
  , @active         BIT
  
)    
RETURNS 
TABLE
AS
RETURN
(

  select top (dbo.CONST_MAX_ROWS())

   rpr.quarterName
	, rp.pracName

  , rp.pracFirstName
  , rp.pracLastName

	, rp.pracTitle
  , r_m.JobClassification
  , rp.reportingGroup

  , rp.pracEmail

	, rp.startDateStr
	, rp.reasonForStartDateChangeStr
	, rp.endDateStr
	, rp.reasonForEndDateChangeStr

  , rpr.quarterNumber
  , fyID
  , rp.hasServiceRecordsStr

  , qtrHasReimbursedClaims = CASE WHEN qtr_clm_paid.CLAIM_ID IS NOT NULL THEN 'Yes' ELSE 'No' END

  , fyHasReimbursedClaims = CASE WHEN fy_clm_paid.CLAIM_ID IS NOT NULL THEN 'Yes' ELSE 'No' END

  from  dbo.RMTS_PARTICIPANTS_VIEW_CORE(@clientID, @recordID, @active, null) as rp
  cross apply dbo.RMTS_PARTICIPATION_ROSTER_VIEW(@userID, @userGroup, @userRank, @clientID, @active, @recordID) as rpr

  OUTER APPLY ( 
		SELECT STRING_AGG ( JobClassification , ', ') JobClassification
		FROM (
			SELECT
			r_m.JobClassification
			FROM [dbo].[RMTS_Moments] as r_m
			WHERE (   
			 ((r_m.[clientID]  = rp.clientID) and (r_m.id > 0))	/* Uses for spedcare weekly report index */		
					AND
					r_m.[PracID]    = rp.pracID

					--AND
					--r_m.[quarterID] = rpr.quarterID

					-- we can't match by quarterID if they haven't
					-- uploaded any RMTS files yet for a given quarter
			)
			GROUP BY     r_m.[clientID], r_m.[PracID], r_m.JobClassification --, r_m.[quarterID]
		) r_m
  ) r_m

    OUTER APPLY (
        SELECT top 1 
		  cv_qtr.CLAIM_ID 
		FROM dbo.CLAIM_CLAIM as cv_qtr
	    WHERE (
          /* PRACID_CLIENTID,W_DOS */
		  (    ((cv_qtr.PRACTITIONER_ID = rp.pracID) and (cv_qtr.CLAIM_ID > 0)) 
	       and (cv_qtr.CLIENT_ID = @clientID) 
		   and (cv_qtr.SERVICE_DATE between quarterStartDate and quarterEndDate)
		  )
	      and (cv_qtr.[STATUS] = '3')              
        )
  ) qtr_clm_paid

  OUTER APPLY (
        SELECT top 1 
		  cv_fyr.CLAIM_ID 
		FROM dbo.CLAIM_CLAIM as cv_fyr
	    WHERE (
          /* PRACID_CLIENTID,W_DOS */
		   (   ((cv_fyr.PRACTITIONER_ID = rp.pracID) and (cv_fyr.CLAIM_ID > 0)) 
	       and (cv_fyr.CLIENT_ID = @clientID) 
		   and (cv_fyr.SERVICE_DATE between fyStartDate and fyEndDate)
	       )
		   and (cv_fyr.[STATUS] = '3')              
        )
  ) fy_clm_paid

  order by 
    rp.pracName
)
GO

GRANT SELECT ON  [dbo].[RMTS_PARTICIPATION_ROSTER_QUARTER_VIEW] TO [webuser]
GO

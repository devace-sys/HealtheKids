USE SPEDMON
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/




IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_RMTS_MOMENTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_RMTS_MOMENTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_RMTS_MOMENTS_VIEW]
(

  --

  @userID bigint,
  @userGroup int,
  @userRank int,

  @recid int,

  @environmentID int,

   @fyquarterid   BIGINT,


   @fyID        int,
   @quarterNum   int,

   @activityCode char(10),
   @matched      bit,
   @clientID     bigint,

   --
   @pracID       bigint,   --
   --

   @isComplete   bit,
   @pcalReviewStatusCode int ,

   @isDeferred    bit
)

RETURNS TABLE

 /***************************************************************************
  * RPT_RMTS_MOMENTS_VIEW */
 /**
  * Returns a table of report rows
  *
  * @param   userID         The userid of who is requesting the report
  * @param   userGroup      Users group
  * @param   userRank       User rank
  * @return                 Table of report rows
  ***************************************************************************/

AS RETURN

(

with
cte_p1
as
(

select
    fyID   = cfq.FY_ID
  , qtrNum = cfq.QTR
  , cfq.QTR_DEFINITION
  , pcalReviewStatusCode = isnull(rm.pcalReviewStatus,100)
  , activityCodeClean    = trim(isnull(rm.ActivityCode,''))
  , rm.*

  , momentTimeStr = dbo.[RPT_TIME_FMT]( rm.[momentTime], 0) 

from dbo.RMTS_MOMENTS              as rm

-- join dbo.RMTS_Moments_Data_Imports as rmdi on rmdi.id = rm.rmtsMomentDataImportID
  -- not using

join dbo.COMPANY_FISCAL_QUARTERS   as cfq  on cfq.ID  = rm.quarterID


   -- TODO - NOTE!  [dbo].[RMTS_Moment_Req] appears to be a very old, unused and abandoned table that should probably be cleaned up and dropped, eventually

where (
        (1=1)
    and ((@clientID     is null)  or (rm.clientID   = @clientID))

    --
    and (( @pracID     is null)  or (rm.pracID   =  @pracID ))  --
    --

    and ((@fyquarterid  is null)  or (rm.quarterID  = @fyquarterid))
	and ((@isComplete   is null)  or (rm.isComplete = @isComplete))
    and ((@recID        is null)  or (rm.id         = @recID))
	and (rm.active = 1)

	and ((@matched      is null)  or (
	                                  (rm.svcRecID IS NULL     AND @matched = 0)
	                               or (rm.svcRecID IS NOT NULL AND @matched = 1 )))

    and ((@fyID       is null)  or (cfq.FY_ID    = @fyID))
	and ((@quarterNum is null)  or (cfq.QTR      = @quarterNum))

  and  (
    ( @isDeferred = 0 AND rm.deferralDate IS NULL)
    OR
    ( @isDeferred = 1 AND rm.deferralDate IS NOT NULL)
    OR
    @isDeferred IS NULL
  )
)

)
,

/* Filter by review status code calculation or activity code calculation */

cte_p2
as
(
select
    p1.*
from cte_p1 as p1
where (
       (1=1)
   and ((@pcalReviewStatusCode is null) or (p1.pcalReviewStatusCode = @pcalReviewStatusCode))
   and (
           ( p1.activityCodeClean = @activityCode)
           OR
           (@activityCode  IS NULL  AND  p1.activityCodeClean in ( '2A', '2Z', '8')  )
           --  NOTE: ADDED  @activityCode filter here
        )
)
)
,
cte_p3
as
(
/* Get related file if any */
select
    p2.*
  , hasFiles = convert(bit, iif ((fu2.id is null), 0, 1))
from cte_p2 as p2
outer apply (
  /* Uses DUP_CHECK index */
  select top 1
	  fu1.id
	from dbo.FILE_UPLOADS as fu1
	where (
	      ((fu1.clientID = p2.clientID)
	  and (fu1.fileClass = 625)
	  and (fu1.fileSize  is not null)
	  and (fu1.id is not null))
	  and (fu1.referencedEntityID = p2.id)
	)
) as fu2
)
,
pre_flags as (
select  -- top (dbo.CONST_MAX_ROWS())

   p3.*
 , clientName           = cc.CLIENT_NAME
 , pcalReviewStatusName = rmprsc.[name]
 , Patient              = pap.CONCAT_NAME  + ' [' + dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH) + ']' /* Returning null for patient name is intended */

  -- BUGFIX: the browser was not filling in the hand green, in some rows, even when the isMatchedGreen bit was set true, in some cases.
  --       The browser behavior was correct, but the bit value was incorrect (here).
  --       We need the bit value here to be correct regardless, because we are sorting on it.

 , isMatchedGreen = isComplete



     ,isPreComplete = CASE WHEN

        p3.isComplete = 0
        AND
        (
          p3.svcRecID IS NOT NULL
          OR
          --( p3.hasFiles IS NOT NULL AND p3.respReqNotifSent = 1 )
         ( p3.hasFiles = 1  )

        )
     THEN cast(1 as bit) ELSE cast(0 as bit) END

       -- NOTE: isPreComplete isn't used on the page.  Let's consider removing this bit flag from the entire call stack if it isn't used in any
       --       of the action SPROCs.  This bit was implemented long before we eventually had to build out the rmtsReqNextStep int behavior.

       -- REVISED: actually, we're using the isPreComplete flag as the validation state for
       -- RMTS_MOMENT_FLAG_COMPLETE().
from cte_p3                                         as p3
join      dbo.CLIENTS_Client                        as cc     on cc.CLIENT_ID   = p3.clientID
join      dbo.RMTS_Moments_Pcal_Review_Status_Codes as rmprsc on rmprsc.code    = p3.pcalReviewStatusCode
left join dbo.SERVICE_RECORDS                       as sr  on sr.id          = p3.svcRecID
left join dbo.PATIENTS_Patient                      as pap on pap.PATIENT_ID = sr.patID

),

more_status_1 as (
     select *
 ,   matchingTooltip = CASE WHEN f_.hasFiles = 1  AND f_.mustCorrectThisMistake = 1 THEN
                      'Supporting documentation has been uploaded.  Row has been deemed erroneous.  '

                    -- TODO: successive WHENs in CASE statements are ignored after the first good match, functioning as else-if, correct?  dblcheck
                    WHEN f_.hasFiles = 1  AND f_.svcRecID IS NOT NULL THEN
                      'Supporting documentation has been uploaded.  Row has been matched with a service record.  '
                    WHEN f_.hasFiles = 1 THEN
                      'Supporting documentation has been uploaded.  '

                    WHEN ISNULL(f_.rmtsReqState, 0)= 0 THEN  -- TODO: not sure if the bit here is ever null, not worth checking
                      'No match found.'

                    WHEN f_.rmtsReqState = 1 THEN
                      'Matching service record automatically found.  '

                    WHEN f_.rmtsReqState = 2 THEN
                      'The matched service record has been rejected by an administrative end user.  '

                    WHEN f_.rmtsReqState = 3 THEN
                      'An administrative end user has found a matching service record for this RMTS moment.  '

                    WHEN f_.rmtsReqState = 4 THEN
                      'The practitioner has been prompted for information regarding this RMTS moment.  '

                    WHEN f_.rmtsReqState = 5 THEN
                      'The practitioner has found a matching service record for this RMTS moment.  '

                    WHEN f_.rmtsReqState = 6 THEN
                      'A matching service record has been found, and the match has been deemed erroneous by an administrative end user.  Please correct this mistake.  '

                    ELSE
                      '' END

                 from

pre_flags f_
),

more_status_2 as (
     select *
 ,   matchingTooltipAction =

                    CASE
                                                     -- TODO: not sure if these are ever null, not worth checking
                    WHEN  f_.rmtsReqNextStep = 2 OR ( f_.hasFiles = 1 AND ISNULL(f_.isComplete, 0) = 0 AND ISNULL( f_.mustCorrectThisMistake,0 ) = 0 )  THEN
                      f_.matchingTooltip + 'Please click to confirm this moment as complete and correct.'

                    WHEN ISNULL(f_.rmtsReqNextStep, 0)= 0 THEN  -- TODO: not sure if the bit here is ever null, not worth checking
                      f_.matchingTooltip + 'No action required; you can click here to reject this automatic match as erroneous.'

                    WHEN f_.rmtsReqNextStep = 1  AND  f_.hasFiles = 1 THEN
                      f_.matchingTooltip + 'You may find a matching service record manually, upload additional supporting documentation, or prompt the practitioner for info.'

                    WHEN f_.rmtsReqNextStep = 1 THEN
                      f_.matchingTooltip + 'You may find a matching service record manually, upload supporting documentation, or prompt the practitioner for info.'

                    ELSE
                      f_.matchingTooltip + 'No action required; you can click here to reject this match as erroneous.' END

 ,   isDeferred =   CASE
                                                     -- TODO: not sure if these are ever null, not worth checking
                    WHEN  deferralDate IS NOT NULL
                      THEN 1
                    ELSE 0 END
 ,   isAwaitingCoord =
                    CASE
                                                     -- TODO: not sure if these are ever null, not worth checking
                    WHEN  deferralDate IS NULL
                          AND (
                            f_.rmtsReqNextStep = 2 OR ( f_.hasFiles = 1 AND ISNULL(f_.isComplete, 0) = 0 AND ISNULL( f_.mustCorrectThisMistake,0 ) = 0 )
                    )  THEN
                      CAST( 1 as bit )
                    ELSE
                      CAST( 0 as bit )  END

 ,   isActionRequired =

                    CASE
                                                     -- TODO: not sure if these are ever null, not worth checking
                    WHEN  deferralDate IS NULL
                          AND (  f_.rmtsReqNextStep = 2 OR ( f_.hasFiles = 1 AND ISNULL(f_.isComplete, 0) = 0 AND ISNULL( f_.mustCorrectThisMistake,0 ) = 0 )
                    ) THEN
                      CAST( 1 as bit )

                    WHEN deferralDate IS NULL
                          AND (  ISNULL(f_.rmtsReqNextStep, 0)= 0 ) THEN  -- TODO: not sure if the bit here is ever null, not worth checking
                      CAST( 0 as bit )

                    WHEN deferralDate IS NULL
                          AND (  f_.rmtsReqNextStep = 1  AND  f_.hasFiles = 1 ) THEN
                      CAST( 1 as bit )

                    WHEN deferralDate IS NULL
                          AND (  f_.rmtsReqNextStep = 1 ) THEN
                      CAST( 1 as bit )

                    ELSE
                      CAST( 0 as bit )  END

 ,   uploadedDocumentationOnly =

                    CASE
                    WHEN
                    (
                       ISNULL(f_.rmtsReqState, 0)= 0
                       OR
                       f_.rmtsReqState = 2
                       OR
                       f_.rmtsReqState = 4
                       OR
                       f_.rmtsReqState = 6
                    )
                       AND  f_.hasFiles = 1

                    THEN
                      CAST( 1 as bit )
                    ELSE
                      CAST( 0 as bit )  END

                 FROM

more_status_1 f_
) ,

more_status_3 as (
     select *  ,

     actionRequiredUnmatched =
         CASE WHEN  isActionRequired = 1
                    AND
                    (
                      f_.svcRecID  IS  NULL
                      OR
                      uploadedDocumentationOnly = 1
                        -- NOTE: not sure if svcRecID is set NULL when a matched svcrec is flagged as wrong;
                        --       uploadedDocumentationOnly is a trusted flag for the given purpose because it
                        --       checks against multiple values of rmtsReqState
                    )
              THEN
                      CAST( 1 as bit )
              ELSE
                      CAST( 0 as bit )  END  ,

     actionRequiredNoDocs =
         CASE WHEN  isActionRequired = 1
                    AND
                    hasFiles = 0
              THEN
                      CAST( 1 as bit )
              ELSE
                      CAST( 0 as bit )  END   ,


    deferralDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD ( deferralDate  )   ,
    deferralDateStr      = dbo.RPT_DATE_FMT	           ( deferralDate  )

    FROM   more_status_2 f_
),

more_status3_ujoinz as (

  SELECT   m3.*,
           ua1.userName lastModifiedByStr ,
           ua2.userName deferredByStr     ,
           ua_p.userName  pracUserName    ,
		   p_p.CONCAT_NAME  matchedPracName

  FROM   more_status_3 m3

  OUTER APPLY ( select top 1 userName = u.UserName FROM [users].dbo.Users as u WHERE u.userrid = m3.lastModifiedBy ) as ua1
  OUTER APPLY ( select top 1 userName = u.UserName FROM [users].dbo.Users as u WHERE u.userrid = m3.deferredBy     ) as ua2
  OUTER APPLY ( select top 1 userName = u.UserName FROM [users].dbo.Users as u WHERE u.userrid = m3.pracUserID     ) as ua_p

  LEFT JOIN   dbo.PRACTITIONER_Practitioner p_p  ON p_p.PRACTITIONER_ID = m3.PracID

)

  select  top (dbo.CONST_MAX_ROWS()) * from  more_status3_ujoinz

  ORDER BY
      clientName asc
	, QTR_DEFINITION desc
	, mustCorrectThisMistake DESC
	, svcrecIsAutoMatched DESC
	, isMatchedGreen desc
	, LastName asc
	, FirstName asc
	, SampledMoment asc

)


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[RPT_RMTS_MOMENTS_VIEW] TO [webuser]
GO

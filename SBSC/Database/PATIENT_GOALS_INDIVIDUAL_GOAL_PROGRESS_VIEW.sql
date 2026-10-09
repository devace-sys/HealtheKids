USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_GOALS_INDIVIDUAL_GOAL_PROGRESS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_GOALS_INDIVIDUAL_GOAL_PROGRESS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_GOALS_INDIVIDUAL_GOAL_PROGRESS_VIEW] (
    @userID               bigint
  , @userGroup            bigint
  , @userRank             bigint
  , @clientID             bigint
  , @patID                bigint
  , @groupSvcClassNameID  bigint
  , @goalID               bigint
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_GOALS_INDIVIDUAL_GOAL_PROGRESS_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN

with
cte_p1
as
(
select    
    pgp.id
  , pgp.goalID
  , sessionNumber      = ROW_NUMBER() over (order by pgp.measuredOn asc)
  , sessionDateStr     = dbo.RPT_DATE_FMT(pgp.measuredOn)
  , sessionDateTime    = pgp.measuredOn
  , sessionDateTimeStr = convert(varchar,pgp.measuredOn,0) /* Mon dd yyyy hh:mm AM/PM */
  , scoreValue         = pgp.measurementValue
  , scoreValueStr      = convert(varchar,pgp.measurementValue)
  , pgp.successfulAttempts
  , successfulAttemptsStr = iif ((pgp.successfulAttempts is null),'Not Recorded',convert(varchar,pgp.successfulAttempts))
  , pgp.totalAttempts
  , totalAttemptsStr      = iif( (pgp.totalAttempts is null),'Not Recorded',convert(varchar,pgp.totalAttempts))
  , pgp.pracID
  , pgp.measurementValue
  , pgp.sessionRatingPrac
  , pgp.sessionRatingPat
  , pgp.measurementValue2
  , pgt.inputGoalProgressUsingWhat
  , pgt.measureValueMin
  , pgt.measureValueMax
  , sessionRatingPracStr = iif( (isnull(pgp.sessionRatingPrac,0) = 0),'Not Recorded',convert(varchar,pgp.sessionRatingPrac))
  , sessionRatingPatStr  = iif( (isnull(pgp.sessionRatingPat,0)  = 0),'Not Recorded',convert(varchar,pgp.sessionRatingPat))

from dbo.PATIENT_GOALS          as pg
join dbo.PATIENT_GOALS_PROGRESS as pgp on pgp.goalID = pg.id
join dbo.PATIENT_GOAL_TYPES     as pgt on pgt.id     = pg.goalTypeID
where (
      (pg.id                  = @goalID)
  and (pg.clientID            = @clientID)
  and (pg.patID               = @patID)
  and ((@groupSvcClassNameID is null) or (pg.groupSvcClassNameID = @groupSvcClassNameID))
  and (convert(date,pgp.measuredOn) between pg.startDate and pg.endDate)
  and (pgp.active = 1)
  and (pgp.progressTrackingForWhat = 1)
)
)
,
cte_p2
as
(
select 
   p1.* 
 , sessionNumberStr = convert(varchar,p1.sessionNumber)
 , pracName         = isnull(prd.pracName,'Not Recorded')
 , pracGroup        = isnull(prd.pracGroup,'')
 , measurementTitle = case 
      when p1.inputGoalProgressUsingWhat = 1 then 'Score Recorded'
	  when p1.inputGoalProgressUsingWhat = 2 then 'Session Rating(s)'	  
   end

from cte_p1 as p1

outer apply (

  select top 1 
     pracName  = prp.CONCAT_NAME
   , pracGroup = gg.GROUP_NAME
  
  from dbo.PRACTITIONER_Practitioner as prp
  join dbo.PRACTITIONER_GROUPS       as pg on  ((pg.PRACTITIONER_ID = prp.PRACTITIONER_ID)
                                           and (pg.GROUP_TYPE in (1,2)))
  join dbo.GROUP_Group               as gg on  ((gg.GROUP_ID        = pg.GROUP_ID)
                                           and (gg.GROUP_TYPE in (1,2)))
  where 
    (prp.PRACTITIONER_ID = p1.pracID)
) as prd

)

select top (dbo.CONST_MAX_ROWS()) 
   p2.* 
 , [name] = 'Session : ' + p2.sessionNumberStr + ' ' + p2.measurementTitle 
          + ' ' 
		  + case 
		      when p2.inputGoalProgressUsingWhat = 1 then p2.scoreValueStr
		      when p2.inputGoalProgressUsingWhat = 2 then ''
			end

 , notes = 'Session Date : ' + p2.sessionDateStr  	   
         + case 
             when p2.inputGoalProgressUsingWhat = 1 then 
                 '<br>Total Attempts Recorded : '      + p2.totalAttemptsStr
	           + '<br>Successful Attempts Recorded : ' + p2.successfulAttemptsStr

	         when p2.inputGoalProgressUsingWhat = 2 then
		         '<br>Practitioner Rating : ' + p2.sessionRatingPracStr
			   + '<br>Patient Rating : '      + p2.sessionRatingPatStr			   
		   end
	     + '<br>Practitioner : ' + p2.pracName + ' ' + p2.pracGroup
from cte_p2 as p2
order by 
  p2.sessionNumber asc

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_GOALS_INDIVIDUAL_GOAL_PROGRESS_VIEW] TO [webuser]
GO  

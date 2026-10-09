USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON] (
    @clientID                bigint
  , @patID                   bigint
  , @patientGoalProgressJSON varchar(max)
) 
RETURNS table 
AS     
return              
(

 /* progressTrackingForWhat = 1 Goal
                            = 10 Objective 1
							= 20 Objective 2
							= 30 Objective 3
 */

 select 
     t1.goalID
   , totalAttempts              = isnull(t1.totalAttempts,             0)
   , successfulAttempts         = isnull(t1.successfulAttempts,        0)
   , score                      = isnull(t1.score,                     0) 
   , practitionerSessionRating  = isnull(t1.practitionerSessionRating, 0)
   , patientSessionRating       = isnull(t1.patientSessionRating,      0)
   , goalName                   = isnull(pg.name,'')
   , objective1Text             = isnull(pg.objective1Text,'')  
   , objective2Text             = isnull(pg.objective2Text,'')
   , objective3Text             = isnull(pg.objective3Text,'')
   , goalFound                  = convert(bit,(iif((pg.goalTypeID is null), 0, 1)))
   , scoreMin                   = pgt.measureValueMin
   , scoreMax                   = pgt.measureValueMax
   , goalTypeID                 = pgt.id
   , pgt.inputGoalProgressUsingWhat
   , pgt.goalHasAutoDates
   , progressTrackingForWhat	= isnull(t1.progressTrackingForWhat, 1)
   , goalOrObjectiveMet 		= nullif(trim(isnull(t1.goalOrObjectiveMet, '')), '')
   , goalOrObjectiveMetOn		= t1.goalOrObjectiveMetOn
 
 FROM OPENJSON(@patientGoalProgressJSON)
 WITH (    
	  goalID                    bigint        '$.goalID'
    , totalAttempts             int           '$.totalAttempts'
    , successfulAttempts        int           '$.successfulAttempts'
    , score                     decimal(38,4) '$.score'
	, practitionerSessionRating tinyint       '$.practitionerSessionRating'
	, patientSessionRating      tinyint       '$.patientSessionRating'
	, progressTrackingForWhat	smallint	  '$.progressTrackingForWhat' 	
	, goalOrObjectiveMet 		varchar(3)	  '$.goalOrObjectiveMet' 	
	, goalOrObjectiveMetOn		date		  '$.goalOrObjectiveMetOn' 	
) as t1

left join dbo.PATIENT_GOALS      as pg  on pg.id  = t1.goalID
left join dbo.PATIENT_GOAL_TYPES as pgt on pgt.id = pg.goalTypeID
where ( 
       (1=1)
  and ((@clientID is null) or (pg.clientID = @clientID))
  and ((@patID    is null) or (pg.patID    = @patID))
)

) 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON] TO [webuser]
GO
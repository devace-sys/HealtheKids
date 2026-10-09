USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_MANAGE_PATIENT_GOALS_PROGRESS_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_MANAGE_PATIENT_GOALS_PROGRESS_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_MANAGE_PATIENT_GOALS_PROGRESS_CORE] (
     @userGroup                  int
   , @saveType                   int
   , @validateRecord             bit
   , @fbdRecID                   bigint
   , @clientID                   bigint
   , @patID                      bigint
   , @pracID                     bigint
   , @userID                     bigint
   , @dos                        datetime
   , @startTime                  time(0)
   , @svcRecID                   bigint
   , @today                      datetime
   , @hasPatientGoalTrackingData bit
   , @patientGoalProgressJSON    varchar(max)
)
as    
begin     
    
/***************************************************************************    
 * SERVICE_RECORD_MANAGE_PATIENT_GOALS_PROGRESS_CORE */    
/**    
 *
 * NOTE: You MUST call this sproc within the context of a transaction from
 *       another sproc.  Do not use this sproc directly!
 *
 *    
 * @param   svcRecID        The record id of the service record
 ***************************************************************************/         
     
set NOCOUNT ON    

declare @progressJSON            as varchar(max) = null
declare @combinedDOSAndStartTime as datetime     = null

/*####################################################################
  # Immediate exits
  ####################################################################*/     

/* Validate */

if (@validateRecord = 1) return(0)

/* If this is a new or edit and the user is SBSC exit */

if ((@userGroup = dbo.CONST_USER_GROUP_SBS())
and ((@saveType = dbo.CONST_SAVE_TYPE_NEW()) or (@saveType = dbo.CONST_SAVE_TYPE_EDIT())))
begin
  return (0)
end

/* If this is an edit and there is no existing form builder data */

if ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) and (@fbdRecID is null))
begin
  return (0)
end

/*####################################################################
  # Delete existing form data associated with given service record
  ####################################################################*/     

/* Edits and deletes */

if ( (@saveType = dbo.CONST_SAVE_TYPE_EDIT()) or (@saveType = dbo.CONST_SAVE_TYPE_DELETE()))   
begin
  update dbo.PATIENT_GOALS_PROGRESS 
    set 
      active         = 0
    , lastModified   = @today
    , lastModifiedBy = @userID
  where ((svcRecID = @svcRecID) and (clientID = @clientID))
end

/* If this is a delete then we already got rid of the existing data and we dont need to do a
 * anything else, exit */

if (@saveType = dbo.CONST_SAVE_TYPE_DELETE()) return (0)

/*####################################################################
  # Prep incoming data
  ####################################################################*/     

/* Clean up incoming JSON */

set @progressJSON = trim(isnull(@patientGoalProgressJSON,''))
if (@progressJSON = '') set @progressJSON = '[]'

/* If there is nothing to record, exit */

if (@progressJSON = '[]') return (0)

/* Combine dos and start time into single datetime */

set @combinedDOSAndStartTime = dbo.DATE_TIME_COMBINE(@dos,@startTime)

/*####################################################################
  # Extract goal data
  ####################################################################*/     

declare @patGoals as table (
    goalID                          bigint
  , totalAttempts                   int           default(0)
  , successfulAttempts              int           default(0)
  , score                           decimal(38,4) default(0)
  , goalName                        varchar(max)
  , goalFound                       bit
  , scoreMin                        decimal(38,4)
  , scoreMax                        decimal(38,4)
  , scoreCheck                      decimal(38,4)
  , practitionerSessionRating       tinyint default(0)
  , patientSessionRating            tinyint default(0)
  , goalTypeID                      bigint 
  , inputGoalProgressUsingWhat      tinyint
  , goalHasAutoDates                bit
  , progressTrackingForWhat			smallint default(1)
  , goalOrObjectiveMet 				varchar(3)
  , goalOrObjectivemetOn			date
)

insert into @patGoals (
    goalID             
  , totalAttempts      
  , successfulAttempts 
  , score     
  , goalName  
  , goalFound 
  , scoreMin  
  , scoreMax  
  , scoreCheck
  , practitionerSessionRating
  , patientSessionRating 
  , goalTypeID 
  , inputGoalProgressUsingWhat
  , goalHasAutoDates
  , progressTrackingForWhat
  , goalOrObjectiveMet
  , goalOrObjectivemetOn
)
select 
    t1.goalID
  , t1.totalAttempts
  , t1.successfulAttempts
  , t1.score
  , t1.goalName
  , t1.goalFound
  , t1.scoreMin
  , t1.scoreMax
  , scoreCheck = t1.score
  , t1.practitionerSessionRating 
  , t1.patientSessionRating 
  , t1.goalTypeID 
  , t1.inputGoalProgressUsingWhat
  , t1.goalHasAutoDates
  , t1.progressTrackingForWhat
  , t1.goalOrObjectiveMet
  , t1.goalOrObjectivemetOn

from dbo.PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON (
    @clientID
  , @patID
  , @patientGoalProgressJSON 
) as t1

/*####################################################################
  # Handle cases where goal is not found
  ####################################################################*/     

if exists (select top 1 t1.goalID from @patGoals as t1 where (t1.goalFound = 0))
begin
  RAISERROR ('One or more patient goals could not be found.  Please check your selections.', 11, 1) 
  return(0)
end

/*####################################################################
  # Process goal data for usingWhat = 1
  ####################################################################*/     

update @patGoals
set scoreCheck = iif (
    (totalAttempts != 0)
  , round((100 * ( convert(decimal(38,4),successfulAttempts) / convert(decimal(38,4),totalAttempts) )),0)
  , score 
  )
where 
  (inputGoalProgressUsingWhat = 1)

if exists (
  select top 1
    t1.goalID 
  from @patGoals as t1 
  where (
        (t1.inputGoalProgressUsingWhat = 1)
    and ((t1.score < t1.scoreMin) or (t1.score > t1.scoreMax))
  )
)
begin
  RAISERROR ('One or more patient goals has a score that is invalid.', 11, 1) 
  return(0)
end

if exists (
  select top 1
    t1.goalID 
  from @patGoals as t1 
  where (
          (t1.inputGoalProgressUsingWhat = 1)
      and (t1.successfulAttempts > t1.totalAttempts)
  )
)
begin
  RAISERROR ('One or more patient goals has a higher value for successful attempts than total attempts', 11, 1) 
  return(0)
end

if exists (
  select top 1
    t1.goalID 
  from @patGoals as t1 
  where ( 
        (t1.inputGoalProgressUsingWhat = 1)
    and (t1.successfulAttempts < 0)
  )
)
begin
  RAISERROR ('One or more patient goals has a negative value for successful attempts', 11, 1) 
  return(0)
end

if exists (
  select top 1
    t1.goalID 
  from @patGoals as t1 
  where ( 
       (t1.inputGoalProgressUsingWhat = 1)
  and  (t1.totalAttempts < 0)
  )
)
begin
  RAISERROR ('One or more patient goals has a negative value for total attempts', 11, 1) 
  return(0)
end

if exists (
  select top 1
    t1.goalID 
  from @patGoals as t1 
  where (
        (t1.inputGoalProgressUsingWhat = 1)
    and (t1.score != t1.scoreCheck)
  )
)
begin
  RAISERROR ('One or more patient goals has a score that is inconsistant with the total and successful attempt values provided.  Please check your entries.', 11, 1) 
  return(0)
end

/*####################################################################
  # Process goal data for usingWhat = 2
  ####################################################################*/     

/* Remove cases where no session rating data entered for either prac or patient */

delete 
from @patGoals
where (
        (inputGoalProgressUsingWhat      = 2)
	and (practitionerSessionRating       = 0)	
    and (patientSessionRating            = 0)
)

/* Handle cases where practitioner session rating is non zero and out of bounds */

if exists (
  select top 1
    t1.goalID 
  from @patGoals as t1 
  where ( 
        (t1.inputGoalProgressUsingWhat = 2)
	and (t1.practitionerSessionRating != 0)
    and (convert(decimal(38,4),t1.practitionerSessionRating) not between t1.scoreMin and t1.scoreMax)
  )
)
begin
  RAISERROR ('One or more patient goals has an invalid value for practitioner session rating', 11, 1) 
  return(0)
end

/* Handle cases where patient session rating is non zero and out of bounds */

if exists (
  select top 1
    t1.goalID 
  from @patGoals as t1 
  where ( 
        (t1.inputGoalProgressUsingWhat = 2)
	and (t1.patientSessionRating != 0)
    and (convert(decimal(38,4),t1.patientSessionRating) not between t1.scoreMin and t1.scoreMax)
  )
)
begin
  RAISERROR ('One or more patient goals has an invalid value for patient session rating', 11, 1) 
  return(0)
end

/*####################################################################
  # Validate goal/objective tracking data
  ####################################################################*/

if exists (
  select top 1
    t1.goalID
  from @patGoals as t1
  where (
    t1.progressTrackingForWhat not in (1, 10, 20, 30)
  )
)
begin
  RAISERROR (
      'One or more patient goals has an invalid progress tracking selection.'
    , 11
    , 1
  )
  return (0)
end

if exists (
  select top 1
    t1.goalID
  from @patGoals as t1
  where (
        t1.goalOrObjectiveMet is not null
    and upper(trim(t1.goalOrObjectiveMet)) not in ('Y', 'N', 'YES', 'NO')
  )
)
begin
  RAISERROR (
      'One or more patient goals has an invalid goal or objective met value.'
    , 11
    , 1
  )
  return (0)
end

/* Overall Goal */

update pg
set
    pg.goalMet =
      case
        when trim(t1.goalOrObjectiveMet) in ('Y', 'YES')
          then convert(bit, 1)

        when trim(t1.goalOrObjectiveMet) in ('N', 'NO')
          then convert(bit, 0)

        else pg.goalMet
      end

  , pg.goalMetOn =
      case
        when t1.goalOrObjectiveMet is not null
          or t1.goalOrObjectiveMetOn is not null
          then t1.goalOrObjectiveMetOn

        else pg.goalMetOn
      end

  , pg.lastModified   = @today
  , pg.lastModifiedBy = @userID

from @patGoals as t1
join dbo.PATIENT_GOALS as pg
  on pg.id = t1.goalID

where (
      (t1.progressTrackingForWhat = 1)
  and (
         t1.goalOrObjectiveMet is not null
      or t1.goalOrObjectiveMetOn is not null
  )
)

/* Objective 1 */

update pg
set
    pg.objective1Met =
      case
        when upper(trim(t1.goalOrObjectiveMet)) in ('Y', 'YES')
          then convert(bit, 1)

        when upper(trim(t1.goalOrObjectiveMet)) in ('N', 'NO')
          then convert(bit, 0)

        else pg.objective1Met
      end

  , pg.objective1MetOn =
      case
        when t1.goalOrObjectiveMet is not null
          or t1.goalOrObjectiveMetOn is not null
          then t1.goalOrObjectiveMetOn

        else pg.objective1MetOn
      end

  , pg.lastModified   = @today
  , pg.lastModifiedBy = @userID

from @patGoals as t1
join dbo.PATIENT_GOALS as pg
  on pg.id = t1.goalID

where (
      (t1.progressTrackingForWhat = 10)
  and (
         t1.goalOrObjectiveMet is not null
      or t1.goalOrObjectiveMetOn is not null
  )
)

/* Objective 2 */

update pg
set
    pg.objective2Met =
      case
        when upper(trim(t1.goalOrObjectiveMet)) in ('Y', 'YES')
          then convert(bit, 1)

        when upper(trim(t1.goalOrObjectiveMet)) in ('N', 'NO')
          then convert(bit, 0)

        else pg.objective2Met
      end

  , pg.objective2MetOn =
      case
        when t1.goalOrObjectiveMet is not null
          or t1.goalOrObjectiveMetOn is not null
          then t1.goalOrObjectiveMetOn

        else pg.objective2MetOn
      end

  , pg.lastModified   = @today
  , pg.lastModifiedBy = @userID

from @patGoals as t1
join dbo.PATIENT_GOALS as pg
  on pg.id = t1.goalID

where (
      (t1.progressTrackingForWhat = 20)
  and (
         t1.goalOrObjectiveMet is not null
      or t1.goalOrObjectiveMetOn is not null
  )
)

/* Objective 3 */

update pg
set
    pg.objective3Met =
      case
        when upper(trim(t1.goalOrObjectiveMet)) in ('Y', 'YES')
          then convert(bit, 1)

        when upper(trim(t1.goalOrObjectiveMet)) in ('N', 'NO')
          then convert(bit, 0)

        else pg.objective3Met
      end

  , pg.objective3MetOn =
      case
        when t1.goalOrObjectiveMet is not null
          or t1.goalOrObjectiveMetOn is not null
          then t1.goalOrObjectiveMetOn

        else pg.objective3MetOn
      end

  , pg.lastModified   = @today
  , pg.lastModifiedBy = @userID

from @patGoals as t1
join dbo.PATIENT_GOALS as pg
  on pg.id = t1.goalID

where (
      (t1.progressTrackingForWhat = 30)
  and (
         t1.goalOrObjectiveMet is not null
      or t1.goalOrObjectiveMetOn is not null
  )
)

/*####################################################################
  # Save data
  ####################################################################*/     

insert into dbo.PATIENT_GOALS_PROGRESS ( 
    clientID
  , patID
  , pracID
  , goalID
  , totalAttempts
  , successfulAttempts
  , measuredOn
  , measurementValue
  , svcRecID
  , created
  , createdBy
  , active 
  , sessionRatingPrac
  , sessionRatingPat
  , measurementValue2
  , progressTrackingForWhat
)

/* For inputGoalProgress = 1 */

select 
    clientID           = @clientID
  , patID              = @patID
  , pracID             = @pracID
  , t1.goalID
  , t1.totalAttempts
  , t1.successfulAttempts
  , measuredOn         = @combinedDOSAndStartTime
  , measurementValue   = t1.score 
  , svcRecID           = @svcRecID
  , created            = @today
  , createdBy          = @userID
  , active             = 1
  , sessionRatingPrac  = 0
  , sessionRatingPat   = 0
  , measurementValue2  = 0
  , progressTrackingForWhat = t1.progressTrackingForWhat
 
from @patGoals as t1
where 
  (t1.inputGoalProgressUsingWhat = 1)

union

/* For inputGoalProgress = 2 */

select 
    clientID           = @clientID
  , patID              = @patID
  , pracID             = @pracID
  , t1.goalID
  , totalAttempts      = 0
  , successfulAttempts = 0
  , measuredOn         = @combinedDOSAndStartTime
  , measurementValue   = t1.practitionerSessionRating
  , svcRecID           = @svcRecID
  , created            = @today
  , createdBy          = @userID
  , active             = 1
  , sessionRatingPrac  = t1.practitionerSessionRating
  , sessionRatingPat   = t1.patientSessionRating
  , measurementValue2  = t1.patientSessionRating
  , progressTrackingForWhat = t1.progressTrackingForWhat

from @patGoals as t1
where (
  (t1.inputGoalProgressUsingWhat = 2)
)

/*####################################################################
  # Auto update start and end dates for applicable goals
  ####################################################################*/     

declare @goalsThatNeedDateChecks as table (
   goalID       bigint
 , newStartDate date
 , newEndDate   date
unique clustered (goalID)
)

insert into @goalsThatNeedDateChecks (
    goalID
  , newStartDate
  , newEndDate
)

select 
    t1.goalID
  , newStartDate = convert(date,(min(pgp.measuredOn)))
  , newEndDate   = convert(date,(max(pgp.measuredOn)))
from @patGoals                  as t1
join dbo.PATIENT_GOALS_PROGRESS as pgp on pgp.goalID = t1.goalID 
where (
      (t1.goalHasAutoDates = 1)
  and (pgp.active = 1)
)
group by 
  t1.goalID

update pg
set
    pg.startDate      = t1.newStartDate
  , pg.endDate        = t1.newEndDate
  , pg.lastModified   = @today
  , pg.lastModifiedBy = @userID
from @goalsThatNeedDateChecks   as t1
join dbo.PATIENT_GOALS          as pg on pg.id = t1.goalID

return (0)

end
go

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_MANAGE_PATIENT_GOALS_PROGRESS_CORE] TO [webuser]
GO

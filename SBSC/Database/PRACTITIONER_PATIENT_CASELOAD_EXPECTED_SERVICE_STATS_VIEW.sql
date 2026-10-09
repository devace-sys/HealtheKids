USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_STATS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_STATS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_STATS_VIEW] (
    @userID              BIGINT    
  , @userGroup           INT    
  , @userRank            INT
  , @clientID            BIGINT
  , @pracID              BIGINT    
)    

RETURNS @rec table (
    numOfExpiredSchedules int 
  , numOfPlanUpdates      int
  , numOfPossibleNewPlans int
)

BEGIN

 /***************************************************************************    
  * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_STATS_VIEW */    
 /**    
  * Returns stats (counts) on expired schedules, plan updates
  * and possible plan updates. 
  ***************************************************************************/     

declare @pnes as table (
    patID    bigint
  , selected bit 
)

declare @numOfExpiredSchedules as int = 0
declare @numOfPlanUpdates      as int = 0
declare @numOfPossibleNewPlans as int = 0

select 
  @numOfExpiredSchedules = count (vc.id)
from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_CORE(@clientID,@pracID,null,null) as vc
where 
  (vc.schedulesExpired = 1)
OPTION (RECOMPILE)

insert into @pnes (
    patID
  , selected
)
select 
    vc.patID
  , vc.selected
from dbo.PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_VIEW_CORE (
    @userID
  , @userGroup
  , @userRank 
  , @clientID 
  , @pracID   
  , '' 
  , 1) as vc
OPTION (RECOMPILE)

select @numOfPlanUpdates      = count(patID) from @pnes as t1 where (t1.selected = 1) OPTION (RECOMPILE)
select @numOfPossibleNewPlans = count(patID) from @pnes as t1 where (t1.selected = 0) OPTION (RECOMPILE)

insert into @rec (
    numOfExpiredSchedules
  , numOfPlanUpdates
  , numOfPossibleNewPlans)
values (
    @numOfExpiredSchedules
  , @numOfPlanUpdates
  , @numOfPossibleNewPlans)

return

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_STATS_VIEW] TO [webuser]
GO

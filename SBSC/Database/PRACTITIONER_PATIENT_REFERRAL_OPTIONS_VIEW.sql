USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS ( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
DROP FUNCTION dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_REFERRAL_OPTIONS_VIEW] (
      @userID              BIGINT
    , @userGroup           INT
    , @userRank            INT
    , @clientID            BIGINT
    , @active              BIT
) 
RETURNS TABLE

/***************************************************************************
 * PRACTITIONER_PATIENT_REFERRAL_OPTIONS_VIEW */
/**
 ***************************************************************************/
AS RETURN
(
	select top 1
	 
		t1.* 
	 
	  , personNameForAllRoutineNotifications1 = isnull(uaRoutine1.[name],N'')
	  , personNameForAllRoutineNotifications2 = isnull(uaRoutine2.[name],N'')
	  , personNameForAllRoutineNotifications3 = isnull(uaRoutine3.[name],N'')
	  , personNameForAllUrgentNotifications1 = isnull(uaUrgent1.[name],N'')
	  , personNameForAllUrgentNotifications2 = isnull(uaUrgent2.[name],N'')
	  , personNameForAllUrgentNotifications3 = isnull(uaUrgent3.[name],N'')
	  , personNameForAllCrisisNotifications1 = isnull(uaCrisis1.[name],N'')
	  , personNameForAllCrisisNotifications2 = isnull(uaCrisis2.[name],N'')
	  , personNameForAllCrisisNotifications3 = isnull(uaCrisis3.[name],N'')
	 
	from dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS as t1
	 
	left join users.dbo.USERS_ALL as uaRoutine1 on uaRoutine1.id = t1.userIDForAllRoutineNotifications1
	left join users.dbo.USERS_ALL as uaRoutine2 on uaRoutine2.id = t1.userIDForAllRoutineNotifications2
	left join users.dbo.USERS_ALL as uaRoutine3 on uaRoutine3.id = t1.userIDForAllRoutineNotifications3
	left join users.dbo.USERS_ALL as uaUrgent1 on uaUrgent1.id = t1.userIDForAllUrgentNotifications1
	left join users.dbo.USERS_ALL as uaUrgent2 on uaUrgent2.id = t1.userIDForAllUrgentNotifications2
	left join users.dbo.USERS_ALL as uaUrgent3 on uaUrgent3.id = t1.userIDForAllUrgentNotifications3
	left join users.dbo.USERS_ALL as uaCrisis1 on uaCrisis1.id = t1.userIDForAllCrisisNotifications1
	left join users.dbo.USERS_ALL as uaCrisis2 on uaCrisis2.id = t1.userIDForAllCrisisNotifications2
	left join users.dbo.USERS_ALL as uaCrisis3 on uaCrisis3.id = t1.userIDForAllCrisisNotifications3
	 
	where (t1.clientID = @clientID)
)
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[PRACTITIONER_PATIENT_REFERRAL_OPTIONS_VIEW] TO [webuser]
GO

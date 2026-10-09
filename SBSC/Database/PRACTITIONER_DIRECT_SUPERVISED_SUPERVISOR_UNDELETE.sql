USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_UNDELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_UNDELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_UNDELETE] (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @clientID      INT  
  , @recID         INT
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_UNDELETE */    
/**    
 * unDelete record and manages any associated records.    
 *    
 * @param   userID          The userid of who saved the record    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT deleting the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng Patient to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message for edit/delete service record    
 *                          operations when record is not found    
 * @param   MsgNoEdit       Desired error message for edit/delete service record    
 *                          operations if the service record cannot be edited or    
 *                          deleted    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @TranOpen     AS BIT    
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    
   
declare @onlyDeptHeadsCanManageDirectSupAssigments                       as bit = 0
declare @deptHeadsCanOnlyManageDirectSupAssignmentsInTheirReportingGroup as bit = 0
declare @groupSvcClassNameID                                             as bigint = null
declare @supervisedPracID                                                as bigint = null
declare @supervisingPracID                                               as bigint = null
declare @supervisedPracReptGroupID                                       as bigint = null
declare @supervisingPracReptGroupID                                      as bigint = null

declare @userRoleID                  as bigint   = null
declare @userClientID                as int      = null
declare @userPracID                  as int      = null
declare @userPracDispGroupID         as int      = null
declare @userPracReptGroupID         as int      = null
declare @userPracGroupSvcClassNameID as bigint   = null
declare @userPracIsDeptHead          as bit      = null

/*============================================================
 * Init output parms
 *============================================================*/  

SET @recordID   = 0    
SET @spDetails  = ''    


BEGIN TRY    
   
/*============================================================
 * Init vars 
 *============================================================*/  
      
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @today      = GETDATE()    
   
/*============================================================
 * Verify required parms
 *============================================================*/  
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)    
   
/*============================================================
 * Lookup record
 *============================================================*/  

select top 1
    @groupSvcClassNameID = t1.groupServiceClassNameID    
  , @supervisedPracID    = t1.SUPERVISED_PRAC_ID
  , @supervisingPracID   = t1.SUPERVISING_PRAC_ID
  , @recordID            = t1.ID
from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as t1
where (
      ([id] = @recID)   
  and ((@clientID is null) or (t1.CLIENT_ID = @clientID))
)

/*============================================================
 * No record, silent exit
 *============================================================*/  

if (@recordID is null) 
begin
  set @recordID = 0
  return(0)
end

/*============================================================
 * Get reporting group for the supervised prac
 *============================================================*/  

 select top 1 
   @supervisedPracReptGroupID = gg.GROUP_ID
 from dbo.PRACTITIONER_GROUPS as pg
 join dbo.GROUP_Group         as gg on gg.GROUP_ID = pg.GROUP_ID 
 where (
     (pg.PRACTITIONER_ID = @supervisedPracID)
 and (pg.ACTIVE = 1)
 and (pg.GROUP_TYPE in (3,5))
 and (gg.ACTIVE = 1)
 )

/*============================================================
 * Get reporting group for the supervising prac
 *============================================================*/  

 select top 1 
   @supervisingPracReptGroupID = gg.GROUP_ID
 from dbo.PRACTITIONER_GROUPS as pg
 join dbo.GROUP_Group         as gg on gg.GROUP_ID = pg.GROUP_ID 
 where (
     (pg.PRACTITIONER_ID = @supervisingPracID)
 and (pg.ACTIVE = 1)
 and (pg.GROUP_TYPE in (3,5))
 and (gg.ACTIVE = 1)
 )

/*============================================================
 * Lookup practice family rules for this practice family
 * and client
 *============================================================*/  
  
select top 1 
      @onlyDeptHeadsCanManageDirectSupAssigments                       = isnull(spr.onlyDepartmentHeadsCanManageDirectSupervisionAssignments,0)
    , @deptHeadsCanOnlyManageDirectSupAssignmentsInTheirReportingGroup = isnull(spr.departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup,0)
from dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES as spr
where ( 
      (spr.clientID                = @clientID)
  and (spr.groupServiceClassNameID = @groupSvcClassNameID)
)

/*============================================================
 * Lookup user data on calling user
 *============================================================*/  

select 

    @userRoleID      = ua.roleID
  , @userClientID    = ua.clientID
  , @userPracID      = ua.pracID
  , @userPracGroupSvcClassNameID = ua.pracGroupSvcClassNameID
  , @userPracReptGroupID         = ua.pracReptGroupID
  , @userPracDispGroupID         = ua.pracDispGroupID
  , @userPracIsDeptHead          = ua.pracIsDeptHead

from users.dbo.USERS_ALL as ua
where 
  (ua.id = @userID)

/*============================================================
 * If calling user is a practitioner then we need to perform
 * some additional checks
 *============================================================*/  

if (@userRoleID = 7)
begin

  declare @groupsThatPracCanSupDirCount                                    as int = 0
  
  /* General rules.  If the user is a prac they have to be qualified to supervise
   * Note: Keep in synch with isPracSomeoneWhoCanManageDirectSupervisionTracking logic in 
   * PRAC_REC_VIEW.sql
  */

  select 
    @groupsThatPracCanSupDirCount = isnull(COUNT(ggdss1.id),0) 
  from [dbo].[GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR] as ggdss1
  where 
    (ggdss1.SUPERVISING_GROUP_ID = @userPracDispGroupID)
  
  if (@groupsThatPracCanSupDirCount = 0)
  begin
    RAISERROR ('You must be a qualified supervising practitioner to manage this relationship', 11, 1)  
  end
  
  /* General rules.  If the user is a prac they have to be in same group family */

  if (@userPracGroupSvcClassNameID != @groupSvcClassNameID)  
    RAISERROR ('You must be in the same practice family as the supervised and supervising practitioner to manage this relationship', 11, 1)  
  
  /* Practice family rule - Department head only management of direct sup assignments */

  if ((@onlyDeptHeadsCanManageDirectSupAssigments = 1) and (@userPracIsDeptHead = 0))
  begin
    RAISERROR ('You must be a department head to manage this relationship', 11, 1)  
  end
  
  if ((@onlyDeptHeadsCanManageDirectSupAssigments = 1) and (@userPracIsDeptHead = 1))
  begin
    
	/* Practice family rule.  Dept heads limited to assignments in their reporting group */

	if (@deptHeadsCanOnlyManageDirectSupAssignmentsInTheirReportingGroup = 1)
	begin
	  if (@userPracReptGroupID != @supervisedPracReptGroupID)  RAISERROR ('You must be in the same reporting group as the supervised practitioner to manage this relationship', 11, 1)  
	  if (@userPracReptGroupID != @supervisingPracReptGroupID) RAISERROR ('You must be in the same reporting group as the supervising practitioner to manage this relationship', 11, 1)  
	end
	
  end
end

/*============================================================
 * If we are just validating go ahead and exit
 *============================================================*/  
     
IF (@validateRec = 1) RETURN(0)    
   
/*============================================================
 * Otherwise update data
 *============================================================*/  
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  SET @updateState = dbo.CONST_SVC_REC_STATE_DEL()    
  set @recordID = @recID
  
  update dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR
  set 
      ACTIVE           = 1
    , LAST_MODIFIED_ON = getdate()
    , LAST_MODIFIED_BY = @userID
    
  where (
        ([id] = @recID)   
    and ((@clientID is null) or (CLIENT_ID = @clientID))
  )
  
/*============================================================
 * We reach this point all is good.  Commit and exit
 *============================================================*/  
     
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY    
   
BEGIN CATCH    
   
/*============================================================
 * We end up here something went wrong.  Rollback if needed
 * and exit, returning any error messages to the caller
 *============================================================*/  
   
  -- Error or raise error with severity 11 to 19 will be caught here    
   
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
   
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  SET @ErrorMessage = @ErrorMessage
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_UNDELETE] TO [webuser]
GO

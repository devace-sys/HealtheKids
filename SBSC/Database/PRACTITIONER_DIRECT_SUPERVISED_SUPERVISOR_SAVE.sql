USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_SAVE] (
    @userID                BIGINT
  , @userGroup             INT
  , @userRank              INT
  , @clientID              BIGINT
  , @supervisingPracID     BIGINT
  , @supervisedPracID      BIGINT
  , @startDate             DATETIME
  , @endDate               DATETIME
  , @shareNotes            BIT
  , @relationshipTypeID    TINYINT
  , @requireSvcRecApprovalForNonProgCompRels BIT
  , @editDelReason         VARCHAR(7000)
  , @validateRec           BIT
  , @saveType              INT
  , @recID                 BIGINT
  , @MsgNoRec              VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
  , @MsgDupRec             VARCHAR(1000)
  , @MsgDataError          VARCHAR(1000)
  , @MsgNotActive          VARCHAR(1000)
  , @recordID              BIGINT        OUTPUT
  , @spDetails             VARCHAR(8000) OUTPUT )
AS    
BEGIN     
    
/***************************************************************************    
 * PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_SAVE */    
/**    
 * Creates new or edits existing
 *    
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/  

declare @tranOpen      as bit       -- Is a transaction open  
declare @today         as datetime
declare @todayDateOnly as datetime

declare @validSupervisedPracID        as bigint = null
declare @validSupervisingPracID       as bigint = null

declare @supervisedPracDispGroupID    as bigint = null
declare @supervisedPracReptGroupID    as bigint = null
declare @supervisedPracGroupSvcNameID as bigint = null

declare @supervisingPracDispGroupID    as bigint = null
declare @supervisingPracReptGroupID    as bigint = null
declare @supervisingPracGroupSvcNameID as bigint = null

declare @supervisingAndSupervisedPracsMustBeInSameReportingGroup         as bit = 0
declare @onlyDeptHeadsCanManageDirectSupAssigments                       as bit = 0
declare @deptHeadsCanOnlyManageDirectSupAssignmentsInTheirReportingGroup as bit = 0

declare @userRoleID                  as bigint   = null
declare @userClientID                as int      = null
declare @userPracID                  as int      = null
declare @userPracDispGroupID         as int      = null
declare @userPracReptGroupID         as int      = null
declare @userPracGroupSvcClassNameID as bigint   = null
declare @userPracIsDeptHead          as bit      = null

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID      = 0    
SET @spDetails     = ''    
SET @today         = GETDATE()    
SET @tranOpen      = 0
set @todayDateOnly = convert(date,@today)

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup          IS NULL) RAISERROR ('userGroup is required',           11, 1)  
IF (@userID             IS NULL) RAISERROR ('user id is required',             11, 1)    
IF (@userRank           IS NULL) RAISERROR ('userRank is required',            11, 1)    
IF (@validateRec        IS NULL) RAISERROR ('Validate flag required',          11, 1)    
IF (@saveType           is null) RAISERROR ('Save type is required',           11, 1)    
if (@clientID           is null) RAISERROR ('Client ID is required',           11, 1)
if (@supervisedPracID   is null) RAISERROR ('Supervised prac id is required',  11, 1)  
if (@supervisingPracID  is null) RAISERROR ('Supervising prac id is required', 11, 1)  
if (@relationshipTypeID is null) RAISERROR ('Supervision relationship type is required', 11, 1)  

/*============================================================
 * If this is a relationship type other than program compliance
 *============================================================*/  

if (@relationshipTypeID in (20,30))
begin

  /*============================================================
   * Start date is required
   *============================================================*/  

  if (@startDate is null) RAISERROR ('Start date is required', 11, 1)  

end

/*============================================================
 * Make sure client is valid
 *============================================================*/  

if not exists (
  select top 1 clc.CLIENT_ID from dbo.CLIENTS_Client as clc
  where (clc.CLIENT_ID = @clientID)
)
begin
  RAISERROR ('Invalid client id', 11, 1)  
end

/*============================================================
 * If this is an edit check if record exists
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  
  if (@recID is null) RAISERROR ('Record id is required', 11, 1)      
  
  set @recordID = 0

  select top 1 
    @recordID = ppdss.id 
  from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss
  where 
      (ppdss.ID        = @recID)
  and (ppdss.CLIENT_ID = @clientID)
  and (ppdss.ACTIVE    = 1)
  
  if (@recordID = 0)
  begin
    RAISERROR ('Record not found', 11, 1)      
  end

end
else
begin  
  set @recordID = 0
end

/*============================================================
 * Make sure supervised practitioner is valid
 * and get their discipline group id 
 *============================================================*/  
 
select top 1 
    @validSupervisedPracID     = prp.PRACTITIONER_ID
  , @supervisedPracDispGroupID = pg.GROUP_ID
from.PRACTITIONER_Client           as prc                                         
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.PRACTITIONER_GROUPS       as pg  on pg.PRACTITIONER_ID  = prp.PRACTITIONER_ID  

where (
        (prc.CLIENT_ID       = @clientID) 
    and (prc.PRACTITIONER_ID = @supervisedPracID) 
    and (prp.PRACTITIONER_ID = @supervisedPracID)
	and (pg.GROUP_TYPE in (1,2))
)

if (@validSupervisedPracID is null)
begin
  RAISERROR ('Invalid supervised practitioner id', 11, 1)  
end

/*============================================================
 * Make sure supervising practitioner is valid
 * and get their discipline group id 
 *============================================================*/  
 
select top 1 
    @validSupervisingPracID     = prp.PRACTITIONER_ID
  , @supervisingPracDispGroupID = pg.GROUP_ID
from.PRACTITIONER_Client           as prc                                         
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.PRACTITIONER_GROUPS       as pg  on pg.PRACTITIONER_ID  = prp.PRACTITIONER_ID  
where (
        (prc.CLIENT_ID       = @clientID) 
    and (prc.PRACTITIONER_ID = @supervisingPracID) 
    and (prp.PRACTITIONER_ID = @supervisingPracID)
	and (pg.GROUP_TYPE in (1,2))
)

if (@validSupervisingPracID is null)
begin
  RAISERROR ('Invalid supervising practitioner id', 11, 1)  
end

/*============================================================
 * Get group family for the supervised prac
 *============================================================*/  

select top 1
  @supervisedPracGroupSvcNameID = png.GROUP_SERVICE_CLASS_NAME_ID
from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png
where (
      (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
  and (png.GROUP_ID = @supervisedPracDispGroupID)
)

/*============================================================
 * Get group family for the supervising prac
 *============================================================*/  

select top 1
  @supervisingPracGroupSvcNameID = png.GROUP_SERVICE_CLASS_NAME_ID
from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png
where (
      (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
  and (png.GROUP_ID = @supervisingPracDispGroupID)
)

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
 * Verify that supervising and supervised are in the same
 * group family.  If not get out.
 *============================================================*/  

if (@supervisedPracGroupSvcNameID != @supervisingPracGroupSvcNameID)
begin
    RAISERROR ('Both supervising and supervised practitioners must be in the same practice family', 11, 1)  
end

/*============================================================
 * Lookup practice family rules for this practice family
 * and client
 *============================================================*/  
  
select top 1 
    @onlyDeptHeadsCanManageDirectSupAssigments                       = isnull(spr.onlyDepartmentHeadsCanManageDirectSupervisionAssignments,0)   , @deptHeadsCanOnlyManageDirectSupAssignmentsInTheirReportingGroup = isnull(spr.departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup,0)
  , @supervisingAndSupervisedPracsMustBeInSameReportingGroup         = isnull(spr.supervisingAndSupervisedPracsMustBeInSameReportingGroup,0)
from dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES as spr
where ( 
      (spr.clientID                = @clientID)
  and (spr.groupServiceClassNameID = @supervisingPracGroupSvcNameID)
)
 
/*============================================================
 * Based on practice family rules for this client 
 * enforce the same reporting group rule
 *============================================================*/  

if (@supervisingAndSupervisedPracsMustBeInSameReportingGroup = 1)
begin
    if (@supervisingPracReptGroupID != @supervisedPracReptGroupID)  
    begin
      RAISERROR ('Both supervising and supervised practitioners must be in the same reporting group', 11, 1)  
    end
end

/*============================================================
 * If this is a program compliance relationship
 *============================================================*/  

if (@relationshipTypeID = 10)
begin

  /*============================================================
   * Verify that supervising practitioner is qualified to 
   * supervise the supervised practitioner
   *============================================================*/  

  if not exists (

      select top 1 
	    pg.PRACTITIONER_GROUP 
      from dbo.PRACTITIONER_GROUPS                               as pg
	  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on png.GROUP_ID = pg.GROUP_ID
	 
	  cross apply (
	    select top 1 
	      canSupervise = 1 
	    from dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR as ggdss1
	    where (
	          (ggdss1.SUPERVISED_GROUP_ID = @supervisedPracDispGroupID)
	      and (ggdss1.SUPERVISING_GROUP_ID = png.GROUP_ID))
	  ) as ggdss2  
	
	  where (
	         (pg.PRACTITIONER_ID = @supervisingPracID)
	     and (pg.GROUP_TYPE in (1,2))
	     and (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
	     and (ggdss2.canSupervise = 1)
	  )
  )
  begin
    RAISERROR ('Based on our data for billing program supervision rules the supervising practitioner is not permitted to supervise the supervised practitioner', 11, 1)  
  end

end /* Program supervision */

/*============================================================
 * If this is a cybhi clinical sup/orp relationship
 *============================================================*/  

else if (@relationshipTypeID = 20)
begin

  /*============================================================
    * Verify that supervising practitioner is qualified to 
    * supervise the supervised practitioner.
    *============================================================*/  

  if @supervisingPracDispGroupID not in (
    select 
      t1.GROUP_ID 
    from dbo.CYBHI_TRANSMISSION_GENERATION_VIEW_LICENSED_PRAC_GROUPS() as t1
    where 
      (t1.GROUP_ID = @supervisingPracDispGroupID)
  )
  begin
    RAISERROR ('Based on our data for CYBHI ORP requirements the supervising practitioner must be a licensed practitioner that is approved by the CYBHI program.', 11, 1)  
  end
end
 
/*============================================================
 * Lookup user data on calling user
 *============================================================*/  

select 
    @userRoleID                  = ua.roleID
  , @userClientID                = ua.clientID
  , @userPracID                  = ua.pracID
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

  declare @groupsThatPracCanSupDirCount as int = 0
  
  /* General rules.  If the user is a prac they have to be qualified to supervise
   * Note: Keep in synch with isPracSomeoneWhoCanManageDirectSupervisionTracking logic in 
   * PRAC_REC_VIEW.sql
  */

  select 
    @groupsThatPracCanSupDirCount = isnull(COUNT(ggdss1.id),0) 
  from [dbo].[GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR] as ggdss1
  where 
    (ggdss1.SUPERVISING_GROUP_ID = @userPracDispGroupID)
  
  /* General rules.  If the user is a prac they have to be in same group family */

  if (@userPracGroupSvcClassNameID != @supervisedPracGroupSvcNameID)  
    RAISERROR ('You must be in the same practice family as the supervised practitioner to manage this relationship', 11, 1)  
  
  if (@userPracGroupSvcClassNameID != @supervisingPracGroupSvcNameID) 
    RAISERROR ('You must be in the same practice family as the supervising practitioner to manage this relationship', 11, 1)  
  
  /*============================================================
   * For program compliance supervision relationships
   *============================================================*/  

  if (@relationshipTypeID = 10)
  begin  
    if (@groupsThatPracCanSupDirCount = 0)
    begin
      RAISERROR ('You must be a qualified supervising practitioner to manage this relationship', 11, 1)  
    end
  end
  
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
	
  end /* Dept head rule */
end /* User is a prac */

/*============================================================
 * Overlap check for program compliance relationships
 *============================================================*/  

if (@relationshipTypeID = 10)
begin
  if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
  begin
    if (dbo.IS_PRAC_SUPERVISED_BY_PRAC(@supervisedPracID, @supervisingPracID, @startDate) = 1) RAISERROR ('A supervision record covering this date already exists', 11, 1)
  end
end
 
/*============================================================
 * Overlap check for other relationships
 *============================================================*/  

if (@relationshipTypeID in (20,30))
begin

  if exists (
    select top 1
      ppdss.id
    from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss
    where (
            /* Uses index: [ACTIVE_SUPERVISED_START_END_IDX] */
            (ppdss.ACTIVE             = 1) 
        and (ppdss.SUPERVISED_PRAC_ID = @supervisedPracID)
        and (isnull(ppdss.START_DATE, @todayDateOnly) between isnull (@startDate,@todayDateOnly) and isnull (@endDate,@todayDateOnly))
	    and (isnull(ppdss.END_DATE,   @todayDateOnly) between isnull (@startDate,@todayDateOnly) and isnull (@endDate,@todayDateOnly)) 		
        and (ppdss.SUPERVISING_PRAC_ID > 0)
        and ((@recID is null) or (ppdss.id != isnull(@recID,0))) /* For edits excludes edited record */
        and (ppdss.SHARE_NOTES         = 0)
        and (ppdss.relationshipTypeID  = @relationshipTypeID)		  
     )
     order by 
	    ppdss.id desc /* Get most recently added */
    )
  begin
	  RAISERROR ('A supervision record of this type covering this date already exists', 11, 1)
  end

end

/*============================================================
 * Validation Only Exit
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  RETURN(0)    
END        

/*============================================================
 * Save data
 *============================================================*/  

BEGIN TRANSACTION

SET @tranOpen = 1

/*============================================================
 * Create new supervision tracking record
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  insert into dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR (
	  CLIENT_ID
	, SUPERVISING_PRAC_ID
	, SUPERVISED_PRAC_ID
	, START_DATE
	, END_DATE
	, CREATED_ON
	, CREATED_BY
	, ACTIVE
	, SHARE_NOTES
	, groupServiceClassNameID
	, relationshipTypeID
	, requireSvcRecApprovalForNonProgCompRels
  )  
  values (
     @clientID
   , @supervisingPracID
   , @supervisedPracID
   , @startDate
   , @endDate
   , @today
   , @userID
   , 1
   , 0 /*@shareNotes*/
   , @supervisedPracGroupSvcNameID
   , @relationshipTypeID
   , @requireSvcRecApprovalForNonProgCompRels
   )

  set @recordID = SCOPE_IDENTITY()
 
end

/*============================================================
 * Update existing 
 * Note: @relationshipTypeID cannot be changed
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
     
   update dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR
   set
       SUPERVISING_PRAC_ID      = @supervisingPracID
	 , SUPERVISED_PRAC_ID       = @supervisedPracID
	 , START_DATE               = @startDate
	 , END_DATE                 = @endDate
     , LAST_MODIFIED_ON         = @today  
     , LAST_MODIFIED_BY         = @userID
	 , groupServiceClassNameID  = @supervisedPracGroupSvcNameID	 
	 , requireSvcRecApprovalForNonProgCompRels = @requireSvcRecApprovalForNonProgCompRels
   where (
      (ID = @recordID)   
   )
end
else
begin
   RAISERROR ('Unsupported save type', 11, 1)  
end

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @tranOpen = 0    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_SAVE] TO [webuser]
GO

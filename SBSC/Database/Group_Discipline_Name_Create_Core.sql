USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Group_Discipline_Name_Create_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Group_Discipline_Name_Create_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Group_Discipline_Name_Create_Core] (
    @userID                   bigint
  , @groupName                nvarchar(max) = null
  , @groupNameAbbreviation    nvarchar(max) = null
  , @groupBase                nvarchar(max) = null
  , @parentGroupID            bigint  /* from groups type 5 */
  , @groupServiceClassNameID  bigint  /* from group service class names*/
  , @groupID                  bigint  output
)  
AS    
BEGIN    
   
/***************************************************************************    
 * Group_Discipline_Name_Create_Core */    
/**    
 ***************************************************************************/        
     
SET NOCOUNT ON    

declare @active                 as bit = 0
declare @appManPageUserRoleName as varchar(512) = ''
declare @groupServiceClassName  as varchar(256) = ''

declare @pngAssociations as table (
    GROUP_SERVICE_CLASS_PARTITION_ID bigint
  , GROUP_SERVICE_CLASS_NAME_ID      bigint
  , GROUP_ID                         bigint
  , ROW_EXISTS                       bit default (0)
)

BEGIN TRY    

/*-------------------------------    
 * Clean up incoming parms    
 *------------------------------*/    

set @userID                  = isnull(@userID,0)
set @groupName               = trim(isnull(@groupName,N''))
set @groupNameAbbreviation   = trim(isnull(@groupNameAbbreviation,N''))
set @groupBase               = trim(isnull(@groupBase,N''))
set @groupServiceClassNameID = isnull(@groupServiceClassNameID, 0)
set @parentGroupID           = isnull(@parentGroupID,           0)

/*-------------------------------    
 * Init output parms
 *------------------------------*/    

set @groupID = 0

/*-------------------------------    
 * If required parms not provided
 * get out
 *------------------------------*/    

if (@userID                  <= 0)    RAISERROR ('User id is required',                      11, 1)  
if (@groupName               =  N'')  RAISERROR ('Group name is required',                   11, 1)  
if (@groupNameAbbreviation   =  N'')  RAISERROR ('Group name abbrevation is required',       11, 1)  
if (@groupBase               =  N'')  RAISERROR ('Group base is required',                   11, 1)  
if (@groupServiceClassNameID <= 0)    RAISERROR ('Group service class name id is required',  11, 1)  
if (@parentGroupID           <= 0)    RAISERROR ('Parent group id is required',              11, 1)  

/*-------------------------------    
 * If related ids do not exist
 * get out
 *------------------------------*/    

/* If parent group ID does not exist, exit*/

if not exists (select top 1 t1.PARENT_GROUP_ID from dbo.GROUP_Group as t1 where ((t1.GROUP_ID = @parentGroupID) and (t1.GROUP_TYPE = 5) and (t1.ACTIVE = 1)))
begin
  RAISERROR ('Parent group id not found', 11, 1)  
end

/* If group service class name ID does not exist, exit*/

if not exists (select top 1 t1.* from dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as t1 where (t1.GROUP_SERVICE_CLASS_NAME_ID = @groupServiceClassNameID))
begin
  RAISERROR ('Service class name id', 11, 1)  
end

/*-------------------------------    
 * Check if group exists
 *------------------------------*/    

select top 1 
    @groupID = isnull(gg.GROUP_ID,0)
  , @active  = isnull(gg.active,0)
from dbo.GROUP_Group as gg
where 
  (trim(gg.GROUP_NAME) = @groupName)

/*-------------------------------    
 * If it does not exist add it
 *------------------------------*/    

if (@groupID = 0)
begin
  insert into dbo.GROUP_Group (
      GROUP_NAME
    , GROUP_TYPE
    , ACTIVE
    , CLIENT_ID
    , PARENT_GROUP_ID
    , GROUP_NAME_ABBREVIATION
    , GROUP_BASE 
  )
  values (
      @groupName
    , 1               /* group type*/
    , 1               /* active */
    , null            /* client id */
    , @parentGroupID
    , @groupNameAbbreviation
    , @groupBase
  )

  set @groupID = SCOPE_IDENTITY()
end


/*-------------------------------    
 * If it does exist 
 *------------------------------*/    

else
begin
  
  /* If it does exist but its inactive, exit with message to check data */

  if (@active = 0)
  begin
    RAISERROR ('Group exists but is inactive.  Check data.', 11, 1)  
  end

  /* Otherwise exit */

  return(0)

end


/*-------------------------------    
 * Setup group name partitions
 * and service name id 
 * associations
 *------------------------------*/    

insert into @pngAssociations (
    GROUP_SERVICE_CLASS_PARTITION_ID
  , GROUP_SERVICE_CLASS_NAME_ID
  , GROUP_ID 
  , ROW_EXISTS
)
values  
  (1,   @groupServiceClassNameID, @groupID, 0)
, (3,   @groupServiceClassNameID, @groupID, 0)
, (4,   @groupServiceClassNameID, @groupID, 0)
, (5,   @groupServiceClassNameID, @groupID, 0)  
, (100, @groupServiceClassNameID, @groupID, 0)  /* Standard */

/* Find existing basic associations with this group id (if any) */

update t1
  set t1.ROW_EXISTS = 1
from @pngAssociations as t1
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on  ((png.GROUP_SERVICE_CLASS_PARTITION_ID = t1.GROUP_SERVICE_CLASS_PARTITION_ID)
                                                                  and (png.GROUP_SERVICE_CLASS_NAME_ID = t1.GROUP_SERVICE_CLASS_NAME_ID)
                                                                  and (png.GROUP_ID = t1.GROUP_ID))

/* Add any that dont exists already */

insert into dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS (
    GROUP_SERVICE_CLASS_PARTITION_ID
  , GROUP_SERVICE_CLASS_NAME_ID
  , GROUP_ID
)
select 
    t1.GROUP_SERVICE_CLASS_PARTITION_ID
  , t1.GROUP_SERVICE_CLASS_NAME_ID
  , t1.GROUP_ID
from @pngAssociations as t1

/* Get group service class name (needed for man page data) */

select top 1 
  @groupServiceClassName = t1.GROUP_SERVICE_CLASS_NAME
from dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as t1
where 
  (t1.GROUP_SERVICE_CLASS_NAME_ID = @groupServiceClassNameID)

/*-------------------------------    
 * Setup help/announcement
 * and newsletter data
 *------------------------------*/    

/* Create man page role name selection value */

set @appManPageUserRoleName  = 'Client Users - Provider -- ' 
                             + @groupServiceClassName 
							 + ' --- ' 
							 + convert(varchar(256), @groupName)

/* If it does not exist already, add it */

if not exists (select id from [users].[dbo].AppManPagesUserRoles as t1 
  where (
        (t1.appName         = 'spedcare')
    and (t1.roleUserGroupID = 1)
    and (t1.roleUserRoleID  = 7)
    and (t1.appEntID1       = 3)
    and (t1.appEntID2       = @groupServiceClassNameID)
    and (t1.appEntID3       = @groupID)
  )
)
begin

  insert into [users].[dbo].AppManPagesUserRoles (
        [appName]
      , [displayOrder]
      , [name]
      , [roleUserGroupID]
      , [roleUserRoleID]
      , [roleUserRoleUID]
      , [roleUserRank]
      , [appEntID1]
      , [appEntID2]
      , [appEntID3]
      , [appEntID4]
      , [isPreviouslyDerivedRoleID]
      , [created]
      , [createdBy]
      , [active]
  )
  values (
     'spedcare' /*app name */
	, 5         /* Display order*/
	, @appManPageUserRoleName
	, 1 /*roleUerGroupID  (client)*/ 
	, 7 /*roleUserRoleID (practitioner) */
	,'75AEDF15-EC30-435B-8DE5-9BFF8A812418' /*roleUserRoleUID (practitioner) */
	, 1     /*roleUserRank (practitioner)*/
	, 3     /*appEntID1 (partition)*/
	, @groupServiceClassNameID     /*appEntID2 (svc class name id)*/
	, @groupID   /*appEntID3 (groupID)*/
	, null /*appEntID4 */
	, 0    /* isPreviouslyDerivedRoleID*/
    , getdate()
	, @userID
	, 1
  )
end

/*-------------------------------    
 * If we reach this point    
 * everything is OK, exit   
 *------------------------------*/    
   
RETURN(0)    
END TRY 
BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
          
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 

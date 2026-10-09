USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE_CORE](
    @userID               BIGINT    
  , @userGroup            INT  
  , @userRank             INT 
  , @selectionID          varchar(8000)
  , @authorized           BIT
  , @editDelReason        VARCHAR(7000)
  , @recordID             BIGINT        OUTPUT
  , @spDetails            VARCHAR(8000) OUTPUT
  , @saveType             INT           OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE_CORE */    
/**    
 * 
 ***************************************************************************/        

/*============================================================
 * Variables and init
 *============================================================*/  

declare @forSpaID    as  bigint
declare @clientID    as  bigint
declare @fyID        as  bigint
declare @pracID      as  bigint
declare @isIFSPorIEP as  bit
declare @groupID     as  bigint
declare @nameID      as  bigint

declare @today       as datetime
declare @earliestDOS as date
declare @latestDOS   as date
declare @spaEndsOn   as date

set @today     = getdate()
set @recordID  = 0
set @spDetails = ''
set @saveType  = 0

BEGIN TRY

/*============================================================
 * Check required parameters
 *============================================================*/  

IF (@userID      IS NULL) RAISERROR ('userID is required',          11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',       11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',        11, 1) 
IF (@selectionID IS NULL) RAISERROR ('selection id is required',    11, 1)    
IF (@authorized  IS NULL) RAISERROR ('authorized flag is required', 11, 1)

/*============================================================
 * Parse and validate selectionID
 *============================================================*/  

exec dbo.CLAIM_RETROACTIVE_FOR_SPA_PARSE_SELECTION_ID 
    @selectionID
  , @forSpaID    output
  , @clientID    output
  , @fyID        output
  , @pracID      output
  , @isIFSPorIEP output
  , @groupID     output
  , @nameID      output

/*============================================================
 * Make sure user exists and can perform this operation
 * Only LEA coordinators can do this
 *============================================================*/  

/*
if not exists (
  select top 1 
    ua.id
  from users.dbo.USERS_ALL as ua
  where 
        (ua.clientID = @clientID)
    and (ua.id       = @userID)
    and (ua.userGroupID = users.dbo.CONST_USER_GROUP_CLIENT())
    and (ua.appName     = users.dbo.CONST_APP_NAME_SPEDCARE())
    and (ua.roleID = 5) /* LEA Coordinator */
)
begin
  RAISERROR ('Only LEA coordinators associated with this client can do this', 11, 1)    
end
*/

-- TODO: if we put this back in, then we should also allow the client consultants to perform this action.  But only the correct ones

/*============================================================
 * Check SPA
 *============================================================*/  

select top 1 
     @earliestDOS = t1.earliestDOSAllowed
   , @latestDOS   = t1.latestDOSAllowed 
from dbo.CLAIM_RETROACTIVE_FOR_SPA as t1
where ( 
      (t1.id = @forSpaID)
  and (@today <= t1.endClaimingOn) 
)

if (@earliestDOS is null)
begin
  RAISERROR ('SPA data not found or claiming window for SPA has ended', 11, 1)    
end

/*============================================================
 * Check fiscal year
 *============================================================*/  

if not exists (
  select top 1 
    t1.ID 
  from dbo.COMPANY_FISCAL_YEARS as t1
  where ( 
      (t1.ID = @fyID)
  and (t1.FY_START between @earliestDOS and @latestDOS)
  and (t1.FY_END   between @earliestDOS and @latestDOS)
  )
)

begin
  RAISERROR ('Fiscal year not valid or does not apply to this SPA', 11, 1)    
end

/*============================================================
 * See if selection is possible
 *============================================================*/ 
  
if not exists (

  select top 1
    t1.numSvcRecs
  from dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW_CORE ( @forSpaID, @clientID, @fyID, null ) as t1
  where (
        (t1.id          = @selectionID)
	and (t1.pracID      = @pracID)
    and (t1.isIFSPorIEP = @isIFSPorIEP)
    and (t1.groupID     = @groupID)
    and (t1.nameID      = @nameID)
  )
)
begin
  RAISERROR ('Selection not valid', 11, 1) 
end


/*============================================================
 * Assume this is a new record to start
 *============================================================*/  

set @saveType = dbo.CONST_SAVE_TYPE_NEW()

/*============================================================
 * See if an authorization record exists for this selection
 * Note: This is using the unique composite clustered index
 *
 * If a record does exist the save type will be changed to
 * edit
 *============================================================*/  

select top 1

   @recordID = t1.id 
,  @saveType = dbo.CONST_SAVE_TYPE_EDIT()

from dbo.CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION as t1

where (
      (t1.forSpaID    = @forSpaID)
  and (t1.clientID    = @clientID)
  and (t1.fyID        = @fyID)
  and (t1.pracID      = @pracID)
  and (t1.isIFSPorIEP = @isIFSPorIEP)
  and (t1.groupID     = @groupID)
  and (t1.nameID      = @nameID)
)

/*============================================================
 * Record does not exist, create a new one
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  insert into dbo.CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION (
      selectionID
	, forSpaID
    , clientID
    , fyID
    , pracID
    , isIFSPorIEP
    , groupID 
    , nameID  
    , authorized 
    , created 
    , createdBy
  )

  values ( 
      @selectionID
    , @forSpaID 
    , @clientID 
    , @fyID 
    , @pracID
    , @isIFSPorIEP
    , @groupID
    , @nameID
    , @authorized
    , @today
    , @userID
  )

  set @recordID = SCOPE_IDENTITY()

end

/*============================================================
 * Record does exist, edit the response
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  update dbo.CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION 
  set 
     authorized     = @authorized
   , lastModified   = @today
   , lastModifiedBy = @userID
  where (id = @recordID)
end
else
begin
    RAISERROR ('save type not valid', 11, 1)   
end

/*============================================================
 * Create audit record
 *============================================================*/  

insert into dbo.CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_AUDIT_LOG (
    authorizationID
  , selectionID
  , authorized
  , loggedOn
  , userID 
  , saveType
  , reason )

values (
    @recordID
  , @selectionID
  , @authorized
  , @today
  , @userID
  , @saveType
  , @editDelReason )

/*============================================================
 * All done
 *============================================================*/  

RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Return any
   * error error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
            
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

GRANT EXECUTE ON  [dbo].[CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE_CORE] TO [webuser]
GO

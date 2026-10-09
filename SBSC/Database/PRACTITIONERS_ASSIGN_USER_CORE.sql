/* TODO: Refactor so we exit on validate = 1 */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONERS_ASSIGN_USER_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONERS_ASSIGN_USER_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTITIONERS_ASSIGN_USER_CORE] (
    @userID                                         bigint
  , @userGroup                                      int
  , @userRank                                       int
  , @clientID                                       bigint
  , @pracID                                         bigint
  , @userIDUid                                      uniqueidentifier
  , @userIDInt                                      bigint
  , @ascClientWithAcct                              bit
  , @ascPracWithAcct                                bit
  , @canHaveMultiClientPracAsc                      bit
  , @pracMustHaveEmploymentRelationshipWithClient   bit
  , @pracCannotHaveEmploymentRelationshipWithClient bit
  , @validateRec                                    bit
 )  
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONERS_ASSIGN_USER_CORE */    
/**    
 * Assigns a user account to an existing practitioner.
 *
 * Note: This sproc is not stand along.  It should be called from other 
 * sprocs within a transaction block.   
 ***************************************************************************/        
 
SET NOCOUNT ON    
   
declare @today       as datetime
declare @updateState as smallint
declare @saveType    as int
declare @auditRecID  as bigint
declare @minIdx      as bigint
declare @maxIdx      as bigint
declare @curIdx      as bigint

declare @pracs as table (
    IDX             bigint identity(1,1)
  , PRACTITIONER_ID bigint
  , PRAC_ASP_ID     uniqueidentifier
  , UserID          bigint
  , CLIENT_ID       bigint
  , ACTIVE          bit
  , employeeRelationshipID bigint
  , UPDATE_REC      bit
)

BEGIN TRY    

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
if (@userID is null) RAISERROR ('User id is required',    11, 1)

if (@validateRec = 0)
begin
  IF (@userIdUid is null) RAISERROR ('UserIdUID is required',  11, 1)
  IF (@userIdInt is null) RAISERROR ('UserIdInt is required',  11, 1)
end

if (@ascClientWithAcct         is null) RAISERROR ('ascClientWithAcct is required',            11, 1)
if (@ascPracWithAcct           is null) RAISERROR ('ascPracWithAcct is required',            11, 1)
if (@canHaveMultiClientPracAsc is null) RAISERROR ('canHaveMultiClientPracAsc is required',  11, 1)

set @today       = getdate()
set @saveType    = dbo.CONST_SAVE_TYPE_EDIT()
set @updateState = dbo.CONST_REC_STATE_MOD() 

/* Lookup existing associations by useriduid */

if (@userIDUid is not null)
  begin
  insert into @pracs
    select 
        prp.PRACTITIONER_ID
      , prp.PRAC_ASP_ID
      , prp.UserID
      , prc.CLIENT_ID
      , prp.ACTIVE
      , prp.employeeRelationshipID
      , UPDATE_REC = 0
    from dbo.PRACTITIONER_Practitioner as prp
    join dbo.PRACTITIONER_Client       as prc on prc.PRACTITIONER_ID = prp.PRACTITIONER_ID
    join dbo.CLIENTS_Client            as clc on clc.CLIENT_ID       = prc.CLIENT_ID
    where (prp.PRAC_ASP_ID = @userIDUid)
end

/* Lookup existing associations by pracid */

if ((@clientID is not null) and (@pracID is not null))
begin

  insert into @pracs
  select 
      prp.PRACTITIONER_ID
    , prp.PRAC_ASP_ID
    , prp.UserID
    , prc.CLIENT_ID
    , prp.ACTIVE
    , prp.employeeRelationshipID
    , UPDATE_REC = 0
  from dbo.PRACTITIONER_Practitioner as prp
  join dbo.PRACTITIONER_Client       as prc on prc.PRACTITIONER_ID = prp.PRACTITIONER_ID
  join dbo.CLIENTS_Client            as clc on clc.CLIENT_ID       = prc.CLIENT_ID
  where  
        (prp.PRACTITIONER_ID = @pracID)
    and (clc.CLIENT_ID = @clientID)
    and (@pracID not in (select PRACTITIONER_ID from @pracs))
end


/* Manage existing associations */

/* This user no longer has prac associations or needs none, cleanup any former associations with any record */

if (@ascPracWithAcct = 0)
begin  

  if (@validateRec = 0)
    update @pracs set UPDATE_REC = 1

  update prp set 
	  prp.PRAC_ASP_ID = null
	, prp.UserID      = null
	, state         = @updateState
    , DATE_MODIFIED = @today
  from dbo.PRACTITIONER_Practitioner as prp
  join @pracs                        as prcs on prcs.PRACTITIONER_ID = prp.PRACTITIONER_ID
  where (prcs.UPDATE_REC = 1) 

end

/* This user requires a prac association */

else
begin

  /* If required data is not provided get out */

  if (@clientID  is null) RAISERROR ('Client id is required',  11, 1)
  if (@pracID    is null) RAISERROR ('Prac id is required',    11, 1)
  
  if not exists (select * from @pracs where PRACTITIONER_ID = @pracID) 
    RAISERROR ('Practitionr not found',    11, 1)

  if (@pracMustHaveEmploymentRelationshipWithClient = 1)
    if exists (select * from @pracs where PRACTITIONER_ID = @pracID and employeeRelationshipID not in (10,20)) 
	  RAISERROR ('This role requires that the practitioner be on staff or contracted with the client', 11, 1)

  if (@pracCannotHaveEmploymentRelationshipWithClient = 1)
    if exists (select * from @pracs where PRACTITIONER_ID = @pracID and employeeRelationshipID not in (30)) 
	  RAISERROR ('This role requires that the practitioner have NO employment relationship with the client', 11, 1)
  
  /* This user can only have ONE prac association PERIOD and thats with a specific clientid + pracid combo
     Cleanup ALL existing associations regardless of client */

  if (@canHaveMultiClientPracAsc = 0)
  begin
      	
	if (@validateRec = 0)  
	  update @pracs set UPDATE_REC = 1
        
	update prp set 
	    prp.PRAC_ASP_ID  = null
      , prp.UserID       = null
	  , state            = @updateState
      , DATE_MODIFIED    = @today
    from dbo.PRACTITIONER_Practitioner as prp
    join @pracs                        as prcs on prcs.PRACTITIONER_ID = prp.PRACTITIONER_ID
    where (prcs.UPDATE_REC = 1)

  end
 
  /* This user can only multiple prac associations but only one association per client
     Cleanup ALL existing associations with given client id.  
     Note we do not want to clean up other client id + prac id combos because we might wipe out valid data */
  
  else  
  begin
    
	if (@validateRec = 0)  	
	  update @pracs set UPDATE_REC = 1 where (CLIENT_ID = @clientID)

    update prp set 
	    prp.PRAC_ASP_ID  = null
      , prp.UserID       = null
	  , state            = @updateState
      , DATE_MODIFIED    = @today
    from dbo.PRACTITIONER_Practitioner as prp
    join @pracs                        as prcs on prcs.PRACTITIONER_ID = prp.PRACTITIONER_ID
	where (prcs.UPDATE_REC = 1)

  end
end


/*-------------------------------    
 * Create audit record(s) for
 * assocation cleanups
 *------------------------------*/    

if (@validateRec = 0)  	
begin
  select @minIdx = min(IDX) from @pracs
  select @maxIdx = max(IDX) from @pracs
  set @curIdx = @minIdx
  while(@curIdx <= @maxIdx)
  begin
    declare @pracRecID as bigint = null
    declare @updatedPracRec as bit = null
    select top 1 @pracRecID = PRACTITIONER_ID, @updatedPracRec = UPDATE_REC from @pracs where IDX = @curIdx
    if (@updatedPracRec = 1)
    begin
      EXEC dbo.PRACTITIONERS_Audit @pracRecID, @today, @userID, @saveType, @updateState, 'Unassigned user account', @auditRecID OUTPUT        
    end
    set @curIdx = @curIdx + 1
  end
end

/*-------------------------------    
 * Associate practitioner record
 *------------------------------*/    

if ((@validateRec = 0) and (@ascPracWithAcct = 1))
begin

  /* Update our data */

  update dbo.PRACTITIONER_Practitioner set 
      PRAC_ASP_ID   = @userIDUid
    , UserID        = @userIDInt
    , state         = @updateState
    , DATE_MODIFIED = @today
  where (PRACTITIONER_ID = @pracID)
              
  /* Create audit record */

  EXEC dbo.PRACTITIONERS_Audit @pracID, @today, @userID, @saveType, @updateState, 'Assigned user account', @auditRecID OUTPUT    
       
end

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
         
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
   
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[PRACTITIONERS_ASSIGN_USER_CORE] TO [webuser]
GO

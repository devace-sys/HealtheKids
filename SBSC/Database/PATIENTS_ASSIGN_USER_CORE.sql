/* TODO: This is initial code and it probably needs more logic added. */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_ASSIGN_USER_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENTS_ASSIGN_USER_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PATIENTS_ASSIGN_USER_CORE] (
    @userID                                         bigint
  , @userGroup                                      int
  , @userRank                                       int
  , @clientID                                       bigint
  , @patID                                          bigint
  , @userIDUid                                      uniqueidentifier
  , @userIDInt                                      bigint
  , @ascClientWithAcct                              bit
  , @ascPatWithAcct                                 bit
  , @canHaveMultiClientPatAsc                       bit
  , @validateRec                                    bit
 )  
AS    
BEGIN    
   
/***************************************************************************    
 * PATIENTS_ASSIGN_USER_CORE */    
/**    
 * Assigns a user account to an existing patient
 *
 * Note: This sproc is not stand along.  It should be called from other 
 * sprocs within a transaction block.   
 ***************************************************************************/        
 
SET NOCOUNT ON    

declare @existingPatUserAccountRecID as bigint = -1

IF (@validateRec = 1) RETURN(0)     

BEGIN TRY    

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
if (@userID                    is null) RAISERROR ('User id is required',                   11, 1)
if (@userIdUid                 is null) RAISERROR ('UserIdUID is required',                 11, 1)
if (@userIdInt                 is null) RAISERROR ('UserIdInt is required',                 11, 1)

/* Clean up existing association if any and exit.  Note: This is also used to exit if role is not patient */

If (@ascPatWithAcct = 0)
begin
 -- Clean up existing associations (if any)
 RETURN(0)
end

if (@clientID                  is null) RAISERROR ('clientID is required',                  11, 1)
if (@patID                     is null) RAISERROR ('patID is required',                     11, 1)
if (@ascClientWithAcct         is null) RAISERROR ('ascClientWithAcct is required',         11, 1)
if (@canHaveMultiClientPatAsc  is null) RAISERROR ('canHaveMultiClientPatAsc is required',  11, 1)

/* Find patient record associated with client + patient id */

if not exists (
  select top 1 
    pap.PATIENT_ID
  from dbo.PATIENTS_CLIENT  as pac
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.PATIENT_ID
  where ( 
        (pac.CLIENT_ID  = @clientID)
    and (pac.PATIENT_ID = @patID)
    and (pap.ACTIVE    != N'N')
  )
)
begin
  RAISERROR ('Patient not found or is no longer active', 11, 1)
end

/* Find record associated with client + patient id + userid */

select top 1 
  @existingPatUserAccountRecID = isnull(t1.id,-1)
from dbo.PATIENTS_USER_ACCOUNTS as t1
where ( 
      ((t1.userIDInt = @userIDInt))
  and (t1.clientID  = @clientID)
  and (t1.patID     = @patID)  
  and (t1.active    = 1)
)

/* If one is not found then create one */

if (@existingPatUserAccountRecID = -1)
begin
  insert into dbo.PATIENTS_USER_ACCOUNTS (            		  
      userIDInt            
    , userIDUid            
    , clientID 				
    , patID                 
    , created 				
    , createdBy 			
    , active 
  )
  values (
      @userIDInt
    , @userIDUid
    , @clientID 
    , @patID    
    , getdate()
    , @userID
    , 1
  )
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
 
GRANT EXECUTE ON  [dbo].[PATIENTS_ASSIGN_USER_CORE] TO [webuser]
GO

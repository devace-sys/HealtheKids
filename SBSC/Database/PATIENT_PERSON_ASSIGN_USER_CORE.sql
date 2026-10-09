USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PERSON_ASSIGN_USER_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PERSON_ASSIGN_USER_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PATIENT_PERSON_ASSIGN_USER_CORE] (
    @userID                      BIGINT
  , @userGroup                   INT  
  , @userRank                    INT
  , @clientID                    bigint
  , @patientPersonID             bigint
  , @userIDUid                   uniqueidentifier
  , @userIDInt                   bigint
  , @ascClientWithAcct           bit
  , @ascPrtGrdWithAcct           bit
  , @canHaveMultiClientPrtGrdAsc bit
  , @validateRec                 bit )
AS    
BEGIN    
   
/***************************************************************************    
 * PATIENT_PERSON_ASSIGN_USER_CORE */    
/**    
 * Assigns a user account to an existing practitioner.
 *
 * Note: This sproc is not stand along.  It should be called from other 
 * sprocs within a transaction block.   
 *
 * @param   clientID        Practitioners client id  
 * @param   pracID          Practitioners record id
 * @param   userIDUid       User id (unique identifier)
 * @param   userIDInt       User id (bigint)
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgNoClient     Desired error message if a clientID is not found 
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted    
 ***************************************************************************/        
 
SET NOCOUNT ON    

/* If we are in validation mode exit */

IF (@validateRec = 1) RETURN(0)     

BEGIN TRY    

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    

IF (@userID      IS NULL) RAISERROR ('userID is required',            11, 1)
IF (@userIDUid   IS NULL) RAISERROR ('User id uid is required',       11, 1)
IF (@userIDInt   IS NULL) RAISERROR ('User id int is required',       11, 1)

/* Clean up existing association if any and exit.  Note: This is also used to exit if role is not parent/guardian */

If (@ascPrtGrdWithAcct = 0)
begin
 -- Clean up existing associations (if any)
 RETURN(0)
end

IF (@patientPersonID IS NULL) RAISERROR ('Patient person id is required', 11, 1)

update dbo.PATIENTS_PERSON
set 
    USER_ID_UID      = @userIDUid 
  , USER_ID_INT      = @userIDInt
  , LAST_MODIFIED_BY = @userID
  , LAST_MODIFIED_ON = getdate()
where 
  (ID = @patientPersonID)
       
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
 
GRANT EXECUTE ON  [dbo].[PATIENT_PERSON_ASSIGN_USER_CORE] TO [webuser]
GO

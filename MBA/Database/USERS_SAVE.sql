USE [users]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.USERS_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[USERS_SAVE] (
    @userID          BIGINT    
  , @userGroup       INT
  , @userRank        INT
  , @appName         varchar(50)
  , @clientID        BIGINT
  , @selpaCode       BIGINT
  , @personID        BIGINT
  , @roleID          BIGINT
  , @username        NVARCHAR(256)
  , @pwdMinLen       int
  , @firstname       NVARCHAR(128)
  , @lastname        NVARCHAR(128)
  , @email           NVARCHAR(256)
  , @phone           NVARCHAR(14)  
  , @receiveEmailNotifications bit
  , @recID           BIGINT
  , @editDelReason   VARCHAR(7000)
  , @validateRec     BIT      
  , @saveType        INT
  , @MsgNotActive    VARCHAR(1000)
  , @MsgDupRec       VARCHAR(1000)
  , @MsgNoRec        VARCHAR(1000)    
  , @MsgNoEdit       VARCHAR(1000)    
  , @MsgDataError    VARCHAR(1000)
  , @recordID        BIGINT        OUTPUT
  , @jsonData        varchar(max)  OUTPUT
  , @spDetails       VARCHAR(8000) OUTPUT
)  
AS    
BEGIN    
   
/***************************************************************************    
 * USERS_SAVE */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   userID          The userID of who is requesting the new user account  
 * @param   userGroup       That users group    
 * @param   userRank        That user rank
 * @param   appName         Application name (from web.config)
 * @param   clientID        New users clientID (if any)  
 * @param   associateWithID Associate with external entity id
 * @param   roleID          roleId of user
 * @param   username        New users username
 * @param   password        New users password 
 * @param   firstname       New users first name
 * @param   lastname        New users last name
 * @param   email           New users email
 * @param   phone           New users phone number  
 * @param   recID           Record id of existing USER record to edit      
 * @param   validateRec     1 = Performs data integrity validation tasks    
 *                              Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete   
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found    
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of user record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
DECLARE @tranOpen         AS BIT            -- Is a transaction open    

BEGIN TRY    
   
   
BEGIN TRANSACTION    
SET @TranOpen = 1    
      
exec dbo.USERS_SAVE_CORE 
    @userID          
  , @userGroup       
  , @userRank        
  , @appName
  , @selpaCode         
  , @clientID        
  , @personID        
  , @roleID          
  , @username  
  , @pwdMinLen
  , @firstname       
  , @lastname        
  , @email           
  , @phone           
  , @receiveEmailNotifications
  , @recID           
  , @editDelReason   
  , @validateRec     
  , @saveType        
  , @MsgNotActive    
  , @MsgDupRec       
  , @MsgNoRec        
  , @MsgNoEdit       
  , @MsgDataError    
  , @recordID   OUTPUT
  , @jsonData   OUTPUT
  , @spDetails  OUTPUT

COMMIT TRANSACTION    
SET @TranOpen = 0    
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
     
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
     
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

GRANT EXECUTE ON  [dbo].[USERS_SAVE] TO [webuser]
GO
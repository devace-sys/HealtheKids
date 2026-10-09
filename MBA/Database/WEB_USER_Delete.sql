USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.WEB_USER_Delete') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.WEB_USER_Delete
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[WEB_USER_Delete]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,
  @appName       varchar(50),    /* Application name (from web.config)*/
  @clientID      INT, 
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,    
  @recID         INT, 
  @MsgNoRec      VARCHAR(1000),     
  @MsgNoEdit     VARCHAR(1000),     
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * WEB_USER_Delete */    
/**    
 * Deletes (hides) an existing user    
 * and manages any associated user records.    
 *    
 * @param   userID          The userid of user requesting delete
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits      
 * @param   recId           Record id of user to delete
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
DECLARE @tempRecID    AS INT            -- Used for determining if a rec exists    
DECLARE @today        AS DATETIME       -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT         -- Audit record id    
DECLARE @recUserID    AS BIGINT    
DECLARE @canEdit      AS BIT    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT 
DECLARE @userUId      as UNIQUEIDENTIFIER    
    
BEGIN TRY    
    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    
    
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
    
IF (@userID      IS NULL) RAISERROR ('User ID is required',  11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required', 11, 1)    
IF (@recID       IS NULL) RAISERROR ('Record id is required',  11, 1)    
    
/*-------------------------------    
 * See if the record can be     
 * deleted 
 *------------------------------*/    
     
SET @recordID = null    
SET @canEdit  = 0    
      
SELECT 
   @recordID = id
 , @userUId  = uid       

from dbo.USERS_VIEW_CORE (@userID, @userGroup, @userRank, @appName,null,null,null,@recID)
where (
     (canEdit = 1)
 and ((@clientID is null) or (clientID = @clientID))
)

/*-------------------------------    
 * If there are any problems    
 * let the user know    
 *------------------------------*/    

IF ((@recordID IS NULL) OR (@userUId IS NULL))
  SET @spDetails = dbo.UPDATE_DETAILS(@spDetails, @MsgNoRec ,dbo.CONST_RET_WARN())    

/*-------------------------------    
 * If we are just validating     
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    

/*-------------------------------    
 * If there is nothing to update
 * get out
 *------------------------------*/    

IF ((@recordID IS NULL) OR (@userUId IS NULL)) RETURN(0)
  
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
    
  /*-------------------------------    
   * UPDATE existing Membership    
   * record    
   *------------------------------*/    
      
  SET @updateState = dbo.CONST_REC_STATE_DEL()  
    
  UPDATE dbo.Membership     
  SET     
    IsApproved  = 0,
    IsLockedOut = 1 
  WHERE (UserId = @userUId)    
  
  /*-------------------------------    
   * UPDATE RoleId to Deactivated in
   * UsersInRoles table  
   *------------------------------*/
   
   UPDATE dbo.UsersInRoles
   SET
     RoleId = dbo.CONST_ROLE_INACTIVE()
   WHERE (UserId = @userUId) 
      
  /*-------------------------------------    
   * Delete applicable WebSession entries    
   *------------------------------------*/    
   
   DELETE FROM dbo.WebSessions WHERE UserID = @userUId
      
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
       
   EXEC WEB_USERS_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
       
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
     
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
    
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
    
  -- Reraise the error so it returns back to the server    
    
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[WEB_USER_Delete] TO [webuser]
GO

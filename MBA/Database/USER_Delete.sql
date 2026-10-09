USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USER_Delete') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.USER_Delete
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[USER_Delete]     
 (@userName      nvarchar(256),
  @validateRec     BIT
 )    
AS    
BEGIN     
    
/***************************************************************************    
 * USER_Delete */    
/**    
 * Deletes (hides) an existing user and manages any associated user records.    
 * 
 * NOTE: This procedure should only be called by hand
 *
 * 
 *    
 * @param   userName        The username to delete
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits      
 ***************************************************************************/         
     
SET NOCOUNT ON    

DECLARE @TranOpen     AS BIT    
DECLARE @today        AS DATETIME       -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT         -- Audit record id    
DECLARE @recordID     AS BIGINT    
DECLARE @userUID      as UNIQUEIDENTIFIER    
DECLARE @saveType     as INT  
DECLARE @updateState  as INT  
DECLARE @recCount     as INT

BEGIN TRY    
    
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
IF (@userName    IS NULL) RAISERROR ('userName is required',      11, 1)    
IF (@validateRec IS NULL) RAISERROR ('validateRec is required',      11, 1)    

/*-------------------------------    
 * Init 
 *------------------------------*/    
    
SET @saveType    = dbo.CONST_SAVE_TYPE_DELETE()    
SET @updateState = dbo.CONST_REC_STATE_DEL() 
SET @today       = GETDATE()    
SET @userName    = lower(@userName) -- We search for the lowercase version of the user name
    
/*-------------------------------    
 * Look up user data
 *------------------------------*/    
     
set @userName  = lower(@userName)
set @recCount  = 0

/*-------------------------------    
 * Count # of instances first
 *------------------------------*/    

select 
  @recCount = COUNT([userrid])
from Users
where LoweredUserName = @userName

/*-------------------------------    
 * If we found some
 *------------------------------*/    

if (@recCount >= 1)
begin

  /*-------------------------------    
   * Get details
   *------------------------------*/    

  set @recordID  = null

  select top 1
    @recordID = [userrid],
    @userUID  = [UserId]
  from Users
  where LoweredUserName = @userName
end

/*-------------------------------    
 * If we did not find any get out
 *------------------------------*/    

else
begin
  RAISERROR ('User not found', 11, 1)    
end

/*-------------------------------    
 * If we are validating show data
 *------------------------------*/    

if (@validateRec = 1)
begin
  
   select 
     ur. *,
     r.RoleName,
     m.FirstName,
     m.LastName
   from UsersInRoles as ur
   join Roles r on r.RoleId = ur.RoleId
   join Membership as m on m.UserId = ur.UserId
   where (ur.UserId = @userUID)



  if (@recCount > 1) RAISERROR ('More than one user found', 11, 1)  

end


/*-------------------------------    
 * If we are just validating     
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    

/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
    
  /*-------------------------------    
   * UPDATE existing Membership    
   * record    
   *------------------------------*/    
          
  UPDATE dbo.Membership     
  SET     
    IsApproved  = 0,
    IsLockedOut = 1 
  WHERE (UserId = @userUID)    
  
  /*-------------------------------    
   * UPDATE RoleId to Deactivated in
   * UsersInRoles table  
   *------------------------------*/
   
  UPDATE dbo.UsersInRoles
  SET
    RoleId = dbo.CONST_ROLE_INACTIVE()
  WHERE (UserId = @userUID) 
      
  /*-------------------------------------    
   * Delete applicable WebSession entries    
   *------------------------------------*/    
   
  DELETE FROM dbo.WebSessions WHERE UserID = @userUId
      
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
       
  EXEC WEB_USERS_Audit @recordID, @today, 0, @saveType, @updateState, '', @auditRecID OUTPUT     
       
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



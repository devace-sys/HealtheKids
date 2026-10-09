USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS_DELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CLIENT_STUDENT_INFORMATION_SYSTEMS_DELETE]    
 (
    @userID        BIGINT 
  , @userGroup     INT   
  , @userRank      INT
  , @clientID      BIGINT
  , @recID         BIGINT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )     
AS    
BEGIN    
   
/***************************************************************************    
 * CLIENT_STUDENT_INFORMATION_SYSTEMS_DELETE */    
/**    
 * Deletes an existing client student information system record   
 *    
 * @param   userID          The user id of who deleted the record    
 * @param   userGroup       The user group
 * @param   userRank        The user rank
 * @param   clientID        The client id     
 * @param   recID           Record id of existing record to delete
 * @param   editDelReason   Reason for deletion
 * @param   validateRec     1 = Performs data integrity validation tasks    
                            Perform advisory validation tasks that can    
 *                          only be conducted by referencing data from the    
 *                          database and then exits WITHOUT deleting the record    
 *                          0 = Peform data integrity validation tasks and    
 *                          if these tasks succeed performs the desired    
 *                          operation on the record and exits    
 * @param   MsgNoRec        Desired error message for delete operations     
 *                          when record is not found    
 * @param   MsgNoEdit       Desired error message for delete operations     
 *                          if the record cannot be deleted     
 * @returns spDetails       Validation or error details    
 * @returns recordID        Record id that was deleted     
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @TranOpen     AS BIT    
DECLARE @today        AS DATETIME          -- Current date/time stamp    
   
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID   = 0 
set @spDetails  = ''
SET @today      = GETDATE()       
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('RecID is required', 11, 1)    
     
/*-------------------------------    
 * Check if record exists
 *------------------------------*/    
     
set @recordID = NULL 

select top 1
    @recordID = csis.id 
FROM dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS AS csis
WHERE (
        (csis.id = @recID)
    AND ((@clientID IS NULL) OR (csis.clientID = @clientID)) /* Client users will have @clientID populated */
    AND (csis.active = 1)
)
     
/*-------------------------------    
 * If there are any problems    
 * let the user know    
 *------------------------------*/    
   
IF (@recordID IS NULL) 
begin
    set @recordID = 0
    RAISERROR (@MsgNoRec,  11, 1)   -- Record not found    
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
     * "Delete" existing entity record
     * (soft delete - set active = 0)   
     *------------------------------*/       
  
    UPDATE dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS 
    SET   active           = 0
        , lastModified     = @today
        , lastModifiedBy   = @userID
    WHERE (id = @recordID)    
  
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
   
    IF @tranOpen = 1 ROLLBACK TRANSACTION    
   
    DECLARE @ErrorMessage  AS NVARCHAR(4000)    
    DECLARE @ErrorSeverity AS INT    
    DECLARE @ErrorState    AS INT    
     
    SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
            @ErrorSeverity = ERROR_SEVERITY(),    
            @ErrorState    = ERROR_STATE()    
   
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
    -- Reraise the error so it returns back to the server    
   
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)    
   
END CATCH    

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[CLIENT_STUDENT_INFORMATION_SYSTEMS_DELETE] TO [webuser]
GO
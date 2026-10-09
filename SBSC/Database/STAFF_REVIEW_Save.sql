USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STAFF_REVIEW_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.STAFF_REVIEW_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[STAFF_REVIEW_Save]    
 (@staffID          bigint,
  @batchID         bigint,
  @categoryID      smallint,  
  @userID          bigint, 
  @review          nvarchar(MAX)
  )  
AS    
BEGIN    
   
/***************************************************************************    
 * STAFF_REVIEW_Save */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   staffID       staff ID
 * @param   batchID       InputBatch ID
 * @param   userID        userID 
 * @param   reviewID      Review about the staff  
 ***************************************************************************/        
     
SET NOCOUNT ON       


BEGIN TRY    
      
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
      
IF (@staffID       IS NULL) RAISERROR ('Staff is required', 11, 1)
IF (@review       IS NULL) RAISERROR ('Review is required', 11, 1)  
IF (@categoryID   IS NULL) RAISERROR ('Problem category is required', 11, 1)  

DECLARE @recID         as bigint
DECLARE @tranOpen      AS BIT            -- Is a transaction open    
DECLARE @saveType      AS int       

select @recID = ID from  dbo.STAFF_Problem_History   
 where INPUT_BATCH_ID = @batchID and STAFF_ID = @staffID and CATEGORY = @categoryID

if(@recID is null) SET @saveType = dbo.CONST_SAVE_TYPE_NEW()
else               SET @saveType = dbo.CONST_SAVE_TYPE_EDIT()
  
/*-------------------------------    
 * Create or modify our record    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1                
           
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
    
  
    INSERT INTO dbo.STAFF_Problem_History
    (  
	[STAFF_ID],
	[REPORTED_BY],	
	[INPUT_BATCH_ID],
    [CATEGORY],
	[PROBLEM_SUMMARY],
	[ACTIVE]
    )    
    VALUES    
    (  
     @staffID,
     @userID,
     @batchID,
     @categoryID,
     @review,
     1
    )      
          
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/    
                 
     UPDATE dbo.STAFF_Problem_History
     SET [STAFF_ID]        = @staffID,
	     [REPORTED_BY]     = @userID,	
	     [INPUT_BATCH_ID]  = @batchID,
         [CATEGORY]        = @categoryID,
	     [PROBLEM_SUMMARY] = @review	     
     WHERE (id  = @recID)       
        
  END    
  ELSE    
    RAISERROR ('Unknown save type', 11, 1)     
       
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

GRANT EXECUTE ON  [dbo].[STAFF_REVIEW_Save] TO [webuser]
GO
 

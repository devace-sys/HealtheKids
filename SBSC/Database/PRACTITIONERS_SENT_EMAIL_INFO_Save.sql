USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONERS_SENT_EMAIL_INFO_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONERS_SENT_EMAIL_INFO_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTITIONERS_SENT_EMAIL_INFO_Save]    
 (@pracID          bigint,
  @batchID         bigint,  
  @userID          bigint, 
  @reason          nvarchar(MAX)
  )  
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONERS_SENT_EMAIL_INFO_Save */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   pracID        Practitioner ID
 * @param   batchID       InputBatch ID
 * @param   userID        userID 
 * @param   reason        Reason for sending the mail   
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
      
IF (@pracID       IS NULL) RAISERROR ('Practitioner     is required', 11, 1)
IF (@userID       IS NULL) RAISERROR ('userID           is required', 11, 1)  

DECLARE @recID         as bigint
DECLARE @tranOpen      AS BIT            -- Is a transaction open    
DECLARE @saveType      AS int       

select @recID = input_batch_ID from  dbo.EMAILS_SENT_TO_PRACTITIONERS   
 where INPUT_BATCH_ID = @batchID and PRAC_ID = @pracID 
 
if(@recID is null) SET @saveType = dbo.CONST_SAVE_TYPE_NEW()
else               SET @saveType = dbo.CONST_SAVE_TYPE_EDIT()
  
/*-------------------------------    
 * Create or modify our record    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1                
           
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
    
  
    INSERT INTO dbo.EMAILS_SENT_TO_PRACTITIONERS   
    (  
	[PRAC_ID],
	[SENT_BY],	
	[INPUT_BATCH_ID],
	[DATE_SENT],    
	[REASON]
    )    
    VALUES    
    (  
     @pracID,
     @userID,
     @batchID, 
     GETDATE(),    
     @reason
    )      
          
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/    
                 
     UPDATE dbo.EMAILS_SENT_TO_PRACTITIONERS   
     SET [PRAC_ID]        = @pracID,
	     [SENT_BY]        = @userID,	
	     [INPUT_BATCH_ID] = @batchID,	     
	     [REASON]         = @reason	     
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

GRANT EXECUTE ON  [dbo].[PRACTITIONERS_SENT_EMAIL_INFO_Save] TO [webuser]
GO
 

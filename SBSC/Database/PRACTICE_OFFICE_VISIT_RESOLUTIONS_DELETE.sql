USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTICE_OFFICE_VISIT_RESOLUTIONS_DELETE] (
    @userID                 BIGINT
  , @userGroup              INT  
  , @userRank               INT      
  , @editDelReason          VARCHAR(7000)
  , @validateRec            BIT
  , @recID                  BIGINT
  , @MsgNoRec               VARCHAR(1000)
  , @MsgNoEdit              VARCHAR(1000)
  , @spDetails              VARCHAR(8000) OUTPUT
  , @recordID               BIGINT        OUTPUT )    
AS    
BEGIN   
/***************************************************************************    
 * PRACTICE_OFFICE_VISIT_RESOLUTIONS_DELETE*/    
/**    
 * Deletes an existing record   
 *    
 * @param   clientID        The clientid of who saved the record    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT deleting the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng service record to edit or    
 *                          delete.    
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
DECLARE @saveType     AS INT
DECLARE @today        AS DATETIME          -- Current date/time stamp    
   
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0 
set @spDetails  = ''
SET @today      = GETDATE()       
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    


IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)    
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('Record id is required',   11, 1)    
     
SET @recordID = NULL

SELECT TOP 1 
    @recordID = povr.id
FROM dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS as povr
WHERE(
     (povr.id = @recID)
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
   BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * "Delete" existing entity record    
   *------------------------------*/    
   UPDATE dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS
  SET   active         = 0
	  , lastmodified   = @today
	  , lastModifiedBy = @userID
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
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_VISIT_RESOLUTIONS_DELETE] TO [webuser]
GO

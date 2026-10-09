USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.KNOWN_HEALTH_PROBLEMS_DELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.KNOWN_HEALTH_PROBLEMS_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[KNOWN_HEALTH_PROBLEMS_DELETE]    
 (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @recID         INT
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )     
AS    
BEGIN    
   
/***************************************************************************    
 * KNOWN_HEALTH_PROBLEMS_DELETE */    
/**    
 * Deletes an existing record   
 *    
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
   
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('RecID is required', 11, 1)    
          
SET @recordID   = NULL 

 SELECT top 1
  @recordID = t1.ID 
FROM dbo.KNOWN_HEALTH_PROBLEMS as t1
where (
  (t1.ID = @recID)  
)
   
/*-------------------------------    
 * If there are any problems    
 * let the user know    
 *------------------------------*/    
   
IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)   -- Record not found    

/*-------------------------------    
 * Test for active use
 *------------------------------*/    

if exists (
select top 1 
  pkhp.id
from dbo.PATIENT_KNOWN_HEALTH_PROBLEMS as pkhp
where (
      (pkhp.knownHealthProblemID = @recordID)
  and (pkhp.active = 1)
)
)
begin
  RAISERROR ('This selection is in active use by patients.',  11, 1)
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
   *------------------------------*/       
  
  UPDATE dbo.KNOWN_HEALTH_PROBLEMS
  SET   active         = 0
	  , lastmodified   = @today
	  , lastModifiedBy = @userID		
  WHERE (ID = @recordID)    
 
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
   
  --SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[KNOWN_HEALTH_PROBLEMS_DELETE] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_INITIATE_CIF_BATCH') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_INITIATE_CIF_BATCH
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_INITIATE_CIF_BATCH]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @clientID      INT,
  @recIDMulti    varchar(8000), 
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_INITIATE_CIF_BATCH */    
/**    
 * Deletes (hides) an existing service record and manages any associated 
 * claim records.
 * 
 * NOTE: This is for single record deletes.
 *    
 * @param   userID          The userid of who saved the record    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recIDMulti      Comma seperated list of record ids to delete
 * @param   MsgNoRec        Desired error message for edit/delete service record    
 *                          operations when record is not found    
 * @param   MsgNoEdit       Desired error message for edit/delete service record    
 *                          operations if the service record cannot be edited or     
 *                          deleted     
 * @returns spDetails       Validation or error details    
 * @returns recordID        Number of record ids that were deleted  
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @TranOpen      as BIT    
DECLARE @today         as DATETIME       -- Current date/time stamp    
DECLARE @numRecIDs     as INT
DECLARE @numDupRecIDs  as INT
DECLARE @currentID     AS INT
DECLARE @recIDVal      AS BIGINT
DECLARE @spDetailsTemp AS VARCHAR(8000)
DECLARE @recIDVals     as TABLE([id] int, [recid] bigint) 


BEGIN TRY    

/*-------------------------------    
 * Init our details return
 *------------------------------*/
 
SET @spDetails = ''
   
/*-------------------------------    
 * Parse multirec value into
 * individual record ids
 *------------------------------*/
 
INSERT INTO @recIDVals
  select [id],[recid] from MULTI_RECORD_ID_PARSE(@recIDMulti,',')

/*-------------------------------    
 * Get number of record ids
 * Exit with an error if there
 * are none.
 *------------------------------*/

SET    @numRecIDs = 0
SELECT @numRecIDs = COUNT(id) FROM @recIDVals

IF (@numRecIDs = 0)
  RAISERROR ('One or more record ids are required', 11, 1) 
  
/*-------------------------------    
 * Check for duplicate record ids
 * Exit with an error if there
 * are dups.
 *------------------------------*/

SET    @numDupRecIDs = 0
SELECT @numDupRecIDs = COUNT([id]) FROM @recIDVals GROUP BY [recid] HAVING COUNT([id]) > 1

IF (@numDupRecIDs > 0) 
  RAISERROR ('Duplicate record ids are not allowed', 11, 1) 

SET @today = GETDATE()    

/*-------------------------------    
 * If this is an actual save
 * or edit begin a transaction
 *------------------------------*/  

IF (@validateRec = 0)
BEGIN
  BEGIN TRANSACTION    
  SET @TranOpen  = 1 
END
ELSE
  SET @TranOpen = 0  

/*-------------------------------    
 * Delete service record(s)
 *------------------------------*/

set @currentID = 1
set @recIDVal  = 0

while (@currentID <= @numRecIDs)                        
begin

  /*-------------------------------    
   * Get record id value
   *------------------------------*/  
  
  select @currentID     = id, 
         @recIDVal      = recid 
         
         from @recIDVals 
         where id = @currentID
  
  SET    @spDetailsTemp = ''
    
  /*-------------------------------    
   * Call delete with record id
   *------------------------------*/  
  
  EXEC SERVICE_RECORD_INITIATE_CIF_CORE @userID, 
                                  @userGroup, 
                                  @userRank, 
                                  @editDelReason, 
                                  @validateRec, 
                                  @clientID,
                                  @recIDVal,
                                  @today,
                                  @spDetailsTemp OUTPUT,
                                  @recordID      OUTPUT

  set @currentID = @currentID + 1            
  set @spDetails = @spDetails + ltrim(rtrim(@spDetailsTemp))
        
end -- While

/*-------------------------------    
 * Return the number of records
 * deleted as the recordID
 *------------------------------*/  

SET @recordID = @numRecIDs

/*-------------------------------    
 * If this was an actual save
 * or edit commit the transaction
 *------------------------------*/  

IF (@TranOpen  = 1) 
  COMMIT TRANSACTION    

/*-------------------------------    
 * Reset our transaction flag
 *------------------------------*/  

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

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_INITIATE_CIF_BATCH] TO [webuser]
GO

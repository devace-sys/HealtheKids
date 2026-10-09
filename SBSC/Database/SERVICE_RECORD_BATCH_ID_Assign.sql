USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_BATCH_ID_Assign') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_BATCH_ID_Assign
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_BATCH_ID_Assign]     
 (@userID            BIGINT,    
  @userGroup         INT,    
  @userRank          INT,
  @saveType          INT,    
  @validateRec       BIT,
  @batchID           UNIQUEIDENTIFIER,
  @entryNum          INT,
  @svcRecID          BIGINT,      
  @recordID          BIGINT           OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_BATCH_ID_Assign */    
/**    
 * Create a new service record batch id and record
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    

BEGIN TRY

/*============================================================
 * Init output parameters
 *============================================================*/  
    
SET @recordID   = 0    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
--IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)    
--IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
    
/*============================================================
 * If this is not a new record exit
 *============================================================*/  

IF (@saveType != dbo.CONST_SAVE_TYPE_NEW()) RETURN (0)

/*============================================================
 * If we are validating we do nothing and get out
 *============================================================*/  

IF (@validateRec = 1) RETURN (0)

/*============================================================
 * Create record
 *============================================================*/     
        
INSERT INTO dbo.SERVICE_RECORD_BATCHES 
(
   [batchID]
  ,[entryNumber]
  ,[svcRecID]
)
VALUES
(
   @batchID
  ,@entryNum
  ,@svcRecID
)

/*============================================================
 * Grab value of identity column
 *============================================================*/  

SET @recordID = SCOPE_IDENTITY()       
            
/*============================================================
 * All done
 *============================================================*/  
    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

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
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_BATCH_ID_Assign] TO [webuser]
GO

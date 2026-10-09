USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PERSONS_DELETE_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PERSONS_DELETE_Core
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[PERSONS_DELETE_Core]    
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @today         DATETIME,
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
 * PERSONS_DELETE_Core */    
/**    
 * Deletes or deactivates record
 *    
 * @param   userID          The userid of who saved the record   
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT deleting the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng Patient to edit or    
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
 
DECLARE @canEdit      AS BIT    
DECLARE @saveType     AS INT    
 
BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @saveType    = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID    = 0    
SET @spDetails   = ''    
 
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
 
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)    
IF (@today       IS NULL) RAISERROR ('Value for today is required', 11,1) 

/*-------------------------------    
 * Look for record 
 *------------------------------*/    

set @recordID = null

select top 1
  @recordID = ID
from dbo.PERSONS_PERSON
where (ID = @recID)

/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
 
IF (@validateRec = 1) RETURN(0)    
 
/*-------------------------------    
 * Deactivate record if it was 
 * found
 *------------------------------*/    
 
if (@recordID is not null)
begin 
  UPDATE dbo.PERSONS_PERSON 
  SET 
        LAST_MODIFIED_BY = @userID
      , LAST_MODIFIED_ON = @today      
	  , ACTIVE           = 0
  WHERE (ID = @recordID)   
end

/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
 
RETURN(0)    
END TRY    
 
BEGIN CATCH    
 
 /*-------------------------------    
   * If we end up here something    
   * went wrong.  Return any    
   * error messages to the caller    
   *------------------------------*/    
   
 
  -- Error or raise error with severity 11 to 19 will be caught here    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
 
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
 
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
 
GRANT EXECUTE ON  [dbo].[PERSONS_DELETE_Core] TO [webuser]
GO
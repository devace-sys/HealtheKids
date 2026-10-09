USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USER_SIGNATURES_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.USER_SIGNATURES_SAVE_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[USER_SIGNATURES_SAVE_CORE] (
    @userID              BIGINT
  , @userGroup           INT
  , @userRank            INT 
  , @signatureBase64	 VARCHAR(max) 
  , @signatureUserID	 BIGINT
  , @signaturePersonID   BIGINT
  , @active     		 BIT
  , @editDelReason       VARCHAR(7000)    
  , @validateRec         BIT    
  , @saveType            INT    
  , @recID               INT    
  , @MsgNoRec            VARCHAR(1000)    
  , @MsgNoEdit           VARCHAR(1000) 
  , @MsgDupRec           VARCHAR(1000)     
  , @MsgDataError        VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)     
  , @spDetails           VARCHAR(8000) OUTPUT    
  , @recordID            BIGINT        OUTPUT
)    
AS    
BEGIN     
 
/***************************************************************************    
 * USER_SIGNATURES_SAVE_CORE */    
/**    
 * Creates a new 
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 
 * @param   editDelReason   Reason for record edit or delete    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @param   recID           Record id of existing patient record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found    
 * @param   MsgNoSite       Desired error message if a siteID is not found     
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
 
SET NOCOUNT ON    
 
DECLARE @TranOpen            AS BIT  
DECLARE @today               as DATETIME

BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @spDetails  = ''    
SET @recordID = NULL 
SET @today    = GETDATE()
  
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
 
IF (@userID      IS NULL) RAISERROR ('userID is required',   11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)  
IF ((@signaturePersonID is null) and @userID != @signatureUserID) RAISERROR ('You do not have permission for this operation!',   11, 1)  


/*-------------------------------    
 * Validation exit
 *------------------------------*/    
  
IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        
 
/*============================================================
 * Write data
 *============================================================*/  

BEGIN TRANSACTION    
 
  SET @TranOpen = 1     
 
   /*==============================    
  * New Record
  *==============================*/ 

  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN        
     /*==============================    
      * Signature
      *==============================*/ 

     INSERT INTO dbo.USER_SIGNATURES (
          signatureBase64
	    , userID		 
        , personID		 
        , active  
		, createdOrLastModifiedOn
	  )          
      VALUES (
          @signatureBase64
        , @signatureUserID
        , @signaturePersonID
        , @active   
		, @today 
      )  
 
      SET @recordID = SCOPE_IDENTITY()              
 
 END       
 
 /*==============================    
  * Edit Record
  *==============================*/ 
 
 ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
 BEGIN      
	if (@recID is null)
	begin
		RAISERROR('recID is required for edits', 11, 1)
	end

    SET @recordID    = @recID
 
    UPDATE dbo.USER_SIGNATURES
    SET 
		  signatureBase64	      =   @signatureBase64
		, userID		 	      =   @signatureUserID
		, personID		 	      =   @signaturePersonID
		, active      		      =   @active  
		, createdOrLastModifiedOn =   @today 
    WHERE 
      (id = @recordID)  
 END
 ELSE
 BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)             
 END


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
 
GRANT EXECUTE ON  [dbo].[USER_SIGNATURES_SAVE_CORE] TO [webuser]
GO
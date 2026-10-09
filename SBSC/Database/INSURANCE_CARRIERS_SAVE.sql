USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INSURANCE_CARRIERS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.INSURANCE_CARRIERS_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[INSURANCE_CARRIERS_SAVE] (
     @userID                  BIGINT
   , @userGroup               INT  
   , @userRank                INT
   , @name 					  VARCHAR(80)	
   , @carrierCode			  VARCHAR(15)	
   , @ohcCode				  CHAR(10)
   , @usState				  CHAR(2)   
   , @planTypeCode			  CHAR(3)
   , @planSupportedByCYBHI    BIT
   , @editDelReason           VARCHAR (7000)
   , @validateRec             BIT
   , @saveType                INT
   , @recID                   BIGINT
   , @MsgNoRec                VARCHAR(1000)
   , @MsgNoEdit               VARCHAR(1000)
   , @MsgDupRec               VARCHAR(1000)
   , @MsgDataError            VARCHAR(1000)
   , @MsgNotActive            VARCHAR(1000)
   , @spDetails               VARCHAR(8000) OUTPUT
   , @recordID                BIGINT        OUTPUT ) 
 AS    
BEGIN  

/***************************************************************************    
 * INSURANCE_CARRIERS_SAVE */    
/**    
 * Creates new or edits existing
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
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/   

SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @today              AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen           AS BIT            -- Is a transaction open

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID  = 0    
SET @spDetails = ''    
SET @today     = GETDATE()    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1) 

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END        

BEGIN TRANSACTION
SET @TranOpen = 1
  
if (@saveType = dbo.CONST_SAVE_TYPE_NEW())

/*============================================================
 * Create new
 *===========================================================*/  

begin

    INSERT INTO dbo.INSURANCE_CARRIERS (
	     name
       , carrierCode
       , ohcCode
       , usState
       , planTypeCode
	   , planSupportedByCYBHI
       , created
       , createdBy
	)
	values (
	   @name
	 , @carrierCode
	 , @ohcCode 
     , @usState
	 , @planTypeCode
     , @planSupportedByCYBHI	 
	 , @today
	 , @userID
	)
    
    set @recordID = SCOPE_IDENTITY()

end
  
 /*============================================================
 * Edit existing
 *===========================================================*/   
 
else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
begin

  update dbo.INSURANCE_CARRIERS
  set	    
      name   			 	= @name
	, carrierCode  		 	= @carrierCode 
	, usState 			 	= @usState
	, ohcCode				= @ohcCode	
    , planTypeCode          = @planTypeCode
	, planSupportedByCYBHI  = @planSupportedByCYBHI
	, lastModified          = @today
	, lastModifiedBy        = @userID	  
  where 
	  (id = @recID)  
	  
  set @recordID = @recID
end

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
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
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
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

GRANT EXECUTE ON  [dbo].[INSURANCE_CARRIERS_SAVE] TO [webuser]
GO

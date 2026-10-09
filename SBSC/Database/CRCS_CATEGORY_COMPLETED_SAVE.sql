USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
                                                                      
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_CATEGORY_COMPLETED_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_CATEGORY_COMPLETED_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
                        
CREATE PROCEDURE [dbo].[CRCS_CATEGORY_COMPLETED_SAVE]     
 (  @userID                bigint    
  , @userGroup             int    
  , @userRank              int    
  , @clientID              bigint
  , @fiscalYearID          bigint
  , @quarterNumber         int
  , @crcsCategoryCode      int
  , @completed             bit
  , @saveType              int           OUTPUT    
  , @spDetails             varchar(8000) OUTPUT    
  , @recordID              bigint        OUTPUT
)
AS    
BEGIN     
    
/***************************************************************************    
 * CRCS_CATEGORY_COMPLETED_SAVE */    
/**    
 * Creates a new record or edits an exiting one
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

declare @TranOpen             as bit
declare @today                as datetime
declare @existingRecID        as bigint

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @recordID   = NULL 
SET @today      = GETDATE()
SET @spDetails  = ''    
set @saveType   = dbo.CONST_SAVE_TYPE_NEW()

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

/*-------------------------------    
 * Retrieve existing record
 *-------------------------------*/    

set @existingRecID = null

select top 1   
    @existingRecID  = ccc.id
from dbo.CRCS_CATEGORY_COMPLETED as ccc
where (
		(ccc.clientID         = @clientID)
	and (ccc.fiscalYearID     = @fiscalYearID)
	and (ccc.quarterNumber    = @quarterNumber)
	and (ccc.crcsCategoryCode = @crcsCategoryCode)
	and (ccc.active           = 1)
)  

BEGIN TRANSACTION    

SET @TranOpen = 1

/*-------------------------------    
 * If there is no record create
 * a new one
 *-------------------------------*/    

if (@existingRecID is null)
begin

  insert into dbo.CRCS_CATEGORY_COMPLETED (
      clientID
    , fiscalYearID
    , quarterNumber
    , crcsCategoryCode
    , completed
    , created
    , createdBy
    , active
   )
   values (
      @clientID
    , @fiscalYearID
    , @quarterNumber
    , @crcsCategoryCode
    , @completed
    , @today
    , @userID
    , 1
    )

  set @saveType = dbo.CONST_SAVE_TYPE_NEW()
  set @recordID = SCOPE_IDENTITY()

end

/*-------------------------------    
 * Otherwise update existing
 *-------------------------------*/    

else
begin      

  update dbo.CRCS_CATEGORY_COMPLETED
  set 
      clientID 		   = @clientID 		  
    , fiscalYearID	   = @fiscalYearID	  
    , quarterNumber	   = @quarterNumber	  
    , crcsCategoryCode = @crcsCategoryCode
    , completed		   = @completed		  
    , lastModified	   = @today		  
    , lastModifiedBy   = @userID 
	  	  
  where (id = @existingRecID)

  set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
  set @recordID = @existingRecID

end
  
/*============================================================
 * All done, commit changes and get out
 *============================================================*/

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

IF @tranOpen = 1 ROLLBACK TRANSACTION    
       
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

GRANT EXECUTE ON  [dbo].[CRCS_CATEGORY_COMPLETED_SAVE] TO [webuser]
GO


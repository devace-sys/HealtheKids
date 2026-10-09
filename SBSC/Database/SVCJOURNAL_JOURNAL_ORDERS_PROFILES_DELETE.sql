USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_ORDERS_PROFILES_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_ORDERS_PROFILES_DELETE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_ORDERS_PROFILES_DELETE]     
 (@userID                   BIGINT,    
  @userGroup                INT,    
  @userRank                 INT,    
  @clientID                 BIGINT, 
  @editDelReason            VARCHAR(7000),    
  @validateRec              BIT,    
  @recID                    BIGINT,
  @MsgNoRec                 VARCHAR(1000),    
  @MsgNoEdit                VARCHAR(1000), 
  @spDetails                VARCHAR(8000) OUTPUT,    
  @recordID                 BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_ORDERS_PROFILES_DELETE */    
/**    
 * Creates or edits prescribed order
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   patID           Patient id
 * @param   dos             Service date
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

declare @refID      as bigint
	  , @orpDocType as bigint

BEGIN TRY
	/*********************************************
	 * Extract ORP document data
	 *********************************************/
	select @refID = refID
		 , @orpDocType = orpDocTypeID 
    from dbo.ORP_DOCUMENTS_VIEW_CORE(
	    @userID                 
	  , @userGroup              
	  , @userRank               
	  , @clientID               
	  , null	--@rdrGroupSvcClassNameID 
	  , null	--@patID                  
	  , null	--@dos                    
	  , null	--@orpDocTypeID           
	  , null	--@refID                  
	  , null	--@active                 
	  , @recID     )
	
	/*********************************************
	 * Execute delete
	 *********************************************/             
    if (@orpDocType = 2)
	begin
		exec dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_DELETE     
		      @userID        
			, @userGroup     
			, @userRank      
			, @editDelReason 
			, @validateRec   
			, @clientID      
			, @refID         
			, @MsgNoRec      
			, @MsgNoEdit     
			, @spDetails     OUTPUT
			, @recordID      OUTPUT
	end

	else if (@orpDocType = 3)
	begin
		exec dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE
			  @userID         
			, @userGroup      
			, @userRank       
			, @editDelReason  
			, @validateRec    
			, @clientID       
			, @refID          
			, @MsgNoRec       
			, @MsgNoEdit      
			, @spDetails      	 OUTPUT
			, @recordID       	 OUTPUT
	end

	else
	begin
		RAISERROR('Invalid ORP Document Type', 11, 1)
	end

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


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_ORDERS_PROFILES_DELETE] TO [webuser]
GO

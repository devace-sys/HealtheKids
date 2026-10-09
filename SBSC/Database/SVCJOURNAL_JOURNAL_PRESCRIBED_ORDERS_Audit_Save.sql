USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_Save
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_Save]     
(  
	  @userID  				 BIGINT
	, @userGroup			 INT
	, @userRank				 INT
	, @recID			     BIGINT
	, @saveType      		 INT
	, @auditDataBeforeJSON   NVARCHAR(MAX)
	, @auditDataAfterJSON    NVARCHAR(MAX)
)    
AS    
BEGIN     
    
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_Save */    
/**    
 * Inserts a record into the log data modification history
 *    
 * @param   @userID  			 BIGINT
 * @param   @userGroup			 INT
 * @param   @userRank			 INT
 * @param   @recID			     BIGINT
 * @param   @saveType      		 INT
 * @param   @auditDataBeforeJSON NVARCHAR(MAX)
 * @param   @auditDataAfterJSON  NVARCHAR(MAX)
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/  

DECLARE @today                   As DATETIME      = GETDATE()         -- Current date/time stamp

BEGIN TRY

insert into dbo.SvcJournal_Prescribed_Orders_Audit (                  
      [RECORD_ID]            
    , [MODIFIED_BY]          
    , [MODIFIED_ON]          
    , [SAVE_TYPE]       
    , [DATA_BEFORE_JSON]
    , [DATA_AFTER_JSON]      
)
values (      
	  @recID   					         
	, @userID					       
	, @today        			       
	, @saveType        			         
	, @auditDataBeforeJSON
	, @auditDataAfterJSON 			   
)


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


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_Save] TO [webuser]
GO

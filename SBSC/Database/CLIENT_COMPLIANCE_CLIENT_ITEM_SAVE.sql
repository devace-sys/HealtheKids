USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE] (
    @userID                 BIGINT
  , @userGroup              INT  
  , @userRank               INT      
  , @clientID				BIGINT   
  , @clientComplianceItemID BIGINT
  , @notes                  NVARCHAR(max)
  , @isComplete				BIT
  , @dateCompleted			DATETIME

  , @dueDate                            DATE
  , @dashboardDate                      DATE

  , @editDueDateAllClients              BIT
  , @editDashboardDateAllClients              BIT

  --, @clientSpecificTaskDueDate                    DATE
  --, @clientSpecificTaskDashboardDate              DATE


 , @taskName                           varchar(256)

  , @editDelReason          VARCHAR(7000)
  , @validateRec            BIT
  , @saveType               INT
  , @recID                  BIGINT
  , @MsgNoRec               VARCHAR(1000)
  , @MsgNoEdit              VARCHAR(1000)
  , @MsgDupRec              VARCHAR(1000)
  , @MsgDataError           VARCHAR(1000)
  , @MsgNotActive           VARCHAR(1000)
  , @spDetails              VARCHAR(8000) OUTPUT
  , @recordID               BIGINT        OUTPUT )
AS    
BEGIN        
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @tranOpen           AS BIT            -- Is a transaction open

BEGIN TRY

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
  
/*-------------------------------    
 * Save client complaince item
 *------------------------------*/    

exec [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE_CORE] 
    @userID                
  , @userGroup             
  , @userRank              
  , @clientID
  , @clientComplianceItemID
  , @notes
  , @isComplete
  , @dateCompleted

  , @dueDate      
  , @dashboardDate    

  , @editDueDateAllClients    
  , @editDashboardDateAllClients    

 , @taskName   

  , @editDelReason         
  , @validateRec           
  , @saveType              
  , @recID                 
  , @MsgNoRec              
  , @MsgNoEdit             
  , @MsgDupRec             
  , @MsgDataError          
  , @MsgNotActive          
  , @spDetails             OUTPUT
  , @recordID              OUTPUT 

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

GRANT EXECUTE ON  [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE] TO [webuser]
GO


USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_SAVE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_SAVE] (
    @userID                       Bigint
  , @userGroup                    Int
  , @userRank                     Int 
  , @clientID				  	  bigint 
  , @fiscalYearID                 bigint 
  , @assetID                      varchar(50)
  , @assetType                 	  varchar(50)
  , @placedInServiceOn         	  date
  , @yearsUseful               	  int
  , @depreciableCost           	  Money
  , @fedResourceOrGrant			  Money
  , @resourceCodeAcctNum       	  varchar(50)
  , @annualDepreciation        	  Money
  , @retiredDuringCostPeriod   	  bit
  , @placedOutOfServiceOn      	  date
  , @accumulatedDepreciation   	  Money
  , @depreciationForReportPeriod  Money
  , @editDelReason                Varchar(7000)    
  , @validateRec                  Bit    
  , @saveType                     Int    
  , @recID                        Int    
  , @MsgNoRec                     Varchar(1000)    
  , @MsgNoEdit                    Varchar(1000) 
  , @MsgDupRec                    Varchar(1000)     
  , @MsgDataError                 Varchar(1000)
  , @MsgNotActive                 Varchar(1000)     
  , @spDetails                    Varchar(8000) OUTPUT   
  , @recordID                     BigInt        OUTPUT)    
AS    
BEGIN            
 
SET NOCOUNT ON    
 
DECLARE @TranOpen            AS BIT  
DECLARE @auditRecID          AS BIGINT
DECLARE @today               as DATETIME = GETDATE()

BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @spDetails  = ''    
SET @recordID = 0 
SET @today    = GETDATE()

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
 
IF (@userID            IS NULL)			    RAISERROR ('userID is required',      11, 1)      
IF (@userGroup         IS NULL)			    RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank          IS NULL)			    RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec       IS NULL)			    RAISERROR ('Validate flag required',  11, 1) 
IF (@clientID      IS NULL
or not exists (select top 1 CLIENT_ID from dbo.CLIENTS_Client where CLIENT_ID = @clientID)
)									    RAISERROR ('Invalid Client ID',      11, 1) 
IF (@fiscalYearID      IS NULL)			RAISERROR ('Fiscal Year is required', 11, 1)   
IF (@placedOutOfServiceOn < @placedInServiceOn)
BEGIN
	RAISERROR ('Placed out of service date cannot be before placed in service date', 11, 1)   
END
IF (@depreciableCost   			  < 0
 or	@fedResourceOrGrant			  < 0
 or	@annualDepreciation			  < 0
 or	@accumulatedDepreciation   	  < 0
 or	@depreciationForReportPeriod  < 0) RAISERROR ('Dollar amount cannot be negative', 11, 1)

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

  if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
  begin
	Insert into dbo.CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS (		  
		  clientID				  
		, fiscalYearID                        
		, assetID                      
		, assetType                 
		, placedInServiceOn         
		, yearsUseful               
		, depreciableCost           
		, fedResourceOrGrant		
		, resourceCodeAcctNum       
		, annualDepreciation        
		, retiredDuringCostPeriod   
		, placedOutOfServiceOn      
		, accumulatedDepreciation   
		, depreciationForReportPeriod
		, created                
		, createdBy
	) values (
	      @clientID				  	
		, @fiscalYearID               
		, @assetID                    
		, @assetType                 	
		, @placedInServiceOn         	
		, @yearsUseful               	
		, @depreciableCost           	
		, @fedResourceOrGrant			
		, @resourceCodeAcctNum       	
		, @annualDepreciation        	
		, @retiredDuringCostPeriod   	
		, @placedOutOfServiceOn      	
		, @accumulatedDepreciation   	
		, @depreciationForReportPeriod 	
		, @today
		, @userID
	)	

	Set @recordID = SCOPE_IDENTITY()
  end

  else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
  begin	

  	Update dbo.CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS Set
		  clientID				  	  = @clientID				  
		, fiscalYearID                = @fiscalYearID               
		, assetID                     = @assetID                    
		, assetType                   = @assetType                 
		, placedInServiceOn           = @placedInServiceOn         
		, yearsUseful                 = @yearsUseful               
		, depreciableCost             = @depreciableCost           
		, fedResourceOrGrant		  = @fedResourceOrGrant		
		, resourceCodeAcctNum         = @resourceCodeAcctNum       
		, annualDepreciation          = @annualDepreciation        
		, retiredDuringCostPeriod     = @retiredDuringCostPeriod   
		, placedOutOfServiceOn        = @placedOutOfServiceOn      
		, accumulatedDepreciation     = @accumulatedDepreciation   
		, depreciationForReportPeriod = @depreciationForReportPeriod		  	
		, lastModified                = @today                
		, lastModifiedBy			  = @userID
	Where (id = @recID)	

	Set @recordID = @recID 
  end



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
 
GRANT EXECUTE ON  [dbo].[CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_SAVE] TO [webuser]
GO
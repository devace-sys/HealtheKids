USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_OTHER_COSTS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_OTHER_COSTS_SAVE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[CRCS_OTHER_COSTS_SAVE] (
    @userID                       Bigint
  , @userGroup                    Int
  , @userRank                     Int 
  , @clientID					  Bigint
  , @fiscalYearID                 Bigint
  , @grpSvcClassNameID		      Bigint
  , @materialsAndSupplies   	  Money
  , @nonCapitalizedEquipment	  Money
  , @travelAndConference		  Money
  , @duesAndMembership			  Money
  , @communications				  Money
  , @otherFederalCosts			  Money
  , @federalResourceCodes	      varchar(50)
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
DECLARE @processedRecID      as Bigint

BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @spDetails  = ''    
SET @recordID = 0 
SET @today    = GETDATE()

select Top 1  @processedRecID = id from dbo.CRCS_OTHER_COSTS where grpSvcClassNameID = @grpSvcClassNameID and clientID = @clientID and fiscalYearID = @fiscalYearID
  
SET @saveType = iif(@processedRecID is not null
				  , dbo.CONST_SAVE_TYPE_EDIT(), dbo.CONST_SAVE_TYPE_NEW())

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
IF (@grpSvcClassNameID IS NULL)			    RAISERROR ('Group Service Class Name ID required',       11, 1)    
IF (@fiscalYearID      IS NULL)				RAISERROR ('Fiscal Year is required', 11, 1)   

IF not exists (
	select top 1
		t1.GROUP_ID
	from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as t1
	where 
	t1.GROUP_SERVICE_CLASS_PARTITION_ID = 600 
	and t1.GROUP_SERVICE_CLASS_NAME_ID = @grpSvcClassNameID
)
begin
	RAISERROR('Invalid group service class name', 11, 1)
end
IF (@materialsAndSupplies     < 0
 or	@nonCapitalizedEquipment  < 0
 or	@travelAndConference	  < 0
 or	@duesAndMembership		  < 0
 or	@communications			  < 0
 or	@otherFederalCosts		  < 0) RAISERROR ('Dollar amount cannot be negative', 11, 1)       


IF ((isnull(@otherFederalCosts,0) != 0) and (@federalResourceCodes is null))
begin		
	RAISERROR('Federal Resource Codes required', 11, 1)
end

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
	Insert into dbo.CRCS_OTHER_COSTS (
		  clientID	
		, fiscalYearID			 
		, grpSvcClassNameID                
		, materialsAndSupplies      
		, nonCapitalizedEquipment
		, travelAndConference	 
		, duesAndMembership		 
		, communications		 
		, otherFederalCosts		 
		, federalResourceCodes	 
		, created                
		, createdBy
	) values (
	      @clientID	
		, @fiscalYearID			
		, @grpSvcClassNameID                
		, @materialsAndSupplies      
	    , @nonCapitalizedEquipment
	    , @travelAndConference	
	    , @duesAndMembership		
	    , @communications			
	    , @otherFederalCosts		
	    , @federalResourceCodes	
		, @today
		, @userID
	)	

	Set @recordID = SCOPE_IDENTITY()
  end

  else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
  begin	

  	Update dbo.CRCS_OTHER_COSTS Set
		  clientID				  = @clientID
		, fiscalYearID            = @fiscalYearID				
		, grpSvcClassNameID       = @grpSvcClassNameID                
		, materialsAndSupplies    = @materialsAndSupplies   
		, nonCapitalizedEquipment = @nonCapitalizedEquipment
		, travelAndConference	  = @travelAndConference	
		, duesAndMembership		  = @duesAndMembership		
		, communications		  = @communications			
		, otherFederalCosts		  = @otherFederalCosts		
		, federalResourceCodes	  = @federalResourceCodes	
		, lastModified            = @today                
		, lastModifiedBy		  = @userID
	Where (id = @processedRecID)	

	Set @recordID = @processedRecID 
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
 
GRANT EXECUTE ON  [dbo].[CRCS_OTHER_COSTS_SAVE] TO [webuser]
GO
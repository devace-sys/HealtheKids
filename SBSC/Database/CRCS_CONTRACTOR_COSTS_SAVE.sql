USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_CONTRACTOR_COSTS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_CONTRACTOR_COSTS_SAVE
GO
 
/*****************************************************************************************************
* IMPORTANT
* 
* For employee relationship, we are NOT going based off "dbo.EMPLOYMENT_RELATIONSHIPS"
* Instead we have: 
*      10: Employee
*      20: Contractor
*      30: Not on TSP
*      40: Duplicate
******************************************************************************************************/

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[CRCS_CONTRACTOR_COSTS_SAVE] (
    @userID                       Bigint
  , @userGroup                    Int
  , @userRank                     Int 
  , @clientID                     Bigint 
  , @pracID                       Bigint
  , @fiscalYearID                 Bigint
  , @employeeRelationshipID       Bigint
  , @contractorCosts5800          Money
  , @contractorCosts5100          Money
  , @contractRatePerHour          Money
  , @federalResourceAmounts       Money
  , @federalResourceCodes         Varchar(50)
  , @notes                        Varchar(max)
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

SELECT top 1
	@processedRecID = id
from dbo.CRCS_CONTRACTOR_COSTS where clientID = @clientID and pracID = @pracID and fiscalYearID = @fiscalYearID and active = 1

SET @saveType = iif(@processedRecID is not null
				  , dbo.CONST_SAVE_TYPE_EDIT(), dbo.CONST_SAVE_TYPE_NEW())

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
 
IF (@userID					 IS NULL) RAISERROR ('userID is required',      11, 1)      
IF (@userGroup				 IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank				 IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec			 IS NULL) RAISERROR ('Validate flag required',  11, 1) 
IF (@clientID				 IS NULL) RAISERROR ('Invalid Client ID',       11, 1)    
IF (@pracID					 IS NULL) RAISERROR ('Prac ID required',        11, 1)
IF (@contractorCosts5800   	 < 0
 or @contractorCosts5100   	 < 0
 or	@contractRatePerHour   	 < 0
 or	@federalResourceAmounts	 < 0)     RAISERROR ('Dollar amount cannot be negative', 11, 1)

-- validate prac and client combo
IF not exists (
	select top 1 
		  clc.CLIENT_ID
		, prp.PRACTITIONER_ID 
	from dbo.CLIENTS_CLIENT as clc
	join dbo.PRACTITIONER_Client as prc on prc.CLIENT_ID = clc.CLIENT_ID
	join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
	where ( 
		(clc.CLIENT_ID = @clientID)
	and (prp.PRACTITIONER_ID = @pracID)
	)
)
begin
	RAISERROR('Invalid client or practitioner ID', 11, 1)
end

IF (@fiscalYearID IS NULL) RAISERROR ('Fiscal Year is required', 11, 1)

IF (@employeeRelationshipID not in (10, 20, 30)) RAISERROR ('Invalid employee relationship', 11, 1)    

-- custom validation
IF (@employeeRelationshipID = 20)
begin
	IF ( -- allow everything to be null if notes is passed
		isnull(@contractorCosts5800    , 0) = 0
	and	isnull(@contractorCosts5100    , 0) = 0
	and	isnull(@contractRatePerHour    , 0) = 0
	and	isnull(@federalResourceAmounts , 0) = 0
	)
	begin
		IF (isnull(TRIM(@notes), '') = '') RAISERROR('Either notes or input data is required', 11, 1)
	end
	else
	begin
		IF (isnull(@contractorCosts5800,0) = 0 and isnull(@contractorCosts5100,0) = 0) RAISERROR('Contractor costs 5100 and/or 5800 are required', 11, 1)
		IF (isnull(@contractRatePerHour,0) = 0) RAISERROR('Rate per hour is is required', 11, 1)
		IF ((isnull(@federalResourceAmounts,0) != 0) and (@federalResourceCodes is null)) RAISERROR('Federal resource code is required', 11, 1)
	end
end

IF (@employeeRelationshipID = 10)
begin
	if (not exists (select top 1 pracID from dbo.CRCS_PRAC_SALARIES_UNION_VIEW(@clientID, @fiscalYearID, @pracID, null, 10))) RAISERROR('Practitioner is either not on RMTS roster or their relationship status is NOT "Employee" in salary tab', 11, 1)	
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

 -- if changing employee relationship to employee, remove any records of that practitioner (set to contractor) in salary tab
 -- if (@employeeRelationshipID = 10)
 -- begin
 --   if (@fiscalYearID <= 26)
	--begin
	--	update dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY
	--	set active = 0
	--	where clientID = @clientID and fiscalYearID = @fiscalYearID  and pracID = @pracID and employeeRelationshipID = 20
	--end
	--else
	--begin
	--	update dbo.CRCS_PRAC_SALARIES
	--	set active = 0
	--	where clientID = @clientID and fiscalYearID = @fiscalYearID  and pracID = @pracID and employeeRelationshipID = 20
	--end
 -- end

  if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
  begin
	Insert into dbo.CRCS_CONTRACTOR_COSTS (
		  clientID
		, pracID 
		, fiscalYearID
		, employeeRelationshipID            
		, contractorCosts5800 
		, contractorCosts5100
		, contractRatePerHour
		, federalResourceAmounts
		, federalResourceCodes
		, notes                    
		, created                
		, createdBy
	) values (
	      @clientID 
		, @pracID  
		, @fiscalYearID  
		, @employeeRelationshipID               
	    , @contractorCosts5800 
		, @contractorCosts5100
		, @contractRatePerHour
		, @federalResourceAmounts
		, @federalResourceCodes
		, @notes                 
		, @today
		, @userID
	)
	
	Set @recordID = SCOPE_IDENTITY()
	
  end

  else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
  begin	
  	Update dbo.CRCS_CONTRACTOR_COSTS Set
		  clientID                    = @clientID                  
		, pracID                   	  = @pracID 
		, fiscalYearID                = @fiscalYearID
		, employeeRelationshipID      = @employeeRelationshipID
		, contractorCosts5800         = @contractorCosts5800   
		, contractorCosts5100         = @contractorCosts5100
		, contractRatePerHour         = @contractRatePerHour
		, federalResourceAmounts      = @federalResourceAmounts
		, federalResourceCodes        = @federalResourceCodes
		, notes                       = @notes                                  
		, lastModified                = @today                
		, lastModifiedBy			  = @userID
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
 
GRANT EXECUTE ON  [dbo].[CRCS_CONTRACTOR_COSTS_SAVE] TO [webuser]
GO
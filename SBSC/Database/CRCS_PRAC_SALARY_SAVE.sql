USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_SALARY_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_PRAC_SALARY_SAVE
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
 
CREATE PROCEDURE [dbo].[CRCS_PRAC_SALARY_SAVE] (
    @userID                       Bigint
  , @userGroup                    Int
  , @userRank                     Int 
  , @clientID                     Bigint 
  , @pracID                       Bigint
  , @fiscalYearID			      BigInt
  , @quarterNumber                Int
  , @employeeRelationshipID       Int

  --, @hoursWorkedThisQuarter       Money

  , @salary                       Money
  , @federalSalary				  Money
  , @federalSalaryResourceCode 	  Varchar(50)
  , @benefits                  	  Money
  , @federalBenefits           	  Money
  , @federalBenefitsResourceCode  Varchar(50)
  , @clientEmployeeID             Varchar(500)
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

select top 1 
	@processedRecID = id 
from dbo.CRCS_PRAC_SALARIES
where (clientID = @clientID and pracID = @pracID and quarterNumber = @quarterNumber and fiscalYearID = @fiscalYearID and active = 1)

SET @saveType = iif(@processedRecID is not null
				  , dbo.CONST_SAVE_TYPE_EDIT(), dbo.CONST_SAVE_TYPE_NEW())


-- very nonstandard here; the RESTVIEW isn't submitting the recID on save, 
-- because it isn't fetching the recID on load, because the underlying
-- callstack of the view UDF doesn't return the recID per-row, even though one exists.



/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
 
IF (@userID        IS NULL)			    RAISERROR ('userID is required',      11, 1)      
IF (@userGroup     IS NULL)			    RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank      IS NULL)			    RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL)			    RAISERROR ('Validate flag required',  11, 1) 
IF (@clientID      IS NULL)				RAISERROR ('Invalid Client ID',       11, 1)    
IF (@pracID        IS NULL)			    RAISERROR ('Prac ID required',        11, 1)

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

IF (dbo.IS_VALID_FY_ID_AND_QTR_NUM(@fiscalYearID, @quarterNumber) = 0)   RAISERROR ('Invalid fiscal year or quarter number', 11, 1)
IF (@salary           < 0        
 or	@federalSalary	  <	0		
 or	@benefits         < 0        
 or	@federalBenefits  < 0 ) RAISERROR ('Dollar amount cannot be negative', 11, 1)       

-- custom CRCS validation
IF (@employeeRelationshipID not in (10, 20, 30, 40)) RAISERROR ('Invalid employee relationship', 11, 1)   

IF (@employeeRelationshipID = 10)
begin
	IF ((isnull(@salary, 0) = 0) or (isnull(@benefits, 0) = 0))
	begin
		RAISERROR('Salary and Benefits are required', 11, 1)
	end

	IF ((isnull(@federalSalary,0) != 0) and (@federalSalaryResourceCode is null))
	begin
		RAISERROR('Federal salary resource code required', 11, 1)
	end

	IF ((isnull(@federalBenefits,0) != 0) and (@federalBenefitsResourceCode is null))
	begin
		RAISERROR('Federal benefits resource code required', 11, 1)
	end
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
	Insert into dbo.CRCS_PRAC_SALARIES (
		  clientID
		, pracID 
		, fiscalYearID
		, quarterNumber 
		, employeeRelationshipID

		--, hoursWorkedThisQuarter 
                 		                
		, salary                     
		, federalSalary				
		, federalSalaryResourceCode 
		, benefits                  
		, federalBenefits           
		, federalBenefitsResourceCode
		, created                
		, createdBy
	) values (
	      @clientID 
		, @pracID  
		, @fiscalYearID
		, @quarterNumber
 		, @employeeRelationshipID

		--, @hoursWorkedThisQuarter
                                  
	    , @salary                     
	    , @federalSalary				
	    , @federalSalaryResourceCode 
	    , @benefits                  
	    , @federalBenefits           
	    , @federalBenefitsResourceCode
		, @today
		, @userID
	)
	
	Set @recordID = SCOPE_IDENTITY()
	
  end

  else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
  begin
  	Update dbo.CRCS_PRAC_SALARIES Set
		  clientID                    = @clientID                  
		, pracID                   	  = @pracID 
		, fiscalYearID                = @fiscalYearID
		, quarterNumber               = @quarterNumber
		, employeeRelationshipID      = @employeeRelationshipID

        --, hoursWorkedThisQuarter      = @hoursWorkedThisQuarter

		, salary                      = @salary                     
		, federalSalary				  = @federalSalary				
		, federalSalaryResourceCode   = @federalSalaryResourceCode 
		, benefits                    = @benefits                  
		, federalBenefits             = @federalBenefits           
		, federalBenefitsResourceCode = @federalBenefitsResourceCode
		, lastModified                = @today                
		, lastModifiedBy			  = @userID
	Where (id = @processedRecID)
	
	Set @recordID = @processedRecID 	
  end

  -- update employee relationship id
  update dbo.PRACTITIONER_Practitioner
  set clientEmployeeID = @clientEmployeeID
  where PRACTITIONER_ID = @pracID

        -- DO!!!!
        -- and CLIENT_ID = @clientID, etc -- ??


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
 
GRANT EXECUTE ON  [dbo].[CRCS_PRAC_SALARY_SAVE] TO [webuser]
GO
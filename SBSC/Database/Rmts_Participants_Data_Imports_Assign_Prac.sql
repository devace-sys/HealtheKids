USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Rmts_Participants_Data_Imports_Assign_Prac') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Rmts_Participants_Data_Imports_Assign_Prac
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[Rmts_Participants_Data_Imports_Assign_Prac] (
    @userID                       Bigint
  , @userGroup                    Int
  , @userRank                     Int 
  , @pracID                       Bigint
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
declare @clientID            as bigint
declare @processingRmtsPracID                       bigint
	  , @processingRmtsRosterID					    bigint
	  , @processingRmtsStartDate					date
	  , @processingRmtsEndDate					    date
	  , @processingRmtsReasonForStartDateChangeCode int
	  , @processingRmtsReasonForEndDateChangeCode	int
	  , @processingRmtsHasServiceRecords			bit
	  , @processingRmtsHasReimbursement			    bit      
	  , @processingRmtsSaveType                     int
	  , @processingRmtsRecID						bigint					 


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
 
IF (@userID					 IS NULL) RAISERROR ('userID is required',           11, 1)      
IF (@userGroup				 IS NULL) RAISERROR ('userGroup is required',        11, 1)    
IF (@userRank				 IS NULL) RAISERROR ('userRank is required',         11, 1)    
IF (@validateRec			 IS NULL) RAISERROR ('Validate flag required',       11, 1) 
IF (@pracID					 IS NULL) RAISERROR ('Prac ID required',             11, 1)
IF (@saveType				 IS NULL) RAISERROR ('Save type is required',        11, 1) 
-- check for pcal staff (only our staff can call this SPROC)
IF (not exists (select id from users.dbo.users_all as ua where ua.id = @userID and ua.pcalStaff = 1)) RAISERROR ('Unauthorized to perform this action', 11, 1) 
  
  
 
/*============================================================
 * Write data
 *============================================================*/  

BEGIN TRANSACTION    
 
	SET @TranOpen = 1     

	
	if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
	begin	
	/*-------------------------------
	* Init save parameters
	*------------------------------*/
	select top 1

		  @clientID								      = rpr.clientID

                  --  TODO: we need to be passing in the clientID via reqClientID or optClientID of the uInfo,
                  --  and then double-checking that the clientID of the row doesn't conflict with the passed-in @clientID.

                  -- Not done here, as this entire SPROC is outside of my deliverable/refactor.  Honestly I don't remember
                  -- what button, what screen, what URL this is called from.

		, @processingRmtsRosterID					  = rpr.id
		, @processingRmtsStartDate			          = iif(( -- ensure start date is between quarter start and end
															(rp.startDate is not null) 
														and (rp.startDate between fyq.QTR_START and fyq.QTR_END)
														), rp.startDate, fyq.QTR_START)
		, @processingRmtsEndDate					  = iif(( -- ensure start date is between quarter start and end
															(rp.endDate is not null) 
														and (rp.endDate between fyq.QTR_START and fyq.QTR_END)
														), rp.endDate  , fyq.QTR_END  )
		, @processingRmtsReasonForStartDateChangeCode = null
		, @processingRmtsReasonForEndDateChangeCode	  = null
														
		, @processingRmtsHasServiceRecords			  = rpv.hasServiceRecords
		, @processingRmtsHasReimbursement			  = rpv.hasReimbursement
		, @processingRmtsSaveType                     = iif(rpv.id is null, dbo.CONST_SAVE_TYPE_NEW(), dbo.CONST_SAVE_TYPE_EDIT())
		, @processingRmtsRecID						  = rpv.id

	from dbo.Rmts_Participants_Data_Imports_Pracs_Not_In_SpEdCare			   as rp
	join dbo.Rmts_Participants_Data_Imports									   as rpd on rpd.id = rp.rmtsDataImportID
	join dbo.RMTS_PARTICIPATION_ROSTER										   as rpr on rpr.quarterID = rpd.fyQuarterID and rpr.clientID = rpd.clientID
	join dbo.COMPANY_FISCAL_QUARTERS										   as fyq on fyq.ID = rpr.quarterID
	outer apply dbo.RMTS_PARTICIPANTS_VIEW_CORE(rpd.clientID, rpr.id, 1, @pracID) as rpv
	where rp.id = @recID	        



	/*-------------------------------
	 * Save to roster
	 *------------------------------*/
	
	declare @spDetailsRmtsPart as varchar(8000) = ''
    declare @recordIDRmtsPart  as bigint = 0

	exec [dbo].[RMTS_PARTICIPANTS_SAVE_CORE]
	  @userID                       
	, @userGroup                    
	, @userRank                     
	, @clientID                     
	, @pracID                       
	, @processingRmtsRosterID					  
	, @processingRmtsStartDate					  
	, @processingRmtsEndDate					  
	, @processingRmtsReasonForStartDateChangeCode 
	, @processingRmtsReasonForEndDateChangeCode   
	, @processingRmtsHasServiceRecords			  
	, @processingRmtsHasReimbursement 
	, null  -- employeeRelationshipID            
	, ''	-- editDelReason 
	, 0     -- validateRec             
	, @processingRmtsSaveType                     
	, @processingRmtsRecID                        
	, 'Record doesn''t exist'                        
	, 'Record not editable'                    
	, 'Duplicate record'                        
	, 'A data error occured'                 
	, 'Inactive Record'                     
	, @spDetailsRmtsPart output   
	, @recordIDRmtsPart  output 

  
	/*-------------------------------
	* Update actual record to indicate
	* it has been processed
	*------------------------------*/
	update dbo.Rmts_Participants_Data_Imports_Pracs_Not_In_SpEdCare
		set processedPracID = @pracID
		  , lastModified      = getdate()
          , lastModifiedBy    = @userID
	where id = @recID
  end
  else
  begin
	RAISERROR('Unsupported save type', 11, 2)
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
 
GRANT EXECUTE ON  [dbo].[Rmts_Participants_Data_Imports_Assign_Prac] TO [webuser]
GO
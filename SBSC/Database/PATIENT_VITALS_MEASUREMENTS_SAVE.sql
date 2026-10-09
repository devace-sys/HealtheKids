USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VITALS_MEASUREMENTS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_VITALS_MEASUREMENTS_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENT_VITALS_MEASUREMENTS_SAVE] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT      
  , @clientID            BIGINT
  , @patID				 BIGINT 
  ,	@temp				 DECIMAL(5,1)
  ,	@pulseRate			 SMALLINT
  ,	@respiratoryRate	 SMALLINT 
  ,	@bloodPressureSys	 SMALLINT 
  ,	@bloodPressureDia	 SMALLINT 
  ,	@o2Saturation		 SMALLINT 
  , @bloodGlucose		 SMALLINT
  ,	@heightFt			 SMALLINT
  ,	@heightInch			 DECIMAL(5,2)
  ,	@weightlb			 DECIMAL(5,1) 
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT
  , @saveType            INT
  , @recID               BIGINT
  , @MsgNoRec            VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgDupRec           VARCHAR(1000)
  , @MsgDataError        VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)
  , @spDetails           VARCHAR(8000) OUTPUT
  , @recordID            BIGINT        OUTPUT )    
AS    
BEGIN     
    
/***************************************************************************    
 * PATIENT_VITALS_MEASUREMENTS_SAVE */    
/**    
 * Creates new or edits existing
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
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

DECLARE @today              AS  DATETIME       -- Current date/time stamp    
DECLARE @tranOpen           AS  BIT            -- Is a transaction open    
declare @measurementDate    AS	DATE
declare @measurmentTime	AS  TIME(0)

BEGIN TRY

/*============================================================
 * Init output parameters
 *===========================================================*/  
    
SET @recordID        = 0    
SET @spDetails       = ''    
SET @today           = GETDATE()    
set @measurementDate = convert(date,@today)
set @measurmentTime  = convert(time(0),@today)

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*============================================================
 * See if the clientid is valid
 *============================================================*/  

if not exists (
  select top 1 
    numOf = 1 
  from dbo.CLIENTS_Client   as cc   
  where cc.CLIENT_ID        = @clientID 
)
begin
  RAISERROR ('Invalid client', 11, 1)
end

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
  
  /*-------------------------------
   * Create Patient Vitals Measurement
   * record.
   *------------------------------*/ 

  insert into dbo.PATIENT_VITALS_MEASUREMENTS (   
        [clientID] 
      , [patID]
	  ,	[measurementDate]
	  ,	[measurmentTime]
	  ,	[temp]
	  ,	[pulseRate]
	  ,	[respiratoryRate] 
	  ,	[bloodPressureSys] 
	  ,	[bloodPressureDia] 
	  ,	[o2Saturation] 
	  , [bloodGlucose]
	  ,	[heightFt]
	  ,	[heightInch]
	  ,	[weightlb]
	  , [created]
	  ,	[createdBy]
  ) 
  values (
      @clientID
    , @patID
    , @measurementDate
    , @measurmentTime
    , @temp
    , @pulseRate
    , @respiratoryRate
    , @bloodPressureDia
    , @bloodPressureSys
	, @o2Saturation
	, @bloodGlucose
	, @heightFt
	, @heightInch
	, @weightlb
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

  update dbo.PATIENT_VITALS_MEASUREMENTS
  set  
	    temp			   = @temp
	  ,	pulseRate		   = @pulseRate
	  ,	respiratoryRate    = @respiratoryRate
	  ,	bloodPressureSys   = @bloodPressureSys
	  ,	bloodPressureDia   = @bloodPressureDia
	  ,	o2Saturation	   = @o2Saturation
	  , bloodGlucose	   = @bloodGlucose	
	  ,	heightFt		   = @heightFt
	  ,	heightInch		   = @heightInch
	  ,	weightlb           = @weightlb
	  , lastModified       = @today
      , lastModifiedBy     = @userID
 
  where ((clientID = @clientID) and (id = @recID))
  
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

GRANT EXECUTE ON  [dbo].[PATIENT_VITALS_MEASUREMENTS_SAVE] TO [webuser]
GO

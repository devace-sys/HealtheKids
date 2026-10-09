USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PERSONS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PERSONS_SAVE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[PATIENT_PERSONS_SAVE] (
  @userID              BIGINT,
  @userGroup           INT,
  @userRank            INT,
  @clientID            BIGINT,
  @patientID           BIGINT,    
  @CLASS_ID_1          BIGINT,
  @CLASS_ID_2          BIGINT,
  @LAST_NAME           varchar(255),
  @FIRST_NAME          varchar(255),
  @MIDDLE_NAME         varchar(255),
  @PHONE               varchar(255),
  @FAX                 varchar(255),
  @EMAIL               varchar(255),
  @ADDRESS_1           varchar(1000),
  @ADDRESS_2           varchar(1000),
  @CITY                varchar(100),
  @STATE               varchar(2),
  @ZIP_5               varchar(5),
  @ZIP_4               varchar(4),      
  @ADDITIONAL_DATA_1   varchar(1000),
  @ADDITIONAL_DATA_2   varchar(1000),  
  @editDelReason       VARCHAR(7000),    
  @validateRec         BIT,    
  @saveType            INT,    
  @recID               INT,    
  @MsgNoRec            VARCHAR(1000),    
  @MsgNoEdit           VARCHAR(1000), 
  @MsgDupRec           VARCHAR(1000),     
  @MsgDataError        VARCHAR(1000),
  @MsgNotActive        VARCHAR(1000),     
  @spDetails           VARCHAR(8000) OUTPUT,    
  @recordID            BIGINT        OUTPUT)    
AS    
BEGIN     
 
/***************************************************************************    
 * PATIENT_PERSONS_SAVE */    
/**    
 * Creates a new 
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
 
DECLARE @updateState         as smallint      -- Indicates what state the record is left in    
DECLARE @today               as datetime
DECLARE @TranOpen            as bit
declare @personIDIn          as bigint
declare @personIDOut         as bigint

/*-------------------------------    
 * Init 
 *------------------------------*/    

set @today      = getdate()
set @spDetails  = ''    
set @recordID   = NULL 
set @personIDIn = null
set @personIDOut = null

BEGIN TRY    
   
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
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*-------------------------------    
 * Lookup
 *------------------------------*/    

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  
  set @recordID = null
  
  select top 1   
      @personIDIn = patp.PERSON_ID 
    , @recordID   = patp.ID
  from dbo.PATIENTS_PERSON as patp
  where (
        (patp.CLIENT_ID  = @clientID)
    and (patp.PATIENT_ID = @patientID)
    and (patp.ID         = @recID)
  )
  
  if (@recordID is null)
  begin
    RAISERROR (@MsgNoRec , 11, 1)    
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
    
  EXEC dbo.PERSONS_SAVE_CORE 
    @userID              
  , @userGroup
  , @userRank
  , @today 
  , @CLASS_ID_1
  , @CLASS_ID_2
  , @LAST_NAME
  , @FIRST_NAME
  , @MIDDLE_NAME
  , null
  , null
  , null
  , @PHONE
  , @FAX
  , @EMAIL
  , @ADDRESS_1
  , @ADDRESS_2
  , @CITY
  , @STATE
  , @ZIP_5
  , @ZIP_4
  , @ADDITIONAL_DATA_1   
  , @ADDITIONAL_DATA_2   
  , @editDelReason     
  , @validateRec       
  , @saveType          
  , @personIDIn
  , @MsgNoRec          
  , @MsgNoEdit         
  , @MsgDupRec         
  , @MsgDataError      
  , @MsgNotActive        
  , @spDetails         OUTPUT    
  , @personIDOut       OUTPUT
       
if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin
  insert into dbo.PATIENTS_PERSON 
  (
      CLIENT_ID
    , PATIENT_ID
    , PERSON_ID
    , START_DATE
    , END_DATE
    , CREATED_BY
    , CREATED_ON
    , ACTIVE 
  )
  values
  (
      @clientID
    , @patientID
    , @personIDOut
    , convert(date,@today)
    , null
    , @userID
    , @today 
   ,1
  )
  
  set @recordID = SCOPE_IDENTITY()
  
end
else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  UPDATE dbo.PATIENTS_PERSON 
  set
      LAST_MODIFIED_BY = @userID
    , LAST_MODIFIED_ON = @today
  where (ID = @personIDIn)

end
else
begin
  RAISERROR ('Unknown or unsupported save type', 11, 1)             
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
 
GRANT EXECUTE ON  [dbo].[PATIENT_PERSONS_SAVE] TO [webuser]
GO
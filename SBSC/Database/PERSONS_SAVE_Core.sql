USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PERSONS_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PERSONS_SAVE_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[PERSONS_SAVE_CORE] (
  @userID              BIGINT,
  @userGroup           INT,
  @userRank            INT,   
  @today               DATETIME,
  @CLASS_ID_1          BIGINT,
  @CLASS_ID_2          BIGINT,
  @LAST_NAME           varchar(255),
  @FIRST_NAME          varchar(255),
  @MIDDLE_NAME         varchar(255),
  @GENDER              varchar(255),
  @DATE_OF_BIRTH       date,
  @DATE_OF_DEATH       date,
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
  @recID               BIGINT,    
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
 * PERSONS_SAVE_CORE */    
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
 
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in    

BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @spDetails  = ''    
SET @recordID = NULL 
  
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
IF (@today       IS NULL) RAISERROR ('Value for today is required', 11,1) 

/*-------------------------------    
 * Clean up name
 *------------------------------*/    

set @LAST_NAME   = isnull  (@LAST_NAME,'')
set @FIRST_NAME  = isnull  (@FIRST_NAME,'')
set @MIDDLE_NAME = isnull  (@MIDDLE_NAME,'')

set @LAST_NAME   = replace (@LAST_NAME,    '''', '`')
set @FIRST_NAME  = replace (@FIRST_NAME,   '''', '`')
set @MIDDLE_NAME = replace (@MIDDLE_NAME,  '''', '`')

/*-------------------------------    
 * If edit lookup
 *------------------------------*/    

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  
  set @recordID = null
    
  select top 1   
    @recordID   = pp.ID
  from dbo.PERSONS_PERSON as pp
  where (ID = @recID)
  
  if (@recordID is null)
  begin
    RAISERROR (@MsgNoRec , 11, 1)    
  end

end

/*-------------------------------    
 * If new lookup.  We want to 
 * reuse existing records
 *------------------------------*/    

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  set @recID = dbo.PERSONS_FIND_EXISTING (@LAST_NAME, @FIRST_NAME, @EMAIL, @PHONE, @CLASS_ID_1, @CLASS_ID_2)
  
  if (@recID is not null) /* If something might have been found */
  begin
    if (@recID != -99) /* Enough was passed to find something */
	begin
	  set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
	end
	else
	begin
      RAISERROR ('Not enough unique information about this person was provided.  You must provide at least a last name and first name and either a email or phone', 11,1) 	  
	end
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

/*==============================    
 * New Record
 *==============================*/ 

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN       
  
   INSERT INTO dbo.PERSONS_PERSON (
       CLASS_ID_1
	 , CLASS_ID_2
     , LAST_NAME
	 , FIRST_NAME
	 , MIDDLE_NAME
	 , GENDER
	 , DATE_OF_BIRTH
	 , DATE_OF_DEATH
	 , PHONE
	 , FAX
	 , EMAIL
	 , ADDRESS_1
	 , ADDRESS_2
	 , CITY
	 , [STATE]
	 , ZIP_5
	 , ZIP_4
	 , ADDITIONAL_DATA_1
	 , ADDITIONAL_DATA_2
     , CREATED_BY
     , CREATED_ON
     , LAST_MODIFIED_BY
     , LAST_MODIFIED_ON
     , ACTIVE         
   )    
   VALUES (
      @CLASS_ID_1
    , @CLASS_ID_2
    , @LAST_NAME
	, @FIRST_NAME
	, @MIDDLE_NAME
	, @GENDER
	, @DATE_OF_BIRTH
	, @DATE_OF_DEATH
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
    , @userID
    , @today
	, null
	, null
    , 1         
  )  
 
  SET @recordID = SCOPE_IDENTITY()
 
END       
 
/*==============================    
 * Edit Record
 *==============================*/ 
 
ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN      
  
  SET @recordID = @recID  
 
  UPDATE dbo.PERSONS_PERSON 
  SET 
      CLASS_ID_1        = @CLASS_ID_1
    , CLASS_ID_2        = @CLASS_ID_2
    , LAST_NAME         = @LAST_NAME
    , FIRST_NAME        = @FIRST_NAME
	, MIDDLE_NAME       = @MIDDLE_NAME
	, GENDER            = @GENDER
	, DATE_OF_BIRTH     = @DATE_OF_BIRTH
	, DATE_OF_DEATH     = @DATE_OF_DEATH
	, PHONE             = @PHONE
	, FAX               = @FAX
	, EMAIL             = @EMAIL
	, ADDRESS_1         = @ADDRESS_1
	, ADDRESS_2         = @ADDRESS_2
	, CITY              = @CITY
	, [STATE]           = @STATE
	, ZIP_5             = @ZIP_5
	, ZIP_4             = @ZIP_4
    , ADDITIONAL_DATA_1 = @ADDITIONAL_DATA_1
    , ADDITIONAL_DATA_2 = @ADDITIONAL_DATA_2
    , LAST_MODIFIED_BY  = @userID
    , LAST_MODIFIED_ON  = @today      
   
  WHERE (ID = @recordID)  
 END
 ELSE
 BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)             
 END
 
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
 
RETURN(0)    
END TRY    
BEGIN CATCH    
 
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Return any    
   * error messages to the caller    
   *------------------------------*/    
 
  -- Error or raise error with severity 11 to 19 will be caught here    
  
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
 
GRANT EXECUTE ON  [dbo].[PERSONS_SAVE_CORE] TO [webuser]
GO
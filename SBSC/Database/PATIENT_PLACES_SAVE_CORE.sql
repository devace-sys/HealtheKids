USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PLACES_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PLACES_SAVE_CORE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENT_PLACES_SAVE_CORE] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT    
  , @CLIENT_ID         BIGINT
  , @PATIENT_ID        BIGINT
  , @NAME                            varchar(500)
  , @PATIENT_PLACE_TYPE              bigint        /* Home,  */
  , @PLACE_FORMAT_TYPE               bigint
  , @PLACE_SOURCE_TYPE               bigint
  , @ADDRESS_1                       varchar(1000)
  , @ADDRESS_2                       varchar(1000)
  , @CITY                            varchar(100)
  , @STATE                           varchar(2)
  , @ZIP_5                           varchar(5)
  , @ZIP_4                           varchar(4)
  , @LATITUDE                        decimal(9,6)
  , @LONGITUDE                       decimal(9,6)
  , @START_DATE                      date
  , @END_DATE                        date
  , @editDelReason     VARCHAR(7000)
  , @validateRec       BIT
  , @saveType          INT    
  , @recID             BIGINT    
  , @MsgNoRec          VARCHAR(1000)
  , @MsgNoEdit         VARCHAR(1000) 
  , @MsgDupRec         VARCHAR(1000)     
  , @MsgDataError      VARCHAR(1000)
  , @MsgNotActive      VARCHAR(1000)     
  , @spDetails         VARCHAR(8000) OUTPUT
  , @recordID          BIGINT        OUTPUT
  , @recData1          varchar(255)  OUTPUT
  , @recData2          varchar(255)  OUTPUT
  , @recData3          varchar(255)  OUTPUT
  , @recData4          varchar(255)  OUTPUT

  
  )    
AS    
BEGIN     
    
/***************************************************************************    
 * PATIENT_PLACES_SAVE_CORE */    
/**    
 * Creates a new record or edits an exiting one
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

DECLARE @recCount            AS INT
DECLARE @today               as DATETIME
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in    

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @spDetails  = ''    
SET @recordID = NULL 
SET @recData1   = ''
SET @recData2   = ''    
SET @recData3   = ''
SET @recData4   = ''
SET @today    = GETDATE()

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

/* If this is an edit check to see if the record exists */

IF (
     ( @saveType = dbo.CONST_SAVE_TYPE_EDIT()  )
  OR ( @saveType = dbo.CONST_SAVE_TYPE_DELETE())
)
BEGIN
 
  set @recordID = null     

  select top 1
    @recordID = id
  from dbo.PATIENT_PLACES
  where ((ID = @recID) and (ACTIVE = 1))
  
  if (@recordID is null) RAISERROR ('Record not found', 11, 1) 

END

/*-------------------------------    
 * Validation    
 *------------------------------*/    
        
IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        

        
/*==============================    
 * New Record
 *==============================*/    
  
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN       
           
    INSERT INTO dbo.PATIENT_PLACES (
      CLIENT_ID
    , PATIENT_ID    
    , NAME
    , PATIENT_PLACE_TYPE
    , PLACE_FORMAT_TYPE
    , PLACE_SOURCE_TYPE
    , ADDRESS_1
    , ADDRESS_2
    , CITY
    , STATE
    , ZIP_5
    , ZIP_4
    , LATITUDE
    , LONGITUDE
    , START_DATE
    , END_DATE
    , CREATED_BY
    , CREATED_ON
    , LAST_MODIFIED_BY
    , LAST_MODIFIED_ON
    , ACTIVE
  )    
  VALUES (            
      @CLIENT_ID
    , @PATIENT_ID
    , @NAME
    , @PATIENT_PLACE_TYPE
    , @PLACE_FORMAT_TYPE
    , @PLACE_SOURCE_TYPE
    , @ADDRESS_1
    , @ADDRESS_2
    , @CITY
    , @STATE
    , @ZIP_5
    , @ZIP_4
    , @LATITUDE     
    , @LONGITUDE       
    , @START_DATE
    , @END_DATE
    , @userID
    , @today
    , null
    , null
    , 1 )
    
    SET @recordID = SCOPE_IDENTITY()
                             
 END       
  
/*==============================    
 * Edit Record
 *==============================*/ 
 
ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN    
     
    
  set @updateState = dbo.CONST_REC_STATE_MOD()
      
  UPDATE dbo.PATIENT_PLACES 
  set
      NAME               = @NAME
    , ADDRESS_1          = @ADDRESS_1
    , ADDRESS_2          = @ADDRESS_2
    , CITY               = @CITY
    , STATE              = @STATE
    , ZIP_5              = @ZIP_5
    , ZIP_4              = @ZIP_4
    , LATITUDE           = @LATITUDE
    , LONGITUDE          = @LONGITUDE
    , START_DATE         = @START_DATE
    , END_DATE           = @END_DATE
    , LAST_MODIFIED_BY   = @userID
    , LAST_MODIFIED_ON   = @today    
  where ((ID = @recordID) and (ACTIVE = 1))

 END
 
/*==============================    
 * Delete Record
 *==============================*/ 
 
ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_DELETE())
BEGIN    

set @updateState = dbo.CONST_REC_STATE_DEL()
UPDATE dbo.PATIENT_PLACES 
  set
      ACTIVE             = 0
    , START_DATE         = @START_DATE
    , END_DATE           = @END_DATE
    , LAST_MODIFIED_BY   = @userID
    , LAST_MODIFIED_ON   = @today    
  where ((ID = @recordID) and (ACTIVE = 1))

END 
ELSE
BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)             
 END
    
 
/*==============================    
 * Get place id
 *==============================*/ 

 select top 1
   @recData1 = placeID     
 from dbo.PATIENT_PLACES_VIEW_CORE (  @userID
                                    , @userGroup
                                    , @userRank
                                    , @CLIENT_ID
                                    , @PATIENT_ID
                                    , null
                                    , 1
                                    , @recordID ) as t1
 where (t1.id = @recordID)


/*-------------------------------    
 * If we reach this point    
 * everything is OK 
 *------------------------------*/    
    
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



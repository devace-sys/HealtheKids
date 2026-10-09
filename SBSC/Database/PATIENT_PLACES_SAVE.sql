USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PLACES_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PLACES_SAVE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENT_PLACES_SAVE] (
   @userID             BIGINT    
  ,@userGroup         INT   
  ,@userRank          INT    
  ,@clientID          BIGINT
  ,@patID             BIGINT
  ,@name              varchar(500)
  ,@address1          varchar(1000)
  ,@address2          varchar(1000)
  ,@city              varchar(100)
  ,@state             varchar(2)
  ,@zip5              varchar(5)
  ,@zip4              varchar(4)
  ,@editDelReason     VARCHAR(7000)
  ,@validateRec       BIT
  ,@saveType          INT    
  ,@recID             BIGINT    
  ,@MsgNoRec          VARCHAR(1000)
  ,@MsgNoEdit         VARCHAR(1000) 
  ,@MsgDupRec         VARCHAR(1000)     
  ,@MsgDataError      VARCHAR(1000)
  ,@MsgNotActive      VARCHAR(1000)     
  ,@spDetails         VARCHAR(8000) OUTPUT    
  ,@recordID          BIGINT        OUTPUT
  ,@recData1          varchar(255)  OUTPUT
  ,@recData2          varchar(255)  OUTPUT
  ,@recData3          varchar(255)  OUTPUT
  ,@recData4          varchar(255)  OUTPUT
)    
AS    
BEGIN     
    
/***************************************************************************    
 * PATIENT_PLACES_SAVE */    
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

declare  @PATIENT_PLACE_TYPE              bigint
declare  @PLACE_FORMAT_TYPE               bigint
declare  @PLACE_SOURCE_TYPE               bigint
declare  @LATITUDE                        decimal(9,6)
declare  @LONGITUDE                       decimal(9,6)
declare  @START_DATE                      date
declare  @END_DATE                        date

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

set @PATIENT_PLACE_TYPE = dbo.CONST_PATIENT_PLACE_TYPE_OTHER()
set @PLACE_FORMAT_TYPE  = dbo.CONST_PLACE_FORMAT_TYPE_NOT_SPECIFIED()
set @PLACE_SOURCE_TYPE  = dbo.CONST_PLACE_SOURCE_TYPE_MGMT_SCREEN()

/*-------------------------------    
 * Save record
 *------------------------------*/    

exec PATIENT_PLACES_SAVE_CORE 
   @userID            
  ,@userGroup         
  ,@userRank          
  ,@clientID         
  ,@patID        
  ,@name           
  ,@PATIENT_PLACE_TYPE 
  ,@PLACE_FORMAT_TYPE  
  ,@PLACE_SOURCE_TYPE  
  ,@address1        
  ,@address2
  ,@city          
  ,@state
  ,@zip5             
  ,@zip4             
  ,@LATITUDE          
  ,@LONGITUDE         
  ,@START_DATE        
  ,@END_DATE          
  ,@editDelReason     
  ,@validateRec       
  ,@saveType          
  ,@recID             
  ,@MsgNoRec          
  ,@MsgNoEdit         
  ,@MsgDupRec         
  ,@MsgDataError      
  ,@MsgNotActive      
  ,@spDetails         OUTPUT
  ,@recordID          OUTPUT
  ,@recData1          OUTPUT
  ,@recData2          OUTPUT
  ,@recData3          OUTPUT
  ,@recData4          OUTPUT
  
       
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

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PATIENT_PLACES_SAVE] TO [webuser]
GO



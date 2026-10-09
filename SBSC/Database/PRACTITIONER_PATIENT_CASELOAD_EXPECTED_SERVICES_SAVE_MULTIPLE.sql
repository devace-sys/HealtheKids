USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE] (
    @userID           BIGINT
  , @userGroup        INT   
  , @userRank         INT
  , @clientID         bigint
  , @pracID           bigint
  , @saveSelectedOnly bit = 0
  , @newSvcsJSON      varchar(max)
  , @editDelReason    VARCHAR(7000)
  , @validateRec      BIT
  , @saveType         INT
  , @recID            BIGINT
  , @MsgNoRec         VARCHAR(1000)
  , @MsgNoEdit        VARCHAR(1000)
  , @MsgDupRec        VARCHAR(1000)
  , @MsgDataError     VARCHAR(1000)
  , @MsgNotActive     VARCHAR(1000)
  , @spDetails        VARCHAR(8000) OUTPUT
  , @recordID         BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE */    
/**    
 * 
 * 
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @tranOpen      as bit          = 0    
declare @hasDataPPCES  as bit          = 0
declare @jsonDataPPCES as varchar(max) = '[]'

BEGIN TRY    
   
/*-------------------------------    
 * Init 
 *------------------------------*/    
   
set @recordID   = 0    
set @spDetails  = ''    
set @tranOpen   = 0   

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    

IF (@userID      IS NULL) RAISERROR ('userID is required',           11, 1)       
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',        11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',         11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',       11, 1)    
IF (@clientID    IS NULL) RAISERROR ('Client id is required',        11, 1)    
IF (@pracID      IS NULL) RAISERROR ('Practitioner id is required',  11, 1)    
      
BEGIN TRANSACTION    
   
  set @tranOpen = 1    
  
  /*############################################################################
   *# Call save multiple caseload entries routine 
   *############################################################################*/

  exec dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE_CORE 
    @userID
  , @userGroup
  , @userRank 
  , @clientID 
  , @pracID 
  , @saveSelectedOnly
  , @newSvcsJSON 
  , @editDelReason 
  , @validateRec 
  , @saveType 
  , @recID 
  , @MsgNoRec 
  , @MsgNoEdit 
  , @MsgDupRec 
  , @MsgDataError
  , @MsgNotActive
  , @spDetails     OUTPUT
  , @recordID      OUTPUT
  , @hasDataPPCES  OUTPUT
  , @jsonDataPPCES OUTPUT

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
   
  SET @ErrorMessage = @ErrorMessage
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE] TO [webuser]
GO

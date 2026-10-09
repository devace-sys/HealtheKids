USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_GET_JSON_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_GET_JSON_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_GET_JSON_CORE] (
    @userID              BIGINT
  , @userGroup           INT   
  , @userRank            INT
  , @clientID            bigint
  , @pracID              bigint
  , @patsCSV             varchar(max) = ''
  , @loadCurrentCaseload bit          = 0  
  , @hasData             bit           OUTPUT
  , @jsonData            varchar(max)  OUTPUT)

AS    
BEGIN    
   
/******************************************************************************    
 * PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_GET_JSON_CORE */    
/**    
 * 
 * 
 ******************************************************************************/        
     
SET NOCOUNT ON    
   
declare @newSvcsJSON as varchar(max)  = ''
declare @spDetails   as varchar(8000) = ''
declare @recordID    as bigint        = 0

BEGIN TRY    
   
/*-------------------------------    
 * Init 
 *------------------------------*/    
   
set @hasData    = 0
set @jsonData   = '[]'

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    

IF (@userID      IS NULL) RAISERROR ('userID is required',           11, 1)       
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',        11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',         11, 1)    
IF (@clientID    IS NULL) RAISERROR ('Client id is required',        11, 1)    
IF (@pracID      IS NULL) RAISERROR ('Practitioner id is required',  11, 1)    
      

/*############################################################################
 *# Call determine new services routine and put results in JSON
 *############################################################################*/

set @newSvcsJSON = convert (varchar(max),(
  select 
      t1.*
  from dbo.PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_VIEW_CORE (
      @userID  
    , @userGroup
    , @userRank 
    , @clientID 
    , @pracID 
    , @patsCsv
	, @loadCurrentCaseload
  ) as t1
  order by 
      t1.patName
    , t1.spEdServiceName
  for json auto
  
))

set @hasData  = 0
set @jsonData = isnull(@newSvcsJSON,'[]')
if (@jsonData != '[]') set @hasData = 1

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
   
  SET @ErrorMessage = @ErrorMessage
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_GET_JSON_CORE] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_AND_GET_NEW') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_AND_GET_NEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_AND_GET_NEW] (
    @userID                    BIGINT
  , @userGroup                 INT   
  , @userRank                  INT
  , @clientID                  bigint
  , @pracID                    bigint
  , @editDelReason             VARCHAR(7000)
  , @validateRec               BIT
  , @saveType                  INT
  , @recID                     bigint
  , @MsgNoRec                  VARCHAR(1000)
  , @MsgNoEdit                 VARCHAR(1000)
  , @MsgDupRec                 VARCHAR(1000)
  , @MsgDataError              VARCHAR(1000)
  , @MsgNotActive              VARCHAR(1000)
  , @spDetails                 VARCHAR(8000) OUTPUT
  , @recordID                  BIGINT        OUTPUT
  , @jsonData                  varchar(max)  OUTPUT)    
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL */    
/**    
 * Bulk updates practitoners caseloads that have SpEd plan associations
 * with any changed data that has been put into patient promised services   
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
declare @tranOpen        as bit          = 0
declare @hasNewSvcs      as bit          = 0 
declare @newSvcsJSON     as varchar(max) = '[]'
declare @patsCSV         as varchar(max) = ''
declare @numUpdates      as bigint       = 0
declare @numAutoAdds     as bigint       = 0
declare @numScheduleAdds as bigint       = 0
declare @hasDataPPCES    as bit          = 0
declare @jsonDataPPCES   as varchar(max) = '[]'

BEGIN TRY    
   
/*############################################################################
 *# Init
 *############################################################################*/
   
set @recordID     = 0    
set @spDetails    = ''    
set @tranOpen     = 0 

set @numUpdates   = 0
set @numAutoAdds  = 0
set @hasNewSvcs   = 0
set @newSvcsJSON  = '[]'

set @jsonData  = '{'
               + ' "numUpdates":'  + convert(varchar,@numUpdates)
               + ',"numAutoAdds":' + convert(varchar,@numAutoAdds)
			   + ',"hasNewSvcs":'  + convert(varchar,@hasNewSvcs)
			   + ',"newSvcs":'     + @newSvcsJSON
			   + '}'

/*############################################################################
 *# Verify parms required to ensure sproc works.
 *############################################################################*/

IF (@userID      IS NULL) RAISERROR ('userID is required',           11, 1)       
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',        11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',         11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',       11, 1)    
IF (@clientID    IS NULL) RAISERROR ('Client id is required',        11, 1)    
IF (@pracID      IS NULL) RAISERROR ('Practitioner id is required',  11, 1)    
      
BEGIN TRANSACTION    
   
  set @tranOpen = 1    

  /*############################################################################
   *# Update plan info.  We do this so we can have exact matching in find new svcs.
   *############################################################################*/

  exec dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_CORE 
      @userID 
    , @clientID
    , @pracID 
    , null -- @patID
    , null -- @spEdSvcCode
    , 0    -- @updateToNewerPlan 
    , @validateRec
    , @spDetails    OUTPUT
    , @numUpdates   OUTPUT

   set @jsonData  = '{'
                  + ' "numUpdates":'  + convert(varchar,@numUpdates)
                  + ',"numAutoAdds":' + convert(varchar,@numAutoAdds)
			      + ',"hasNewSvcs":'  + convert(varchar,@hasNewSvcs)
			      + ',"newSvcs":'     + @newSvcsJSON
			      + '}'

  /*############################################################################
   *# Find any new services for current caseload
   *############################################################################*/

  exec dbo.PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_GET_JSON_CORE
      @userID
    , @userGroup
    , @userRank 
    , @clientID 
    , @pracID 
    , @patsCSV
    , 1 -- @loadCurrentCaseload 
    , @hasNewSvcs  OUTPUT
    , @newSvcsJSON OUTPUT

   set @jsonData  = '{'
                  + ' "numUpdates":'  + convert(varchar,@numUpdates)
                  + ',"numAutoAdds":' + convert(varchar,@numAutoAdds)
			      + ',"hasNewSvcs":'  + convert(varchar,@hasNewSvcs)
			      + ',"newSvcs":'     + @newSvcsJSON
			      + '}'
  

  /*############################################################################
   *# Call save multiple caseload entries routine to save JUST the preselected
   *############################################################################*/

  exec dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE_CORE 
      @userID
    , @userGroup
    , @userRank 
    , @clientID 
    , @pracID 
    , 1 --@saveSelectedOnly
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
    , @numAutoAdds   OUTPUT
	, @hasDataPPCES  OUTPUT
	, @jsonDataPPCES OUTPUT

  set @jsonData  = '{'
                 + ' "numUpdates":'  + convert(varchar,@numUpdates)
                 + ',"numAutoAdds":' + convert(varchar,@numAutoAdds)
			     + ',"hasNewSvcs":'  + convert(varchar,@hasNewSvcs)
			     + ',"newSvcs":'     + @newSvcsJSON
			     + '}'

  /*############################################################################
   *# Create new schedule data (if applicable)
   *############################################################################*/
  
  if (@hasDataPPCES = 1)
  begin

    exec dbo.Practitioner_Patient_Scheduled_Services_Save_Multiple_Core 
        @userID 
      , @userGroup
      , @userRank 
      , @clientID 
      , @pracID   
      , @jsonDataPPCES                 
      , 1 -- @loadNewSvsFromPossibleNewFromExpSvcs
      , @validateRec
      , @MsgNoRec 
      , @MsgNoEdit
      , @MsgDupRec
      , @MsgDataError
      , @MsgNotActive
      , @spDetails          OUTPUT
      , @numScheduleAdds    OUTPUT
  
  end

  /*############################################################################
   *# Find any new services after this.  We will return this data so the user
   *# can select what additional service may need to be added.
   *############################################################################*/

  exec dbo.PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_GET_JSON_CORE
      @userID
    , @userGroup
    , @userRank 
    , @clientID 
    , @pracID 
    , @patsCSV
    , 1 -- @loadCurrentCaseload 
    , @hasNewSvcs  OUTPUT
    , @newSvcsJSON OUTPUT

	set @jsonData  = '{'
                   + ' "numUpdates":'  + convert(varchar,@numUpdates)
                   + ',"numAutoAdds":' + convert(varchar,@numAutoAdds)
			       + ',"hasNewSvcs":'  + convert(varchar,@hasNewSvcs)
			       + ',"newSvcs":'     + @newSvcsJSON
			       + '}'

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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_AND_GET_NEW] TO [webuser]
GO

USE spedmon
GO




/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Match') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Match
GO


/*-------------------------------
 * Create new
 *------------------------------*/

  -- NOTE: processes imports 1 at a time by ID.
  --       The full result set of processable jobs is queried via
  --       StructuredDataImportFilesPatientData.viewList() in C#.

CREATE PROCEDURE [dbo].[Patient_Data_Imports_Match] (
    @userID                       bigint
  , @userGroup                    int
  , @userRank                     int
  , @clientID                     bigint
  , @patientDataImportID          bigint
  , @editDelReason                varchar(7000)
  , @validateRec                  bit
  , @saveType                     int
  , @recID                        bigint
  , @MsgNoRec                     Varchar(1000)
  , @MsgNoEdit                    Varchar(1000)
  , @MsgDupRec                    Varchar(1000)
  , @MsgDataError                 Varchar(1000)
  , @MsgNotActive                 Varchar(1000)
  , @spDetails                    VARCHAR(8000) OUTPUT
  , @recordID                     BIGINT        OUTPUT
  , @jsonData                     varchar(max) output
)
AS

BEGIN

set nocount on

declare @today                               as datetime
declare @tranOpen                            as bit = 0
declare @fileSubClass                        as varchar(256)
declare @fileProcessingStarted               as bit           = 0
declare @fileName                            as varchar(256)  = ''
declare @manageSitesJSONData                 as varchar(max)  = '{}'
declare @jsonErrors                          as varchar(max)  = '{}'

declare @sendExternalMsgToWhatUserID         as bigint        = 0  --

declare @spDetailsSaveExternalMsg            as varchar(8000) = ''
declare @externalMsgID                       as bigint        = 0

declare @externalMsgrecipientUserIDsStr      as varchar(max)  = ''
declare @externalMsgSubject                  as varchar(256)  = ''
declare @externalMsgBody                     as varchar(max)  = ''

declare @requiresRollback                    as bit           =  0
declare @requiresInternalFollowupNotif       as bit           = 0

declare @spDetailsSaveInternalMsg            as varchar(8000) = ''

declare @internalMsgID                       as bigint        = 0
declare @internalMsgrecipientUserIDsStr      as varchar(max)  = '805,12403,10549'
declare @internalMsgBody                     as varchar(max)  = ''
declare @spedSvcsImportResultsJSON           as varchar(max)  = ''
declare @hasSpedSvcsImportResults            as bit = 0
declare @numImportPopRowsSkipped             as int = 0
declare @numImportSpedRowsSkipped            as int = 0
declare @gotoUrlForManage                    as varchar(256) = 'user_all_patients_data_manage.aspx'
declare @okToCommitData                      as bit = 0

declare @popmatchTestMode                             as bit
declare @popmatchEarlyExit                            as bit

declare @popmatchRejectedValidateGradeDOBs            as bit

declare @popmatchUnknownProblem        as bit

set @today         = getdate()
set @jsonData      = '{}'
set @jsonErrors    = '{}'
set @recordID      = 0
set @spDetails     = ''
set @tranOpen      = 0
set @recordID      = 0

/*############################################################################
 *# Load patient data import record
 *############################################################################*/

select top 1
    @fileProcessingStarted       = pdi.fileProcessingStarted
  , @fileSubClass                = pdi.fileSubClass
  , @recordID                    = pdi.id

  , @sendExternalMsgToWhatUserID = pdi.createdBy

      -- the "external msg" is the test results/ notifs /warnings
      -- that were intended to be sent to whoever uploaded the bulk import,
      -- even if they are a client user.  We orig intended that the client would
      -- eventually have the ability to process their own imports completely.

      -- The "internal message" is a more detailed set of notifs and errors, sent
      -- to a hardcoded selection of internal staffers and devs.

  , @fileName                    = sdi.fileName

  , @okToCommitData              = pdi.okToCommitData

from dbo.Patient_Data_Imports    as pdi
join dbo.Structured_Data_Imports as sdi on sdi.id = pdi.structuredDataImportID
where (
      (pdi.id = @patientDataImportID)
  and (sdi.clientID = @clientID)
  and (pdi.clientID = @clientID)
)

/*############################################################################
 *# Exit if record not found, processing has started already or we are validating
 *############################################################################*/

if (@recordID is null)          return(0)
if (@fileProcessingStarted = 1) return(0)
if (@validateRec = 1)           return(0)

BEGIN TRY

/*############################################################################
 *# Preset notification message recipients
 *############################################################################*/

set @externalMsgrecipientUserIDsStr = convert(varchar(256),@sendExternalMsgToWhatUserID)

/*############################################################################
 *# Set the file processing started status so our service will not pick this
 *# up again.  Do this in a seperate transaction and do it as soon as possible.
 *############################################################################*/

set @tranOpen = 1
begin transaction

set @today = getdate()

update dbo.Patient_Data_Imports
set
    fileProcessingStarted            = 1
  , fileProcessingStartDateTime      = @today
  , lastModified                     = @today
  , lastModifiedBy                   = @userID
where ((id = @patientDataImportID) and (clientID = @clientID))

commit transaction
set @tranOpen = 0

/*############################################################################
 *# Send user message that the import process has started
 *############################################################################*/

/*-------------------------------
 * Create and save message
 *------------------------------*/

set @externalMsgSubject = 'Import of ' +@fileName + ' is in process'
set @externalMsgBody    = '<p>' + @fileName + ' is currently being imported.  You will receive another notification when the import is complete.</p>'


exec users.dbo.USERS_MESSAGES_SAVE_GENERATED
   0
 , 0
 , 0
 , 'spedcare'
 , @externalMsgrecipientUserIDsStr
 , @externalMsgSubject
 , @externalMsgBody
 , 1 /* Send email */
 , null -- @respPromptOptionsBitwise
 , null -- @respPromptOptionsJSON

 , 1
 , @gotoUrlForManage
 , null  --, @gotoURLAdditionalParams

 , 1  -- save type
 , 0  -- Rec id
 , @spDetailsSaveExternalMsg output
 , @externalMsgID            output


/*-------------------------------
 * Associate message with import
 *------------------------------*/

insert into dbo.Patient_Data_Import_Messages (importID, messageID) values(@patientDataImportID, @externalMsgID)

/*############################################################################
 *# Manage site data that comes in.  This runs under its own transaction.
 *# This HAS to run before the imports.
 *############################################################################*/

 if (@okToCommitData = 0)  -- don't run this a second time
 begin


  set @manageSitesJSONData = '{}'

  exec dbo.Patient_Data_Imports_Manage_Sites
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @patientDataImportID
  , 0
  , @manageSitesJSONData output

/*############################################################################
 *# Save the manage sites results data
 *# Do this in a seperate transaction and do it as soon as possible.
 *############################################################################*/

  set @tranOpen = 1
  begin transaction

  set @today = getdate()

  update dbo.Patient_Data_Imports
  set
    manageSitesJSONData              = @manageSitesJSONData
  , hasManageSitesData               = 1
  , lastModified                     = @today
  , lastModifiedBy                   = @userID

  where ((id = @patientDataImportID) and (clientID = @clientID))

  commit transaction
  set @tranOpen = 0

end

/*############################################################################
 *# Start the match.  This will be long running potentially.
 *############################################################################*/

set @jsonData   = '{}'
set @jsonErrors = '{}'

declare @stats_internal    varchar(max);
declare @stats_outgoing    varchar(max);
declare @completedNormally as bit = 0

/*############################################################################
  *# Match total population file data
  *# Note: The sproc called has its own transaction handling
  *############################################################################*/

 if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
 begin

  /*-------------------------------
   * Get the internal message
   * distribution list
   *------------------------------*/

   -- TODO: double check whether this works
   set @internalMsgrecipientUserIDsStr = users.dbo.APP_SETTING_GET_VALUE ('spedcare','patientdata','totalpop','import','exceptions','message-dist-list')

	/*-------------------------------
     * Run the match
     *------------------------------*/

    exec dbo.Patient_Data_Imports_Match_Pop_Data
        @userID
      , @userGroup
      , @userRank
      , @clientID
      , @patientDataImportID
      , 0 /* @testMode is zero */
      
	  , @jsonData                           output
      , @requiresRollback                   output
      , @requiresInternalFollowupNotif      output
	  , @completedNormally                  output
      , @popmatchTestMode                   output
      , @popmatchEarlyExit                  output
      , @popmatchRejectedValidateGradeDOBs  output
      , @popmatchUnknownProblem             output

	--if (@completedNormally = 0) RAISERROR ('Total pop match for total pop file failed', 11, 1)
  -- this error-out causes problems; we don't want to RAISERROR here,
  -- we want the notifs and stats to be populated as normal


    UPDATE dbo.Patient_Data_Imports
      SET   
            completedNormally          =  @completedNormally ,
            earlyExit                  =  @popmatchEarlyExit ,
            rejectedValidateGradeDOBs  =  @popmatchRejectedValidateGradeDOBs ,
            unknownProblem             =  @popmatchUnknownProblem
      WHERE  id = @patientDataImportID

  ---


end

/*############################################################################
  *# Match special ed file data
  *# Note: The sproc called has its own transaction handling
  *############################################################################*/

else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())
begin

   /*-------------------------------
    * Get the internal message
    * distribution list
    *------------------------------*/


   set @internalMsgrecipientUserIDsStr = users.dbo.APP_SETTING_GET_VALUE ('spedcare','patientdata','sped','import','exceptions','message-dist-list')

	/*-------------------------------
     * Run the total pop match
     *------------------------------*/

    exec dbo.Patient_Data_Imports_Match_Pop_Data

        @userID
      , @userGroup
      , @userRank
      , @clientID
      , @patientDataImportID
      , 0 /* @testMode is zero */

      , @jsonData                           output
      , @requiresRollback                   output
      , @requiresInternalFollowupNotif      output
      , @completedNormally                  output
      , @popmatchTestMode                   output
      , @popmatchEarlyExit                  output
      , @popmatchRejectedValidateGradeDOBs  output
	  , @popmatchUnknownProblem             output
	  
	--if (@completedNormally = 0) RAISERROR ('Total pop match for total pop file failed', 11, 1)
    -- this error-out causes problems; we don't want to RAISERROR here,
    -- we want the notifs and stats to be created as normal

    UPDATE dbo.Patient_Data_Imports
      SET   
            completedNormally          =  @completedNormally ,
            earlyExit                  =  @popmatchEarlyExit ,
            rejectedValidateGradeDOBs  =  @popmatchRejectedValidateGradeDOBs ,
            unknownProblem             =  @popmatchUnknownProblem
      WHERE  id = @patientDataImportID

    ---
   declare @okToParseAsSped   as bit = 1

    if (@completedNormally = 0)
       SET @okToParseAsSped = 0;
    else
    begin
    /*-------------------------------
     * Run the sped data match
     *------------------------------*/

    declare
       @spedMatchIsTestMode                     bit
     , @spedMatchRequiresRollback               bit

	  exec dbo.Patient_Data_Imports_Match_SpecEd_Data
    
        @userID
      , @userGroup
      , @userRank
      , @clientID
      , @patientDataImportID

      , 0
      , @spedMatchIsTestMode                     output
      , @spedMatchRequiresRollback               output

      , @spedSvcsImportResultsJSON  output
      , @jsonErrors                 output
	    , @completedNormally          output

	  if (@completedNormally = 0) RAISERROR ('SpEd match for SpEd file failed', 11, 1)


	  set @hasSpedSvcsImportResults = 1 /* TODO: Need to generate importResultsJSON */
	  set @numImportSpedRowsSkipped = 0 /* TODO: Determine what gets skipped */


   /*-------------------------------
    * Update patient SpEd data
	* and promised service data
    *------------------------------*/
   end

   declare @canUseData  as bit = 0
   declare @okToProcess as bit = 0

   /* Make sure its OK to parse with this latest file import */

   select top 1
       @okToProcess = isnull(t0.[committed_transaction],0)
     , @canUseData  = isnull(t0.canUseData,0)
   from dbo.[Import_From_A.5_SERVICES_From_Client_Files] as t0
   where (t0.patientDataImportID = @patientDataImportID)

   if (@canUseData  = 0)    set @okToParseAsSped = 0
   if (@okToProcess = 0)    set @okToParseAsSped = 0
   if (@okToCommitData = 0) set @okToParseAsSped = 0

   /* If it is OK to parse */

   if (@okToParseAsSped = 1)
   begin

     /* Record stats */

	 update [dbo].[Import_From_A.5_SERVICES_From_Client_Files]
     set
	     opened_SQL_transaction_2 = GETDATE()
	   , committed_transaction_2  = 0
	   , canUseData               = 1  /* Assuming we can use data */
     where (patientDataImportID = @patientDataImportID)

     /* Parse.
	  * Note: This routine completely replaces all promised service data for the client.
	  * It also maintains its own transactions and will fail silently if there is an
	  * issue and roll back to the previous stored promised service data.
	  */

     exec dbo.Patient_Data_Imports_Parse_And_Update_SpEd_Data @clientID, @completedNormally output

	 /* This routine updates delivery exceptions */

	 exec dbo.Patient_Promised_Services_Delivery_Expections_Find_And_Update_Orphans @clientID, @completedNormally output

     /* Record stats */

	 update [dbo].[Import_From_A.5_SERVICES_From_Client_Files]
     set
         closed_SQL_transaction_2 = GETDATE()
       , committed_transaction_2  = @completedNormally
	   , canUseData               = @completedNormally
     where (patientDataImportID = @patientDataImportID)

     /* If the parsing failed */

	 if (@completedNormally = 0)
     begin

	   /* Set a flag so we can detect if there was a failure
	    * Note: The thought here is that this if this latest import causes issues in the parsing then this file is at fault so we flag it.
	    * The change to the promised service data will be rolled back so we can correct the issue with the file and try again possibly.
	    */

       update dbo.Patient_Data_Imports
       set
        parsingSpEdSvcDataFailed = 1
      where ((id = @patientDataImportID) and (clientID = @clientID))

	end /* completedNormally */
  end /* okToParse*/

end

/*############################################################################
 *# Unsupported file
 *############################################################################*/

else
begin
    RAISERROR ('Unsupported file', 11, 1)
end


/*############################################################################
 *# Set the file processing completed status
 *############################################################################*/

set @tranOpen = 1
begin transaction

  select
     @numImportPopRowsSkipped = count(distinct t1.rowNum)
  FROM OPENJSON( @jsonData,'$."importErrors"."mergeHeuristicErrors"')
  with (
          [rowNum]             int       '$."txtfile_row_num"'
  ) as t1

  set @today = getdate()

  update dbo.Patient_Data_Imports
  set
      fileProcessingCompleted          = 1
    , importRolledBack                 = @requiresRollback
    , hasImportRowExceptions           = @requiresInternalFollowupNotif
    , fileProcessingError              = 0
    , fileProcessingEndDateTime        = @today
    , lastModified                     = @today
    , lastModifiedBy                   = @userID
    , importResultsJSON                = @jsonData
    , spedSvcsImportResultsJSON        = @spedSvcsImportResultsJSON
    , numImportPopRowsSkipped          = @numImportPopRowsSkipped
	, numImportSpedRowsSkipped         = @numImportSpedRowsSkipped
  where ((id = @patientDataImportID) and (clientID = @clientID))

commit transaction
set @tranOpen = 0

/*############################################################################
 *# Send notification message that import is complete
 *############################################################################*/

 --
if (@requiresRollback = 0)
begin
  set @externalMsgSubject = 'Import of the data in ' + @fileName + ' is complete'
  set @externalMsgBody    = '<p>' + ISNULL(@filename, 'File') + ' has been imported.</p>'
  set @internalMsgBody    = '<p>' + ISNULL(@filename, 'File') + ' has been imported.  Please see details on management screen.</p>'
end
else
 --
begin
  if ( @popmatchTestMode = 0 )
  begin

    set @externalMsgSubject = 'Import of the data in ' + @fileName + ' has failed'
    set @externalMsgBody    = '<p>' + ISNULL(@filename, 'File') + ' has not been imported.</p>'
    set @internalMsgBody    = '<p>' + ISNULL(@filename, 'File') + ' has not been imported.  Please see expection report on management screen.</p>'

  end
  else begin


    IF ( @popmatchEarlyExit = 0  AND  @requiresInternalFollowupNotif = 0  AND  @popmatchUnknownProblem = 0)
      set @externalMsgSubject = 'Test Import of the data in ' + @fileName + ' has been processed succesfully'

    ELSE
      set @externalMsgSubject = 'Test Import of the data in ' + @fileName + ' requires further troubleshooting'

    set @externalMsgBody    = '<p>' + ISNULL(@filename, 'File') + ' has not been imported.</p>'
    set @internalMsgBody    = '<p>' + ISNULL(@filename, 'File') + ' has not been imported.  Please see expection report on management screen.</p>'

  end
end
 --


declare @internalMsgSubject varchar(max) = 'Please Review - ' + @externalMsgSubject;


if ( @popmatchEarlyExit = 1 )
  SET  @internalMsgSubject = @internalMsgSubject + ' with early exit'

if ( @popmatchUnknownProblem = 1 )
  SET  @popmatchUnknownProblem = @internalMsgSubject + ' with unknown problem'

/*-------------------------------
 * Create and save message
 *------------------------------*/

exec users.dbo.USERS_MESSAGES_SAVE_GENERATED
   0
 , 0
 , 0
 , 'spedcare'
 , @externalMsgrecipientUserIDsStr
 , @externalMsgSubject

 , @externalMsgBody  ---

 , 1 /* Send email */
 , null -- @respPromptOptionsBitwise
 , null -- @respPromptOptionsJSON

 , 1
 , @gotoUrlForManage
 , null  -- @gotoURLAdditionalParams

 , 1  -- save type
 , 0  -- Rec id
 , @spDetailsSaveExternalMsg output
 , @externalMsgID            output

/*-------------------------------
 * Associate message with import
 *------------------------------*/

insert into dbo.Patient_Data_Import_Messages (importID, messageID) values(@patientDataImportID, @externalMsgID)


/*############################################################################
 *# Send notification message to internal staff if there were exceptions
 *# that require staff attention (ie patients with conflicting SSID, etc)
 *############################################################################*/

IF ((@requiresInternalFollowupNotif = 1) or (@requiresRollback = 1))
begin

  /*-------------------------------
   * Create and save message
   *------------------------------*/

  exec users.dbo.USERS_MESSAGES_SAVE_GENERATED
     0
   , 0
   , 0
   , 'spedcare'
   , @internalMsgrecipientUserIDsStr
   , @internalMsgSubject

   , @internalMsgBody    --

   , 1 /* Send email */
   , null -- @respPromptOptionsBitwise
   , null -- @respPromptOptionsJSON

   , 1
   , @gotoUrlForManage
   , null  -- @gotoURLAdditionalParams

   , 1  -- save type
   , 0  -- Rec id
   , @spDetailsSaveInternalMsg output
   , @internalMsgID            output

   /*-------------------------------
    * Associate message with import
    *------------------------------*/

   insert into dbo.Patient_Data_Import_Messages (importID, messageID) values(@patientDataImportID, @internalMsgID)

end

/*############################################################################
 *# Done
 *############################################################################*/

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

  if (@tranOpen = 1)
  begin
    ROLLBACK TRANSACTION
	set @tranOpen = 0
  end

  -- Error or raise error with severity 11 to 19 will be caught here

  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()

  if (@ErrorSeverity > 11)
  set @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'

  if ((@clientID is not null) and (@patientDataImportID is not null) and (@userId is not null))
  begin
  set @today = getdate()

    update dbo.Patient_Data_Imports
    set
        fileProcessingError              = 1
      , errorMessages                    = @ErrorMessage
      , lastModified                     = @today
      , lastModifiedBy                   = @userID
    where ((id = @patientDataImportID) and (clientID = @clientID))
  end

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Match] TO [webuser]
go

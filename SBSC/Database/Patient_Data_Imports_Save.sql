USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Save
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patient_Data_Imports_Save] (
    @userID            BIGINT
  , @userGroup         INT
  , @userRank          INT
  , @clientID          bigint

  , @validateGradeDOBs  bit

  , @importDataJSON               varchar(max)
  , @editDelReason                varchar(7000)
  , @validateRec                  bit
  , @saveType                     int
  , @recID                        bigint
  , @MsgNoRec                     Varchar(1000)
  , @MsgNoEdit                    Varchar(1000)
  , @MsgDupRec                    Varchar(1000)
  , @MsgDataError                 Varchar(1000)
  , @MsgNotActive                 Varchar(1000)
  , @spDetails         VARCHAR(8000) OUTPUT
  , @recordID          BIGINT        OUTPUT
  , @jsonData          varchar(max) output
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

declare @tranOpen                    as bit           = 0
declare @sendMatchReportToWhatUserID as bigint        = 0
declare @fileName                    as varchar(256)  = ''
declare @numRowsSkipped              as int           = 0
declare @numColsSkipped              as int           = 0
declare @subject                     as varchar(256)  = ''
declare @body                        as varchar(max)  = ''
declare @bodyLine                    as varchar(max)  = ''
declare @spDetailsSaveMsg            as varchar(8000) = ''
declare @msgID                       as bigint        = 0
declare @recipientUserIDsStr         as varchar(max)  = ''
declare @gotoUrlForManage            as varchar(256) = 'user_all_patients_data_manage.aspx'

/*############################################################################
 *# Init
 *############################################################################*/

set @tranOpen = 0
set @spDetails  = ''
set @recordID = 0
set @jsonData = '{}'

/*############################################################################
 *# Save structured data import data
 *#
 *# Note: We save the import data in a seperate transaction block so we can
 *#
 *# 1. Show the file in the management screen and its status ASAP.
 *# 2. Process the import data in a seperate process
 *############################################################################*/

BEGIN TRANSACTION
set @tranOpen = 1

declare @structuredDataImportID as bigint

exec dbo.Structured_Data_Imports_Save_Core
    @userID
 ,  @userGroup
 ,  @userRank
 ,  @clientID
 ,  @importDataJSON
 , 0 /* @skipDupCheck */
 ,  @editDelReason
 ,  @validateRec
 ,  @saveType
 ,  @recID
 ,  @MsgNoRec
 ,  @MsgNoEdit
 ,  @MsgDupRec
 ,  @MsgDataError
 ,  @MsgNotActive
 ,  @spDetails    OUTPUT
 ,  @structuredDataImportID OUTPUT

COMMIT TRANSACTION
set @tranOpen = 0

/*############################################################################
 *# Save and parse import file
 *#
 *# Note: We use a seperate transaction block so we can
 *#
 *# 1. Show the file in the management screen and its status ASAP.
 *# 2. Process the import data in a seperate process
 *############################################################################*/

BEGIN TRANSACTION
set @tranOpen = 1

declare @patientDataImportID bigint

exec dbo.Patient_Data_Import_Save_Core
     @userID
   , @userGroup
   , @userRank
   , @clientID
   , @structuredDataImportID

   , @validateGradeDOBs

   , @validateRec
   , @spDetails
   , @patientDataImportID   OUTPUT

set @recordID = @patientDataImportID

COMMIT TRANSACTION
set @tranOpen = 0

/*############################################################################
 *# If we are not validating then prepare and send a notification to the user
 *############################################################################*/

if (@validateRec = 0)
begin

  set @numRowsSkipped = 0
  set @numColsSkipped = 0

  select top 1
      @sendMatchReportToWhatUserID = sdi.createdBy
    , @fileName                    = sdi.fileName
    , @numRowsSkipped              = (pdi.preImportNumRowsSkipped + pdi.preImportNumAdditionalRowsSkipped)
	, @numColsSkipped              = pdi.preImportNumColsSkipped
  from dbo.Patient_Data_Imports as pdi
  join dbo.Structured_Data_Imports as sdi on sdi.id = pdi.structuredDataImportID

  where
    (pdi.id = @patientDataImportID)

  set @subject = 'Import of '+ @fileName + ' is pending.' + iif ( ((@numRowsSkipped != 0) or (@numColsSkipped != 0)), ' Some rows and/or columns were skipped.','')
  set @body    = ''
  set @recipientUserIDsStr = convert(varchar(256),@sendMatchReportToWhatUserID)

  set @body = '<p>' + @subject + '</p>'
  set @body = @body + '<p>You will receive additional notifications once the import has started and when it has completed.</p>'

  if (@numRowsSkipped != 0)
  begin
    set @body = @body + '<p>Number of rows skipped due to invalid data : ' + convert(varchar(256),@numRowsSkipped) + '</p>'
    set @body = @body + '<p>Number of cols skipped due to invalid data : ' + convert(varchar(256),@numColsSkipped) + '</p>'
    set @body = @body + '<p>We cannot include details on what patient data was skipped in this message because of privacy concerns and HIPPA compliance</p>'
	set @body = @body + '<p>Once this import is complete, please review the import results report in SpEdCare for details on what patient data was skipped.</p>'
  end

  exec users.dbo.USERS_MESSAGES_SAVE_GENERATED
     0
   , 0
   , 0
   , 'spedcare'
   , @recipientUserIDsStr
   , @subject
   , @body
   , 1     /* Send email */
   , null  /* @respPromptOptionsBitwise*/
   , null  /* @respPromptOptionsJSON*/

   , 1
   , @gotoUrlForManage
   , null  -- @gotoURLAdditionalParams

   , 1     /* save type*/
   , 0     /* Rec id */
   , @spDetailsSaveMsg output
   , @msgID            output

  insert into dbo.Patient_Data_Import_Messages (importID, messageID) values(@patientDataImportID, @msgID)


end /* Validate */

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
     SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Save] TO [webuser]
GO

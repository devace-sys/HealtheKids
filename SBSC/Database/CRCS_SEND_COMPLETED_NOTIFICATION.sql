USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_SEND_COMPLETED_NOTIFICATION') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_SEND_COMPLETED_NOTIFICATION
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CRCS_SEND_COMPLETED_NOTIFICATION]
 (  @userID                bigint
  , @userGroup             int
  , @userRank              int
  , @clientID              bigint
  , @saveType              int           OUTPUT
  , @spDetails             varchar(8000) OUTPUT
  , @recordID              bigint        OUTPUT
)
AS
BEGIN

/***************************************************************************
 * CRCS_SEND_COMPLETED_NOTIFICATION */
/**
 * Creates a new record or edits an exiting one
 *
 ***************************************************************************/

SET NOCOUNT ON

declare @TranOpen               as bit
declare @msgrecipientUserIDsStr as varchar(max)  = ''
declare @msgBody                as varchar(max)  = ''
declare @clientName             as varchar(max)  = ''

BEGIN TRY

/*-------------------------------
 * Init our output parameters
 *------------------------------*/

SET @recordID   = NULL
SET @spDetails  = ''
set @saveType   = dbo.CONST_SAVE_TYPE_NEW()

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

/*-------------------------------
 * Retrieve client name
 *------------------------------*/

 select
   @clientName = cc.CLIENT_NAME
 from dbo.CLIENTS_Client as cc
 where cc.CLIENT_ID = @clientID

BEGIN TRANSACTION

SET @TranOpen = 1

  declare @msgSubject varchar(max) = @clientName + ' has finished entering CRCS data in SpEdCare.';

  /*-------------------------------
   * Get message recipient(s)
   *------------------------------*/

  set @msgrecipientUserIDsStr = users.dbo.APP_SETTING_GET_VALUE ('spedcare','crcs','client','notification','completion','complete-notification')

  /*-------------------------------
   * Create and save message
   *------------------------------*/

  exec users.dbo.USERS_MESSAGES_SAVE_GENERATED
     0
   , 0
   , 0
   , 'spedcare'
   , @msgrecipientUserIDsStr
   , @msgSubject
   , @msgBody
   , 1 /* Send email */
   , null -- @respPromptOptionsBitwise
   , null -- @respPromptOptionsJSON

   , 0     -- @promptUserToGotoURL
   , null  --@gotoUrlForManage
   , null  -- @gotoURLAdditionalParams

   , @saveType  -- save type
   , 0  -- Rec id
   , @spDetails output
   , @recordID  output

/*============================================================
 * All done, commit changes and get out
 *============================================================*/

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

IF @tranOpen = 1 ROLLBACK TRANSACTION

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

GRANT EXECUTE ON  [dbo].[CRCS_SEND_COMPLETED_NOTIFICATION] TO [webuser]
GO

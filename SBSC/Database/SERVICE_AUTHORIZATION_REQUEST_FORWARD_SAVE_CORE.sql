USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_FORWARD_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_FORWARD_SAVE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_REQUEST_FORWARD_SAVE_CORE] (
    @userID                        BIGINT
  , @userGroup                     INT
  , @userRank                      INT
  , @today                         DATETIME
  , @requestID                     BIGINT
  , @reqSvcAuthFromSelectionID     BIGINT
  , @reqSvcAuthMethodSelectionID   BIGINT
  , @svcAuthRequestMsgUrlBase      varchar(512)
  , @svcAuthRequestPaperUploadUrlBase  varchar(512)
  , @pwdMinLen                     INT
  , @editDelReason                 VARCHAR(7000)
  , @validateRec                   BIT

  , @MsgNoRec                      VARCHAR(1000)
  , @MsgNoEdit                     VARCHAR(1000)
  , @MsgDupRec                     VARCHAR(1000)
  , @MsgDataError                  VARCHAR(1000)
  , @MsgNotActive                  VARCHAR(1000)

  , @recordID                      BIGINT        OUTPUT
  , @jsonData                      varchar(max)  OUTPUT
  , @spDetails                     VARCHAR(8000) OUTPUT)

AS
BEGIN

/***************************************************************************
 * SERVICE_AUTHORIZATION_REQUEST_FORWARD_SAVE_CORE */
/**
 * @returns spDetails       Validation or error details
 * @returns saveType        1 = New record created, 2 = Existing record edited
 * @returns recordID        New record id or record id of user record that
 *                          was modified
 ***************************************************************************/

SET NOCOUNT ON

declare @responseCodeData               as   varchar(max)
declare @newUserAccountData             as   NEW_USER_ACCOUNT_DATA
declare @messages                       as   NOTIFICATION_MESSAGE_DATA
declare @clientID                       as   BIGINT

declare @pracID                         as   BIGINT

declare @districtContactUserID          as   BIGINT

declare @selectedFileList               as varchar(max)

declare @patID                          as   BIGINT
declare @svcAuthorizationRequestTypeID  as   BIGINT
declare @referencedEntityID             as   BIGINT
declare @svcDescription                 as   VARCHAR (8000)
declare @formBuilderAnswersJSON         as   VARCHAR (max)
declare @prtGrd1PersonID                as   BIGINT
declare @prtGrd2PersonID                as   BIGINT
declare @orpPracID                      as   BIGINT

BEGIN TRY

SET @recordID   = 0
SET @spDetails  = ''
set @responseCodeData = '{}'

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/

IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',     11, 1)
IF (@userID        IS NULL) RAISERROR ('user id is required',       11, 1)
IF (@userRank      IS NULL) RAISERROR ('userRank is required',      11, 1)
IF (@requestID     IS NULL) RAISERROR ('requestID is required',     11, 1)


/*============================================================
 * Retrieve service authorization record
 *============================================================*/

select top 1

    @clientID                       =   sar.clientID
  , @pracID                         =   sar.pracID
  , @patID                          =   sar.patID
  , @svcAuthorizationRequestTypeID  =   sar.svcAuthorizationRequestTypeID
  , @referencedEntityID             =   sar.referencedEntityID
  , @svcDescription                 =   sar.svcDescription
  , @formBuilderAnswersJSON         =   sar.formBuilderAnswersJSON
  , @prtGrd1PersonID                =   sar.prtGrd1PersonID
  , @prtGrd2PersonID                =   sar.prtGrd2PersonID
  , @orpPracID                      =   sar.orpPracID
  , @districtContactUserID          =   sar.districtContactUserID
  , @selectedFileList               =   sar.filesToIncludeUploadIds
from dbo.SERVICE_AUTHORIZATION_REQUESTS as sar
where (sar.id = @requestID)

/*============================================================
 * Create new request (forwarding to next)
 *============================================================*/

exec dbo.SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE 
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @districtContactUserID
  , @patID
  , 30 /* Response screen */
  , 50 /* Fwd to next */
  , @svcAuthorizationRequestTypeID
  , @referencedEntityID
  , @svcDescription
  , @formBuilderAnswersJSON
  , @formBuilderAnswersJSON
  , @reqSvcAuthFromSelectionID
  , @reqSvcAuthMethodSelectionID
  , @prtGrd1PersonID
  , @prtGrd2PersonID
  , @orpPracID
  , @selectedFileList
  , @pwdMinLen
  , @svcAuthRequestMsgUrlBase
  , @svcAuthRequestPaperUploadUrlBase
  , @editDelReason
  , @validateRec
  , 1 /* @saveType */
  , null /* @recID */
  , @MsgNoRec
  , @MsgNoEdit
  , @MsgDupRec
  , @MsgDataError
  , @MsgNotActive
  , @recordID OUTPUT
  , @jsonData OUTPUT
  , @spDetails OUTPUT

 /*-------------------------------
  * Update record chain
  *------------------------------*/

 update dbo.SERVICE_AUTHORIZATION_REQUESTS set
     nextRequestID  = @recordID
   , lastModified   = @today
   , lastModifiedBy = @userID
 where (id = @requestID)

 update dbo.SERVICE_AUTHORIZATION_REQUESTS set
     prevRequestID  = @requestID
   , lastModified   = @today
   , lastModifiedBy = @userID
 where (id = @recordID)

 /*-------------------------------
  * Update status log
  *------------------------------*/

 exec dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS @requestID, @today, @userID, 2100, @jsonData


/*============================================================
 * All done
 *============================================================*/

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

   SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_FORWARD_SAVE_CORE] TO [webuser]
GO

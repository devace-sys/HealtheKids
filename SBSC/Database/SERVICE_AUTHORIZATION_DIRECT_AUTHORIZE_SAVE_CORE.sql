USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_DIRECT_AUTHORIZE_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_DIRECT_AUTHORIZE_SAVE_CORE
GO

/*-------------------------------
 * Create
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_DIRECT_AUTHORIZE_SAVE_CORE] (
    @userID                            BIGINT
  , @userGroup                         INT
  , @userRank                          INT
  , @clientID                          BIGINT
  , @pracID                            BIGINT
  , @patID                             BIGINT
  , @orpPracID                         BIGINT
  , @effectiveDate                     DATE
  , @svcAuthorizationRequestTypeID     BIGINT
  , @referencedEntityID                BIGINT
  
  , @svcDescription                    VARCHAR (8000)
  , @formBuilderQuestionsJSON          VARCHAR(max)
  , @formBuilderAnswersJSON            VARCHAR(max)

  , @editDelReason         VARCHAR(7000)
  , @validateRec           BIT
  , @MsgNoRec              VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
  , @MsgDupRec             VARCHAR(1000)
  , @MsgDataError          VARCHAR(1000)
  , @MsgNotActive          VARCHAR(1000)
  , @recordID              BIGINT        OUTPUT
  , @spDetails             VARCHAR(8000) OUTPUT )
AS
BEGIN

/***************************************************************************
 * SERVICE_AUTHORIZATION_DIRECT_AUTHORIZE_SAVE_CORE */
/**
 *
 ***************************************************************************/

SET NOCOUNT ON

declare @requestID         as bigint
declare @responseID        as bigint
declare @jsonDataRequest   as varchar(max)
declare @jsonDataResponse  as varchar(max)

/*============================================================
 * Init
 *============================================================*/

set @spDetails = ''
set @recordID  = 0

BEGIN TRY

  /*============================================================
   * Attempt to determine pracID if its null based on userID
   *============================================================*/

  if (@pracID is null)
  begin
    select top 1
	  @pracID = prp.PRACTITIONER_ID
	from dbo.PRACTITIONER_Practitioner as prp
	where (prp.UserID = @userID)
  end

  /*============================================================
   * Generate request
   *============================================================*/

  set @spDetails = ''

  exec dbo.SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE
      @userID
    , @userGroup
    , @userRank
    , @clientID
    , @userID /* Caller is a prac and is the district contact */
    , @patID
    , 60 /* Service authorization confirmation */
    , 75 /* Direct authorization */
    , @svcAuthorizationRequestTypeID
    , @referencedEntityID
    , @svcDescription
	, @formBuilderQuestionsJSON
	, @formBuilderAnswersJSON
    , 20    /*@reqSvcAuthFromSelectionID*/
    , 10    /*@reqSvcAuthMethodSelectionID*/
    , null  /*@prtGrd1PersonID*/
    , null  /*@prtGrd2PersonID*/
    , @orpPracID
    , null --@selectedFileList
    , 8  /*@pwdMinLen*/
    , '' /*@svcAuthRequestMsgUrlBase*/
    , '' /*@svcAuthRequestPaperUploadUrlBase*/
    , @editDelReason
    , @validateRec
    , 1    /*@saveType*/
    , null /*@recID*/
    , @MsgNoRec
    , @MsgNoEdit
    , @MsgDupRec
    , @MsgDataError
    , @MsgNotActive
    , @requestID            OUTPUT
    , @jsonDataRequest      OUTPUT
    , @spDetails            OUTPUT
	
  /*============================================================
   * Generate response
   *============================================================*/

   set @spDetails = ''

   exec dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE_CORE
      @userID
    , @userGroup
    , @userRank
    , @clientID
    , @requestID
    , 3000 /* @responseCode */
    , @effectiveDate
    , '' /*@svcAuthRequestMsgUrlBase*/
    , ''/*@svcAuthRequestPaperUploadUrlBase*/
    , 8 /*@pwdMinLen*/
    , @editDelReason
    , @validateRec
    , 1    /*@saveType*/
    , null /*@recID*/
    , @MsgNoRec
    , @MsgNoEdit
    , @MsgDupRec
    , @MsgDataError
    , @MsgNotActive
    , @responseID        OUTPUT
    , @jsonDataResponse  OUTPUT
    , @spDetails         OUTPUT

  /*============================================================
   * Create record
   *============================================================*/

  insert into dbo.SERVICE_AUTHORIZATION_DIRECT_AUTHORIZATIONS (
	  [clientID]
	, [patID]
	, [pracID]
	, [orpPracID]
	, [effectiveDate]
	, [svcAuthorizationRequestTypeID]
    , [referencedEntityID]
	, [requestID]
	, [responseID]
	, [created]
    , [createdBy]
    , [active]
  )
  values (
  	  @clientID
	, @patID
	, @pracID
	, @orpPracID
	, @effectiveDate
	, @svcAuthorizationRequestTypeID
    , @referencedEntityID
	, @requestID
	, @responseID
	, getdate()
    , @userID
    , 1
  )

  set @recordID = SCOPE_IDENTITY()

  /*============================================================
   * All done
   *============================================================*/


RETURN(0)
END TRY

/*============================================================
 * Exception handling
 *============================================================*/

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

  -- Only send really bad exceptions back with sp details

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

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_DIRECT_AUTHORIZE_SAVE_CORE] TO [webuser]
GO

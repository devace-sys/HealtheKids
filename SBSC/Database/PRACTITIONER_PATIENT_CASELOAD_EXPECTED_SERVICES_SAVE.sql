USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE] (
    @userID                       bigint
  , @userGroup                    bigint
  , @userRank                     bigint
  , @clientID                     bigint
  , @pracID                       bigint
  , @patID                        bigint
  , @svcTrackingClass             int 
  , @spEdServiceCode              int
  , @orpDocID		              bigint
  , @svcNamesListDataSourceID     int  
  , @viaTeleHealth                bit = 0
  , @nameID                       bigint  
  , @startDate                    date
  , @endDate                      date
  , @spEdFreqCode                 int
  , @minsPerFreq                  int
  , @startDateAssigned            date
  , @minsPerFreqAssigned          int
  , @hasSvcDetails                bit = 0
  , @svcDetailsJSON               varchar(max)
  , @userProvidedSvcTerms         bit = 0
  , @editDelReason                VARCHAR(7000)
  , @validateRec                  BIT
  , @saveType                  INT
  , @recID                     bigint
  , @MsgNoRec                  VARCHAR(1000)
  , @MsgNoEdit                 VARCHAR(1000)
  , @MsgDupRec                 VARCHAR(1000)
  , @MsgDataError              VARCHAR(1000)
  , @MsgNotActive              VARCHAR(1000)
  , @spDetails                 VARCHAR(8000) OUTPUT
  , @recordID                  BIGINT        OUTPUT
)
AS
BEGIN

/***************************************************************************
 * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE */
/**
 ***************************************************************************/

SET NOCOUNT ON

declare @tranOpen            as bit = 0
declare @recordIDPromisedSvc as bigint = 0

BEGIN TRY

/*============================================================
 * Init
 *============================================================*/  

set @spDetails  = ''
set @recordID   = 0
set @tranOpen = 0

BEGIN TRANSACTION

set @tranOpen = 1

/*============================================================
 * If this is a tracking record for a SpEd service
 * Please Note: DO NOT MOVE THE FOLLOWING CODE TO THE SAVE CORE
 * ROUTINE.  THIS IS CODE JUST FOR THE SAVE SCREEN.
 *============================================================*/  

if (@svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED())
begin

  /*============================================================
   * And the user selected a SpEd service code and service terms
   * (meaning an existing plan was not selected)
   *============================================================*/  

  if (@userProvidedSvcTerms = 1)
  begin
  	
    /*============================================================
     * Set assigned fields if not provided
     *============================================================*/  

	if (@startDateAssigned   is null) set @startDateAssigned   = @startDate
    if (@minsPerFreqAssigned is null) set @minsPerFreqAssigned = @minsPerFreq

    /*============================================================
     * Create a new promised service
     *============================================================*/  

    exec dbo.PATIENT_PROMISED_SERVICE_Save_Core 
      @userID
    , @userGroup 
    , @userRank 
    , @patID 
    , @spEdServiceCode 
    , null /*@spEdProviderCode*/
    , @spEdFreqCode 
    , null /*@spEdLocationCode*/
    , @startDate 
    , @endDate 
    , 1  /*@individualDelivery*/
    , 0  /*@groupDelivery  */
    , @minsPerFreq 
    , null /*@replacementDataActive */
    , null /*@replacementSpEdServiceCode*/
    , null /*@replacementSpEdFreqCode */
    , null /*@replacementMinsPerFreq  */
    , @editDelReason  
    , @validateRec 
    , 0 /* @recID  */
    , @MsgNoRec 
    , @MsgDupRec
    , @MsgNoEdit
    , @MsgNotActive 
    , @MsgDataError 
    , 1 /*@saveType */
    , @spDetails           OUTPUT    
    , @recordIDPromisedSvc OUTPUT
  end
end

/*============================================================
 * Call save core
 *============================================================*/  

exec dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_CORE 
    @userID
  , @userGroup
  , @userRank 

  , @clientID 
  , @pracID 
  , @patID 
  , @svcTrackingClass

  , @spEdServiceCode
  , @orpDocID
  , @svcNamesListDataSourceID
  , @viaTeleHealth  
  , @nameID 
  , @startDate 
  , @endDate 
  , @spEdFreqCode
  , @minsPerFreq 
  , @startDateAssigned
  , @minsPerFreqAssigned   
  , @hasSvcDetails 
  , @svcDetailsJSON 

  , @editDelReason  
  , @validateRec 
  , @saveType 
  , @recID 

  , @MsgNoRec 
  , @MsgNoEdit 
  , @MsgDupRec 
  , @MsgDataError 
  , @MsgNotActive 
  , @spDetails OUTPUT
  , @recordID  OUTPUT

/*============================================================
 * IF we reach this point everything is OK.  Commit and exit.
 *============================================================*/  

COMMIT TRANSACTION
SET @TranOpen = 0
RETURN(0)
END TRY

/*============================================================
 * IF we end up here something went wrong.  Cancel any pending
 * trasations and return any error messages to caller.
 *============================================================*/  

BEGIN CATCH

  -- Error or raise error with severity 11 to 19 will be caught here

  IF @tranOpen = 1 ROLLBACK TRANSACTION

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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE] TO [webuser]
GO

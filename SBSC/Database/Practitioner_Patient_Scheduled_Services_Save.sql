USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Services_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Practitioner_Patient_Scheduled_Services_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Practitioner_Patient_Scheduled_Services_Save] (
    @userID                    bigint
  , @userGroup                 bigint
  , @userRank                  bigint
  , @clientID                  bigint
  , @pracID                    bigint
  , @patID                     bigint
  , @caseloadGrpID			   bigint	
  , @svcNamesListDataSourceID  int
  , @viaTeleHealth             bit
  , @nameID                    bigint  
  , @recurring                 bit
  , @practitionerPatientCaseloadExpectedServiceID bigint
  , @startDate                 date
  , @endDate                   date  
  , @startTime                 time(0)
  , @numMins                   int
  , @mon                       bit
  , @monStartTime              time(0)
  , @tue                       bit
  , @tueStartTime              time(0)
  , @wed                       bit
  , @wedStartTime              time(0)
  , @thu                       bit
  , @thuStartTime              time(0)
  , @fri                       bit
  , @friStartTime              time(0)
  , @notes                     varchar(max)
  , @editDelReason             varchar(7000)
  , @validateRec               bit
  , @saveType                  int
  , @recID                     bigint
  , @MsgNoRec                  varchar(1000)
  , @MsgNoEdit                 varchar(1000)
  , @MsgDupRec                 varchar(1000)
  , @MsgDataError              varchar(1000)
  , @MsgNotActive              varchar(1000)
  , @spDetails                 varchar(8000) OUTPUT
  , @recordID                  bigint        OUTPUT
)
AS
BEGIN

/***************************************************************************
 * Practitioner_Patient_Scheduled_Services_Save */
/**
 ***************************************************************************/

SET NOCOUNT ON

declare @tranOpen                as bit          = 0


BEGIN TRY

/*============================================================
 * Init output parameters and set initial values for vars
 *============================================================*/  

set @tranOpen = 0
set @spDetails  = ''
set @recordID   = 0


/*============================================================
 * Save or edit
 *============================================================*/  

BEGIN TRANSACTION

  set @tranOpen = 1

  /*-------------------------------
   * Call core sproc
   *------------------------------*/

  exec dbo.Practitioner_Patient_Scheduled_Services_Save_Core
    @userID 
  , @userGroup
  , @userRank 
  , @clientID 
  , @pracID   
  , @patID
  , @caseloadGrpID 
  , @svcNamesListDataSourceID 
  , @viaTeleHealth 
  , @nameID  
  , @recurring 
  , @practitionerPatientCaseloadExpectedServiceID 
  , @startDate 
  , @endDate 
  , @startTime 
  , @numMins
  , @mon 
  , @monStartTime  
  , @tue 
  , @tueStartTime 
  , @wed 
  , @wedStartTime 
  , @thu 
  , @thuStartTime 
  , @fri 
  , @friStartTime 
  , @notes 
  , @editDelReason 
  , @validateRec 
  , @saveType  
  , @recID   
  , @MsgNoRec
  , @MsgNoEdit
  , @MsgDupRec
  , @MsgDataError 
  , @MsgNotActive 
  , @spDetails  OUTPUT
  , @recordID   OUTPUT

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

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Practitioner_Patient_Scheduled_Services_Save] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_SCHEDULED_SERVICES_SAVE_MULTIPLE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_SCHEDULED_SERVICES_SAVE_MULTIPLE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_SCHEDULED_SERVICES_SAVE_MULTIPLE] (
    @userID                    bigint
  , @userGroup                 bigint
  , @userRank                  bigint
  , @clientID                  bigint
  , @pracID                    bigint
  , @caseloadGrpID			   bigint		
  , @patSelectedJSON           varchar(max)
  , @svcNamesListDataSourceID  int
  , @viaTeleHealth             bit
  , @nameID                    bigint  
  , @recurring                 bit  
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
 * PRACTITIONER_PATIENT_SCHEDULED_SERVICES_SAVE_MULTIPLE */
/**
 ***************************************************************************/

SET NOCOUNT ON

declare @tranOpen                as bit          = 0,
		@maxIdx       INT,
        @curIdx       INT           = 1,
        @patID        BIGINT,
		@practitionerPatientCaseloadExpectedServiceID BIGINT,
        @recIDOut     BIGINT,
        @spDetailsOut VARCHAR(8000),
		@recordCount  INT;
    
    DECLARE @Items TABLE (
    idx                      INT IDENTITY(1,1) PRIMARY KEY,
    patID                    BIGINT   NULL,
    pracPatCaseloadExpSvcID  BIGINT   NULL,
    recSchSvcID              BIGINT   NULL    -- para UPDATE
  );


BEGIN TRY

/*============================================================
 * Init output parameters and set initial values for vars
 *============================================================*/  

set @tranOpen = 0
set @spDetails  = ''
set @recordID   = 0
set @recordCount = 0

/*-------------------------------
* Parse JSON into @Items
*------------------------------*/
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
  BEGIN
    -- INSERT (nuevo): leo JSON y saco patID + expectedSvcID
    INSERT INTO @Items(patID, pracPatCaseloadExpSvcID)
    SELECT
      j.patID,
      j.pracPatCaseloadExpSvcID
    FROM OPENJSON(@patSelectedJSON)
    WITH (
      patID                   BIGINT '$.patID',
      pracPatCaseloadExpSvcID BIGINT '$.id'
    ) AS j;
  END
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
  BEGIN
    INSERT INTO @Items(patID, pracPatCaseloadExpSvcID, recSchSvcID)
	SELECT
	  ppss.patID,
	  ppss.practitionerPatientCaseloadExpectedServiceID,
	  ppss.id
	FROM dbo.Practitioner_Patient_Scheduled_Services AS ppss
	  WHERE (
	   ppss.clientID      = @clientID
	 AND ppss.pracID        = @pracID
	 AND ppss.caseloadGrpID = @caseloadGrpID
	 AND ppss.active        = 1
	 );
  END
  ELSE
  BEGIN
    RAISERROR ('Unknown save type', 11, 1)  
    RETURN;
  END

  SELECT @maxIdx = COUNT(*) FROM @Items;
  IF @maxIdx = 0 RETURN(0);


IF @validateRec = 1
BEGIN          
RETURN(0);
END

/*============================================================
 * Save or edit
 *============================================================*/  

BEGIN TRANSACTION

  set @tranOpen = 1
  WHILE @curIdx <= @maxIdx
	BEGIN
	SELECT
        @patID    = patID,
        @practitionerPatientCaseloadExpectedServiceID = pracPatCaseloadExpSvcID,
        @recID    = recSchSvcID
      FROM @Items
      WHERE idx = @curIdx;
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

SET @curIdx = @curIdx + 1;
END

SET @recordCount = @maxIdx;
set @recordID = @recordCount;
COMMIT TRANSACTION;
SET @tranOpen = 0;
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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_SCHEDULED_SERVICES_SAVE_MULTIPLE] TO [webuser]
GO

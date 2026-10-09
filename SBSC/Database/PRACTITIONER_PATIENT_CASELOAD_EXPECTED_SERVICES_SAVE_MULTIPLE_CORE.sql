USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE_CORE] (
    @userID                    bigint
  , @userGroup                 bigint
  , @userRank                  bigint
  , @clientID                  bigint
  , @pracID                    bigint
  , @saveSelectedOnly          bit = 0
  , @newSvcsJSON               varchar(max)
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
  , @hasData                   bit           OUTPUT 
  , @jsonData                  varchar(max)  OUTPUT
)
AS
BEGIN

/***************************************************************************
 * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE_CORE */
/**
 ***************************************************************************/

SET NOCOUNT ON

declare   @curIdx                    as int
declare   @maxIdx                    as int
declare   @patID                     as bigint
declare   @svcTrackingClass          as int
declare   @spEdServiceCode           as int
declare   @startDate                 as date
declare   @endDate                   as date
declare   @spEdFreqCode              as int
declare   @minsPerFreq               as int

declare   @hasSvcLinesDetails        as bit
declare   @svcLinesDetailsJSON       as varchar(max)
declare   @patName                   as varchar(256)
declare   @spEdServiceName           as varchar(256)
declare   @spEdFreqName              as varchar(256)
declare   @selected                  as bit
declare   @okToSave                  as bit 
declare   @numRecsSaved              as int = 0

declare @newServices as table (
	  idx                       int identity(1,1)
	, patID                     bigint
    , spEdServiceCode           int
    , spEdFreqCode              int
    , minsPerFreq               int
    , startDate                 date
    , endDate                   date
    , previousPPCESID           bigint default(-1)
	, expectedMinsInd           int          /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	, expectedMinsGrp           int          /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	, daysOfWeekSvcProvidedJSON varchar(max) /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
    , hasSvcLinesDetails        bit
    , svcLinesDetailsJSON       varchar(max)
	, patName                   varchar(256)
	, spEdServiceName           varchar(256)
	, spEdFreqName              varchar(256)
	, selected                  bit 
	, recSaved                  bit   default(0)
	, recordID                  bigint 
	unique clustered (idx)    
)

BEGIN TRY

/*-------------------------------
 * Init 
 *------------------------------*/

set @spDetails    = ''
set @recordID     = 0
set @numRecsSaved = 0
set @svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED()
set @hasData          = 0
set @jsonData         = '[]'

/*-------------------------------
 * Parse
 *------------------------------*/

insert into @newServices (
    patID
  , spEdServiceCode
  , spEdFreqCode
  , minsPerFreq
  , startDate
  , endDate
  , previousPPCESID
  , expectedMinsInd           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
  , expectedMinsGrp           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
  , daysOfWeekSvcProvidedJSON /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
  , hasSvcLinesDetails
  , svcLinesDetailsJSON
  , patName
  , spEdServiceName
  , spEdFreqName
  , selected
)
select 
    t1.patID
  , t1.spEdServiceCode
  , t1.spEdFreqCode
  , t1.minsPerFreq
  , t1.startDate
  , t1.endDate
  , t1.previousPPCESID
  , t1.expectedMinsInd           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
  , t1.expectedMinsGrp           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
  , t1.daysOfWeekSvcProvidedJSON /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
  , t1.hasSvcLinesDetails
  , t1.svcLinesDetailsJSON
  , t1.patName
  , t1.spEdServiceName
  , t1.spEdFreqName
  , t1.selected
from openjson(@newSvcsJSON)
with (
      patID                     bigint       '$."patID"'
    , spEdServiceCode           int          '$."spEdServiceCode"'
    , spEdFreqCode              int          '$."spEdFreqCode"'
    , minsPerFreq               int          '$."minsPerFreq"'
    , startDate                 date         '$."startDate"'
    , endDate                   date         '$."endDate"'
    , previousPPCESID           bigint       '$."previousPPCESID"'
	, expectedMinsInd           int          '$."expectedMinsInd"'
    , expectedMinsGrp           int          '$."expectedMinsGrp"'
    , daysOfWeekSvcProvidedJSON varchar(max) '$."daysOfWeekSvcProvidedJSON"'
	, hasSvcLinesDetails        bit          '$."hasSvcLinesDetails"'
    , svcLinesDetailsJSON       varchar(max) '$."svcLinesDetailsJSON"'
    , patName                   varchar(256) '$."patName"'
    , spEdServiceName           varchar(256) '$."spEdServiceName"'
    , spEdFreqName              varchar(256) '$."spEdFreqName"'
	, selected                  bit          '$."selected"'
) as t1

set @curIdx = 1
select @maxIdx = max(ns.idx) from @newServices as ns

while (@curIdx <= @maxIdx)
begin
  
  set @patID                     = null
  set @spEdServiceCode           = null
  set @spEdFreqCode              = null
  set @minsPerFreq               = null
  set @startDate                 = null
  set @endDate                   = null
  set @hasSvcLinesDetails        = null
  set @svcLinesDetailsJSON       = null
  set @patName                   = ''
  set @spEdServiceName           = ''
  set @spEdFreqName              = ''
  
  select top 1 
	    @patID                     = ns.patID
	  , @spEdServiceCode           = ns.spEdServiceCode
	  , @spEdFreqCode              = ns.spEdFreqCode
	  , @minsPerFreq               = ns.minsPerFreq
	  , @startDate                 = ns.startDate
	  , @endDate                   = ns.endDate
	  , @hasSvcLinesDetails        = ns.hasSvcLinesDetails
	  , @svcLinesDetailsJSON       = ns.svcLinesDetailsJSON
      , @patName                   = ns.patName
	  , @spEdServiceName           = ns.spEdServiceName
	  , @spEdFreqName              = ns.spEdFreqName
	  , @selected                  = ns.selected
  from @newServices as ns 
  where 
    (ns.idx = @curIdx)
  
  /*-------------------------------
   * If procedure is in save 
   * selected only mode 
   *------------------------------*/
  
  set @okToSave = 0

  if (@saveSelectedOnly = 1)
  begin
    
	/*-------------------------------
     * And this service is not 
	 * selected dont allow save
     *------------------------------*/

    if (@selected = 1) 
	  set @okToSave = 1 
	else 
	  set @okToSave = 0

  end
  else  
  begin
    set @okToSave = 1
  end
  
  if (@okToSave = 1)
  begin

    exec dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_CORE
        @userID
      , @userGroup
      , @userRank
      , @clientID
      , @pracID
      , @patID
      , @svcTrackingClass
      , @spEdServiceCode
      , null -- @orpDocID
	  , null --@svcNamesListDataSourceID 
      , 0 --@viaTeleHealth
      , null --@nameID  
      , @startDate
      , @endDate
      , @spEdFreqCode
      , @minsPerFreq
	  , @startDate --  @startDateAssigned
	  , @minsPerFreq --@minsPerFreqAssigned
      , @hasSvcLinesDetails
      , @svcLinesDetailsJSON
      , @editDelReason
      , @validateRec
      , 1    -- @saveType
      , null -- @recID
      , @msgNoRec
      , @msgNoEdit
      , @msgDupRec
      , @msgDataError
      , @msgNotActive 
      , @spDetails    OUTPUT
      , @recordID     OUTPUT

	  /*-------------------------------
       * Indicate we were able to save
	   * record and capture record id
       *------------------------------*/

	  update @newServices 
	  set 
	      recSaved = 1
		, recordID = @recordID 
	  where 
	    (idx = @curIdx)

	  set @numRecsSaved = @numRecsSaved + 1

    end /* ok to save */
	set @curIdx = @curIdx + 1

end

/*-------------------------------
 * If we reach this point
 * everything is OK 
 * Record num of recs saved in 
 * recordID (standard for multi
 * save ops), serialize some data
 * about the records that were 
 * saved (not standard) and
 * exit.
 *------------------------------*/

set @recordID = @numRecsSaved
set @jsonData = '[]'
set @hasData  = 0

declare @jsonDataOut as varchar(max) = null

set @jsonDataOut = convert (varchar(max),(
  select 
      t1.patID
	, t1.spEdServiceCode
	, t1.spEdFreqCode
	, t1.minsPerFreq
	, t1.startDate
	, t1.endDate
	, t1.previousPPCESID
	, t1.recordID	
  from @newServices as t1
  where 
    (t1.recSaved = 1)  
  
  for json auto
))

set @jsonData = isnull(@jsonDataOut,'[]')
if (@jsonData != '[]') set @hasData = 1

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

   SET @ErrorMessage = @ErrorMessage + ' ' + @patName + ' ' + @spEdServiceName

   --if (@ErrorSeverity > 11)
   --  SET @ErrorMessage = @ErrorMessage + ' ' + @patName + ' ' + @spEdServiceName

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE_CORE] TO [webuser]
GO

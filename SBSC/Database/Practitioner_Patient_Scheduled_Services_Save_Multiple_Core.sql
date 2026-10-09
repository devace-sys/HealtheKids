USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Services_Save_Multiple_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Practitioner_Patient_Scheduled_Services_Save_Multiple_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Practitioner_Patient_Scheduled_Services_Save_Multiple_Core] (
    @userID                    bigint
  , @userGroup                 int
  , @userRank                  int
  , @clientID                  bigint
  , @pracID                    bigint
  , @newSvcsOrExpSvcsJSON                 varchar(max) = '[]' /* Note: Content is contextual.  See inline docs for more info.*/
  , @loadNewSvsFromPossibleNewFromExpSvcs bit          = 0
  , @validateRec               BIT
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
 * Practitioner_Patient_Scheduled_Services_Save_Multiple_Core */
/**
 * Note: This routine is currently only going to be used internally for
 * spEd plan updates.  However hooks have been left in place for end user 
 * use.  Some functionality.
 *
 * @parm @newSvcsOrExpSvcsJSON  Requires different JSON to be passed in
 * based on value of @loadNewSvsFromPossibleNewFromExpSvcs. 
 ***************************************************************************/

SET NOCOUNT ON

declare 
    @curIdx                    int
  , @maxIdx                    int
  , @patID                     bigint
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
  , @numRecsSaved              int

declare @newServices as table (
	idx                                          int identity(1,1)
  , patID                                        bigint
  , svcNamesListDataSourceID                     int
  , viaTeleHealth                                bit
  , nameID                                       bigint  
  , recurring                                    bit
  , practitionerPatientCaseloadExpectedServiceID bigint
  , startDate                                    date
  , endDate                                      date  
  , startTime                                    time(0)
  , numMins                                      int
  , mon                                          bit
  , monStartTime                                 time(0)
  , tue                                          bit
  , tueStartTime                                 time(0)
  , wed                                          bit
  , wedStartTime                                 time(0)
  , thu                                          bit
  , thuStartTime                                 time(0)
  , fri                                          bit
  , friStartTime                                 time(0)
  , notes                                        varchar(max)
  unique clustered (idx)    
)

BEGIN TRY

/*############################################################################
 *# Init
 *############################################################################*/

set @spDetails    = ''
set @recordID     = 0
set @numRecsSaved = 0

/*############################################################################
 *# Validate required parameters needed to make sproc work properly
 *############################################################################*/

IF (@userID      IS NULL) RAISERROR ('userID is required',           11, 1)       
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',        11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',         11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',       11, 1)    
IF (@clientID    IS NULL) RAISERROR ('Client id is required',        11, 1)    
IF (@pracID      IS NULL) RAISERROR ('Practitioner id is required',  11, 1)    

/*############################################################################
 *# If we are populating @newServices (table variable) from the following UDF: 
 *# Practitioner_Patient_Scheduled_Services_Possible_New_From_Exp_Svcs_View_Core
 *# then it is expected that @newSvcsOrExpSvcsJSON will contain the 
 *# EXPECTED SERVICES data that the UDF requires.
 *############################################################################*/

if (@loadNewSvsFromPossibleNewFromExpSvcs = 1)
begin

  insert into @newServices (
      patID
    , svcNamesListDataSourceID 
    , viaTeleHealth 
    , nameID  
    , recurring 
    , practitionerPatientCaseloadExpectedServiceID 
    , startDate 
    , endDate  
    , startTime 
    , numMins  
    , mon   
    , monStartTime 
    , tue  
    , tueStartTime 
    , wed 
    , wedStartTime 
    , thu  
    , thuStartTime 
    , fri 
    , friStartTime 
    , notes
  )
  select 
      t1.patID
    , t1.svcNamesListDataSourceID 
    , t1.viaTeleHealth 
    , t1.nameID  
    , t1.recurring 
    , t1.practitionerPatientCaseloadExpectedServiceID 
    , t1.startDate 
    , t1.endDate  
    , t1.startTime 
    , t1.numMins  
    , t1.mon   
    , t1.monStartTime 
    , t1.tue  
    , t1.tueStartTime 
    , t1.wed 
    , t1.wedStartTime 
    , t1.thu  
    , t1.thuStartTime 
    , t1.fri 
    , t1.friStartTime
    , notes = '' 
  from dbo.Practitioner_Patient_Scheduled_Services_Possible_New_From_Exp_Svcs_View_Core (@clientID, @pracID, @newSvcsOrExpSvcsJSON) as t1
  where 
    (t1.possibleDup = 0)  /* Filter out possible duplicates */

end

/*############################################################################
 *# If we are populating the new scheduled services table variable from the 
 *# contents of @newSvcsOrExpSvcsJSON then it is expected that 
 *# @newSvcsOrExpSvcsJSON will contain data that can be used to populate
 *# @newServices.
 *#       TODO : IMPLEMENT THIS WHEN THIS FUNCTIONALITY IS NEEDED.
 *############################################################################*/

else
begin
  RAISERROR ('Not implemented yet', 11, 1)    
end

/*############################################################################
 *# Setup our save loop
 *############################################################################*/

set @curIdx = 1
select @maxIdx = max(ns.idx) from @newServices as ns
set @numRecsSaved = 0

/*############################################################################
 *# Save data
 *############################################################################*/

while (@curIdx <= @maxIdx)
begin

  /*-------------------------------
   * Get rec to save
   *------------------------------*/

  select top 1 

      @patID                                        = ns.patID
    , @svcNamesListDataSourceID                     = ns.svcNamesListDataSourceID
    , @viaTeleHealth                                = ns.viaTeleHealth
    , @nameID                                       = ns.nameID
    , @recurring                                    = ns.recurring
    , @practitionerPatientCaseloadExpectedServiceID = ns.practitionerPatientCaseloadExpectedServiceID
    , @startDate                 = ns.startDate
    , @endDate                   = ns.endDate
    , @startTime                 = ns.startTime
    , @numMins                   = ns.numMins
    , @mon                       = ns.mon
    , @monStartTime              = ns.monStartTime
    , @tue                       = ns.tue
    , @tueStartTime              = ns.tueStartTime
    , @wed                       = ns.wed
    , @wedStartTime              = ns.wedStartTime
    , @thu                       = ns.thu
    , @thuStartTime              = ns.thuStartTime
    , @fri                       = ns.fri
    , @friStartTime              = ns.friStartTime
    , @notes                     = ns.notes
  
  from @newServices as ns 
  where 
    (ns.idx = @curIdx)
  
  /*-------------------------------
   * Call core sproc to save
   *------------------------------*/

  exec dbo.Practitioner_Patient_Scheduled_Services_Save_Core
      @userID 
    , @userGroup
    , @userRank 
    , @clientID 
    , @pracID   
    , @patID 
	, null
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
    , '' /*@editDelReason */
    , @validateRec 
    , 1 /*@saveType*/  
    , null /* @recID */
    , @MsgNoRec
    , @MsgNoEdit
    , @MsgDupRec
    , @MsgDataError 
    , @MsgNotActive 
    , @spDetails  OUTPUT
    , @recordID   OUTPUT
  
  set @numRecsSaved = @numRecsSaved + 1
  set @curIdx       = @curIdx + 1

end

/*-------------------------------
 * If we reach this point
 * everything is OK 
 * Record num of recs saved in 
 * recordID (standard for multi
 * save ops) and exit
 *------------------------------*/

set @recordID = @numRecsSaved

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

GRANT EXECUTE ON  [dbo].[Practitioner_Patient_Scheduled_Services_Save_Multiple_Core] TO [webuser]
GO

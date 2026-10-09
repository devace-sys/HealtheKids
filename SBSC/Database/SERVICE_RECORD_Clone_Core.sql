USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Clone_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Clone_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Clone_Core] (
    @recID              bigint
  , @validateRec        bit
  , @msgDupRec          VARCHAR(1000)    
  , @msgInvCombo        VARCHAR(1000)    
  , @MsgNoRec           VARCHAR(1000)     
  , @MsgNoEdit          VARCHAR(1000)     
  , @MsgDataError       VARCHAR(1000)    
  , @MsgMinReq          VARCHAR(1000)    
  , @MsgMinDef          VARCHAR(1000)     
  , @MsgMilReq          VARCHAR(1000)    
  , @MsgPatElg          VARCHAR(1000)
  , @MsgPatDOBGteDOS    VARCHAR(1000)
  , @MsgNotActive       VARCHAR(1000)
  , @MsgPatAbsent       VARCHAR(1000) 
  , @MsgFutureDOS       VARCHAR(1000)    
  , @spDetails          VARCHAR(8000) OUTPUT
  , @srUserID           bigint        output
  , @srUserGroup        int           output
  , @srUserRank         int           output
  , @srClientID         bigint        output
  , @recordID           bigint        output )    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_Clone */    
/**    
 * Creates an exact copy of an existing service record with new claims
 ***************************************************************************/         
     
SET NOCOUNT ON    

BEGIN TRY    
      
declare @saveType         as int
declare @batchID          as UNIQUEIDENTIFIER = null
declare @batchIDRecID     as BIGINT           = null
declare @svcRecID         as bigint           = null
declare @srReference      as varchar(500)
declare @srPracID         as bigint
declare @srPatID          as bigint
declare @srSvcTypeID      as int
declare @srEntryType      as int
declare @srHasOrpDocID    as bit
declare @srOrpDocID       as  bigint
declare @srGroupID        as bigint
declare @srDOS            as datetime
declare @srNameID         as bigint
declare @srPlanType       as bigint
declare @srIsIep          as bit
declare @srPatAbsent      as bit
declare @srPracAbsent     as bit
declare @srMakeupSession  as bit
declare @srAttendanceSelectionID as int
declare @srState          as int
declare @srNumMins        as int
declare @srStartTime      as time(0)
declare @srHasSvcDetFlags as bit
declare @srSvcDetFlag1    as bit
declare @srSvcDetFlag2    as bit
declare @srSvcDetFlag3    as bit
declare @srSvcDetFlag4    as bit

declare @srTrip1Start as decimal(7,1)
declare @srTrip1End   as decimal(7,1)
declare @srTrip2Start as decimal(7,1)
declare @srTrip2End   as decimal(7,1)
declare @srTrip3Start as decimal(7,1)
declare @srTrip3End   as decimal(7,1)
declare @srTrip4Start as decimal(7,1)
declare @srTrip4End   as decimal(7,1)

declare @srNotes                            as varchar(max)
declare @srSvcNotesFormBuilderQuestionsJSON as varchar(max)
declare @srSvcNotesFormBuilderAnswersJSON   as varchar(max)
declare @srPatientGoalProgressJSON          as varchar(max)
declare @srHasPatientGoalTrackingData       as bit
declare @srBillingProgramID                 as tinyint

declare @srHasFillablePdfSelections  as bit
declare @srFillablePdfSelectionsJSON as varchar(max)
declare @srFillablePdfAnswersJSON    as varchar(max)

/*#########################################################################################################
  #                                        INIT OUTPUT FIELDS
  #########################################################################################################*/

set @spDetails     = ''
set @recordID      = 0
set @saveType      = dbo.CONST_SAVE_TYPE_NEW()
set @srUserID      = 0 
set @srUserGroup   = 0
set @srUserRank    = 0
set @srClientID    = 0
  
/*#########################################################################################################
  #                                  GET BASIC SERVICE RECORD DATA TO CLONE
  #########################################################################################################*/

set @svcRecID = null

select top 1 
    @svcRecID                     = sr.id 
  , @srReference                  = sr.reference
  , @srEntryType                  = sr.entryType
  , @srSvcTypeID                  = sr.svcType
  , @srState                      = sr.[state]
  , @srHasOrpDocID                = sr.hasOrpDocID
  , @srOrpDocID                   = sr.orpDocID
  , @srGroupID                    = sr.groupID
  , @srDOS                        = sr.dos
  , @srNameID                     = sr.nameID
  , @srPlanType                   = sr.planType
  , @srIsIEP                      = sr.isIFSPorIEP
  , @srPatAbsent                  = sr.patAbsent
  , @srPracAbsent                 = sr.pracAbsent
  , @srMakeupSession              = sr.makeupSession
  , @srAttendanceSelectionID      = sr.attendanceSelectionID
  , @srNumMins                    = sr.numMins
  , @srStartTime                  = sr.startTime
  , @srHasSvcDetFlags             = sr.hasSvcDetFlags
  , @srSvcDetFlag1                = sr.svcDetFlag1
  , @srSvcDetFlag2                = sr.svcDetFlag2
  , @srSvcDetFlag3                = sr.svcDetFlag3
  , @srSvcDetFlag4                = sr.svcDetFlag4
  , @srClientID                   = sr.clientID
  , @srUserID                     = sr.userID
  , @srPracID                     = sr.pracID
  , @srPatID                      = sr.patID
  , @srNotes                      = sr.notes
  , @srTrip1Start                 = sr.trip1Start
  , @srTrip1End                   = sr.trip1End
  , @srTrip2Start                 = sr.trip2Start
  , @srTrip2End                   = sr.trip2End
  , @srTrip3Start                 = sr.trip3Start
  , @srTrip3End                   = sr.trip3End
  , @srTrip4Start                 = sr.trip4Start
  , @srTrip4End                   = sr.trip4End
  , @srHasPatientGoalTrackingData = sr.hasPatientGoalTrackingData
  , @srBillingProgramID           = sr.billingProgramID
from dbo.SERVICE_RECORDS as sr
where 
  (sr.id = @recID)
 
/*#########################################################################################################
  #                                        EARLY EXIT IF NEEDED
  #########################################################################################################*/

/*============================================================
 * If we cant find the record exit
 *============================================================*/ 

if (@svcRecID is null)
  RAISERROR ('Service record not found', 11, 1) 

/*============================================================
 * Exit if we cant process certain service records
 *============================================================*/ 

if (@srEntryType in (10,11)) 
  RAISERROR ('Cloning services that were created in a service journal are not supported yet', 11, 1) 

if (@srState = 99)  
  RAISERROR ('Service can no longer be cloned because it has been deleted', 11, 1) 

if (@srState = 199) 
  RAISERROR ('Service can no longer be cloned because it has been marked for CIF', 11, 1) 

/*#########################################################################################################
  #                               GET REMAINING SERVICE RECORD DATA TO CLONE
  #########################################################################################################*/

/*============================================================
 * Look up info on the user who entered the service
 *============================================================*/ 

select top 1 
    @srUserGroup = ua.userGroupID
  , @srUserRank  = ua.userGroupRank
from users.dbo.USERS_ALL as ua 
where ((ua.id = @srUserID) and (ua.appName = 'spedcare'))

if ((@srUserGroup is null) or (@srUserRank is null))
begin
  RAISERROR ('User who entered service is no longer active', 11, 1)   
end

/*============================================================
 * Get note data
 *============================================================*/ 

select top 1 
    @srSvcNotesFormBuilderQuestionsJSON = srfbd.svcNotesFormBuilderQuestionsJSON
  , @srSvcNotesFormBuilderAnswersJSON   = srfbd.svcNotesFormBuilderAnswersJSON
  , @srPatientGoalProgressJSON          = srfbd.patientGoalProgressJSON   
  , @srHasFillablePdfSelections         = srfbd.hasFillablePdfSelections
  , @srFillablePdfSelectionsJSON        = srfbd.fillablePdfSelectionsJSON
  , @srFillablePdfAnswersJSON           = srfbd.fillablePdfAnswersJSON
   
from dbo.SERVICE_RECORDS_FORM_BUILDER_DATA as srfbd
where 
  (srfbd.svcRecID = @svcRecID)

/*
select   
      userID = @srUserID   
    , userGroup = @srUserGroup    
    , userRank = @srUserRank
    , entryType = @srEntryType
    , reference = @srReference           
    , dos = @srDos
    , clientID = @srClientID     
    , pracId   = @srPracID    
    , patID    = @srPatID
    , isIep    = @srIsIep
    , nameID   = @srNameID
    , hasOrpDocID = @srHasOrpDocID
    , orpDocID    = @srOrpDocID
    , hasSvcDetFlags = @srHasSvcDetFlags
    , detFlag1       = @srSvcDetFlag1
    , detFlag2       = @srSvcDetFlag2
    , detFlag3       = @srSvcDetFlag3
    , detFlag4       = @srSvcDetFlag4
    , startTime      = @srStartTime
    , numMins        = @srNumMins    
    , patAbsent      = @srPatAbsent    
    , pracAbsent     = @srPracAbsent
    , makeupSession  = @srMakeupSession 
    , notes          = @srNotes
	, trip1Start = @srTrip1Start
   ,  trip1End   = @srTrip1End   
   ,  trip2Start = @srTrip2Start 
   ,  trip2End   = @srTrip2End   
   ,  trip3Start = @srTrip3Start 
   ,  trip3End   = @srTrip3End   
   ,  trip4Start = @srTrip4Start 
   ,  trip4End   = @srTrip4End   

	, fbQuestionsJSON = @srSvcNotesFormBuilderQuestionsJSON
    , fbAnswersJSON   = @srSvcNotesFormBuilderAnswersJSON
	, patGoalsJSON    = @srPatientGoalProgressJSON
	, hasPatGoalTrackingData = @srHasPatientGoalTrackingData
*/

/*#########################################################################################################
  #                                   CALL SAVE CORE TO CLONE                                             #
  #########################################################################################################*/

/*-------------------------------    
 * Create unique batch ID
 *------------------------------*/

exec SERVICE_RECORD_BATCH_ID_Create 
  @srUserID, @srUserGroup, @srUserRank, @saveType, @validateRec, @batchIDRecID OUTPUT , @batchID OUTPUT  

/*-------------------------------    
 * Call save sproc
 *------------------------------*/
 
EXEC dbo.SERVICE_RECORD_Save_Core
      @srUserID   
    , @srUserGroup    
    , @srUserRank
	, 1 /* Gen claims */
    , @srEntryType
    , @srReference           
    , ''   
    , ''   
    , @srDos
    , @srClientID     
    , @srPracID    
    , @srPatID
    , @srIsIep
    , @srNameID
    , @srHasOrpDocID
    , @srOrpDocID
    , null    
    , @srHasSvcDetFlags
    , @srSvcDetFlag1
    , @srSvcDetFlag2
    , @srSvcDetFlag3
    , @srSvcDetFlag4
    , @srStartTime
    , @srNumMins    
    , @srTrip1Start   
    , @srTrip1End   
    , @srTrip2Start    
    , @srTrip2End   
    , @srTrip3Start    
    , @srTrip3End   
    , @srTrip4Start    
    , @srTrip4End
    , @srPatAbsent    
    , @srPracAbsent
    , @srMakeupSession 
	, @srAttendanceSelectionID
    , @srNotes
	, @srSvcNotesFormBuilderQuestionsJSON
    , @srSvcNotesFormBuilderAnswersJSON
	, @srPatientGoalProgressJSON
	, @srHasPatientGoalTrackingData
    , @srBillingProgramID
	, @srHasFillablePdfSelections
    , @srFillablePdfSelectionsJSON
    , @srFillablePdfAnswersJSON
	, ''  /* Edit/del reason */  
    , @validateRec    
    , @saveType    
    , 0 
    , @msgDupRec   
    , @msgInvCombo    
    , @MsgNoRec     
    , @MsgNoEdit   
    , @MsgDataError    
    , @MsgMinReq    
    , @MsgMinDef     
    , @MsgMilReq    
    , @MsgPatElg
    , @MsgPatDOBGteDOS
    , @MsgNotActive 
    , @MsgPatAbsent
    , @MsgFutureDOS
    , @spDetails     OUTPUT    
    , @recordID      OUTPUT      

/*-------------------------------    
 * Assign unique batch ID
 *------------------------------*/

DECLARE @batchIDAssRecID  AS BIGINT = null

exec SERVICE_RECORD_BATCH_ID_Assign
    @srUserID, @srUserGroup, @srUserRank, @saveType, @validateRec, @batchID, 1, @recordID, @batchIDAssRecID OUTPUT 


RETURN

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  -- Error or raise error with severity 11 to 19 will be caught here    
    
      
  /*-------------------------------    
   * Identify error
   *------------------------------*/    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage 
      
 /*-------------------------------    
   * Return the error message to
   * the caller. 
   *------------------------------*/    
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Clone_Core] TO [webuser]
GO

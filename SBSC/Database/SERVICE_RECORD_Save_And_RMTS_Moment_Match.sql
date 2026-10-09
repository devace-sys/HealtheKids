USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_And_RMTS_Moment_Match') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save_And_RMTS_Moment_Match
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Save_And_RMTS_Moment_Match] (
    @userID             bigint   
  , @userGroup          bigint    
  , @userRank           int
  , @reference          varchar(500)  
  , @dos                datetime
  , @clientID           bigint     
  , @pracID             bigint    
  , @patID              bigint    
  , @svcNamesListDataSourceID int    
  , @nameID             bigint
  , @hasOrpDocID        BIT
  , @orpDocID           BIGINT
  , @hasSvcDetailFlags  BIT
  , @svcDetFlag1        BIT
  , @svcDetFlag2        BIT
  , @svcDetFlag3        BIT
  , @svcDetFlag4        BIT
  , @startTime          varchar(50)
  , @numMin             INT    
  , @attendanceStatus   int      
  , @notes              varchar(7000)
  , @svcNotesFormBuilderQuestionsJSON varchar(max)
  , @svcNotesFormBuilderAnswersJSON   varchar(max)
  , @patientGoalProgressJSON          varchar(max)
  , @hasPatientGoalTrackingData       bit
  , @hasFillablePdfSelections         bit
  , @fillablePdfSelectionsJSON        varchar(max)
  , @fillablePdfAnswersJSON           varchar(max)
  , @rmtsMomentID                     bigint
  , @editDelReason      varchar(7000)
  , @validateRec        bit
  , @saveType           int    
  , @recID              bigint    
  , @msgDupRec          varchar(1000)    
  , @msgInvCombo        varchar(1000)    
  , @MsgNoRec           varchar(1000)     
  , @MsgNoEdit          varchar(1000)     
  , @MsgDataError       varchar(1000)    
  , @MsgMinReq          varchar(1000)    
  , @MsgMinDef          varchar(1000)     
  , @MsgMilReq          varchar(1000)    
  , @MsgPatElg          varchar(1000)
  , @MsgPatDOBGteDOS    varchar(1000)
  , @MsgNotActive       varchar(1000)
  , @MsgPatAbsent       varchar(1000) 
  , @MsgFutureDOS       varchar(1000)
  , @spDetails          varchar(8000) OUTPUT
  , @recordID           bigint       OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_Save_And_RMTS_Moment_Match */    
/**    
 *
 ***************************************************************************/         
     
SET NOCOUNT ON    

set @spDetails = ''
set @recordID = 0
    
declare @tranOpen       as bit = 0           
declare @startTimeVal   as time(0)
declare @patAbsent      as bit
declare @pracAbsent     as bit 
declare @makeupSession  as bit

declare @isIFSPorIEP      as bit
declare @billingProgramID as smallint = 1

/*-------------------------------    
 * Get IEP flag and billing 
 * program id
 *------------------------------*/

select
    @isIFSPorIEP      = csnlds.isIEPOrIFSP
  , @billingProgramID = csnlds.billingProgramID
from dbo.CLAIM_Svc_Names_List_Data_Sources as csnlds 

where (csnlds.id = @svcNamesListDataSourceID)

BEGIN TRY    
 
/*-------------------------------    
 * Get attendance status flags
 * from selection
 *------------------------------*/

select top 1
    @patAbsent     = t1.patAbsent
  , @pracAbsent    = t1.pracAbsent
  , @makeUpSession = t1.makeupSession
from dbo.SERVICE_RECORD_ATTENDANCE_SELECTION_ID_TO_FLAGS (@attendanceStatus) as t1
    
/*-------------------------------    
 * Convert start time
 *------------------------------*/  

set @startTimeVal = dbo.TIME_STR_TO_TIME_VAL(@startTime)

set @svcNotesFormBuilderQuestionsJSON = isnull(@svcNotesFormBuilderQuestionsJSON,'{}')
set @svcNotesFormBuilderAnswersJSON   = isnull(@svcNotesFormBuilderAnswersJSON,'{}')
set @patientGoalProgressJSON          = isnull(@patientGoalProgressJSON,'{}')
	

/*-------------------------------    
 * If this is an actual save
 * or edit begin a transaction
 *------------------------------*/  

set @TranOpen = 1    

BEGIN TRANSACTION    

/*-------------------------------    
 * Create unique batch ID
 *------------------------------*/

declare @batchID       AS UNIQUEIDENTIFIER
declare @batchIDRecID  AS BIGINT          

exec SERVICE_RECORD_BATCH_ID_Create @userID, @userGroup, @userRank, @saveType, @validateRec, @batchIDRecID OUTPUT, @batchID OUTPUT  

/*-------------------------------    
 * Create service record
 *------------------------------*/

EXEC dbo.SERVICE_RECORD_Save_Core
      @userID 
    , @userGroup    
    , @userRank
	, 1/* Gen claims */
    , 200    
    , @reference           
    , N'' /*@batchNum   */
    , N'' /*@papClmNum  */
    , @dos 
    , @clientID     
    , @pracID   
    , @patID    
    , @isIFSPorIEP    
    , @nameID
    , @hasOrpDocID
    , @orpDocID
    , null
    , @hasSvcDetailFlags
    , @svcDetFlag1
    , @svcDetFlag2
    , @svcDetFlag3
    , @svcDetFlag4
    , @startTimeVal
    , @numMin
    , 0 /*@trip1Start*/    
    , 0 /*@trip1End*/
    , 0 /*@trip2Start*/    
    , 0 /*@trip2End*/ 
    , 0 /*@trip3Start*/    
    , 0 /*@trip3End*/ 
    , 0 /*@trip4Start*/    
    , 0 /*@trip4End*/
    , @patAbsent   
    , @pracAbsent 
    , @makeupSession 
	, @attendanceStatus /* @attendanceSelectionID*/
    , @notes  
	, @svcNotesFormBuilderQuestionsJSON
    , @svcNotesFormBuilderAnswersJSON
	, @patientGoalProgressJSON
	, @hasPatientGoalTrackingData
	, @billingProgramID
	, @hasFillablePdfSelections
	, @fillablePdfSelectionsJSON
	, @fillablePdfAnswersJSON
    , @editDelReason    
    , @validateRec   
    , @saveType  
    , @recID  
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

 declare @batchIDAssRecID as bigint = 0
 declare @svcRecID        as bigint = @recordID
 
 exec SERVICE_RECORD_BATCH_ID_Assign @userID, @userGroup, @userRank, @saveType, @validateRec, @batchID, 1, @svcRecID, @batchIDAssRecID OUTPUT 
    
 /*-------------------------------    
  * Create match record
  *------------------------------*/
 
 declare @matchRecordID  as bigint        = 0
 declare @spDetailsMatch as varchar(8000) = ''

 
 exec dbo.RMTS_MOMENT_MATCH_SERVICE_RECORD_CORE 
    @userID        
  , @userGroup        
  , @userRank          
  , @clientID      

  , @rmtsMomentID
  , null

  , 1 /*@isPrac*/

  , @editDelReason 
  , @validateRec  
  , @saveType     
  , @svcRecID   
  , @msgDupRec
  , @MsgNoRec 
  , @MsgNoEdit 
  , @MsgDataError
  , @MsgNotActive 
  , @spDetailsMatch    OUTPUT
  , @matchRecordID     OUTPUT
 

  
/*-------------------------------    
 * If this was an actual save
 * or edit commit the transaction
 *------------------------------*/  

if (@tranOpen = 1) COMMIT TRANSACTION    

/*-------------------------------    
 * Done
 *------------------------------*/  

set @tranOpen = 0    
RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  -- Error or raise error with severity 11 to 19 will be caught here    
    
  /*-------------------------------    
   * Cancel any pending    
   * transactions  
   *------------------------------*/    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
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
 
GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Save_And_RMTS_Moment_Match] TO [webuser]
GO

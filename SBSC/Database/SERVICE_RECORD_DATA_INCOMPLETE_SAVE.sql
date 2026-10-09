USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_DATA_INCOMPLETE_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_DATA_INCOMPLETE_SAVE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[SERVICE_RECORD_DATA_INCOMPLETE_SAVE] (
    @userID             BIGINT    
  , @userGroup          INT    
  , @userRank           INT    
  , @reference          VARCHAR(500)
  , @dos                datetime
  , @clientID           BIGINT
  , @pracID             BIGINT    
  , @patID              BIGINT    
  , @isIEPOrIFSP        BIT    
  , @nameID             BIGINT
  , @hasOrpDocID        BIT
  , @orpDocID           BIGINT
  , @hasSvcDetFlags     BIT
  , @svcDetFlag1        BIT
  , @svcDetFlag2        BIT
  , @svcDetFlag3        BIT
  , @svcDetFlag4        BIT
  
  , @numMins            INT 
  , @editDelReason      VARCHAR(7000)
  , @validateRec        BIT
  , @saveType           INT  /* Not used*/
  , @recID              BIGINT /* Rec id of qform */   
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
  , @recordID           BIGINT        OUTPUT /* Rec id of service record (if created)*/ )    
AS    
BEGIN            
 
/* Note: Support provided for LEA BOP services only and only services where patient was present
 * Basically the fields that the pcal input staff would be able to input.
 */   

SET NOCOUNT ON    
 
DECLARE @TranOpen            as BIT  
DECLARE @auditRecID          as BIGINT
DECLARE @today               as DATETIME = GETDATE()
DECLARE @batchID             as UNIQUEIDENTIFIER = null
DECLARE @batchIDRecID        as BIGINT           = null
DECLARE @batchIDAssRecID     as BIGINT = null
declare @spDetailsOut        as varchar(8000) = ''
declare @recordIDOut         as bigint = 0
 

BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
set @spDetails  = ''    
set @recordID   = 0 
set @today      = GETDATE()

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
 
IF (@userID            IS NULL)			    RAISERROR ('userID is required',      11, 1)      
IF (@userGroup         IS NULL)			    RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank          IS NULL)			    RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec       IS NULL)			    RAISERROR ('Validate flag required',  11, 1) 
IF (@recID             IS NULL)             RAISERROR ('Qform rec id required',   11, 1)

/*-------------------------------    
 * Validation exit
 *------------------------------*/    
  
IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        
 
/*============================================================
 * Write data
 *============================================================*/  

BEGIN TRANSACTION    
 
   set @TranOpen = 1     
   set @recordID = 0
  
  /*============================================================
   * Create unique batch id
   *============================================================*/ 

  exec SERVICE_RECORD_BATCH_ID_Create @userID, @userGroup, @userRank, @saveType, @validateRec, @batchIDRecID OUTPUT , @batchID OUTPUT  
    
  /*============================================================
   * Call the core service record save routine
   *============================================================*/ 
  
   EXEC dbo.SERVICE_RECORD_Save_Core
        @userID,                --@userID                              
    	@userGroup,    		    --@userGroup  
  	    @userRank,			    --@userRank   
  	    1,
  		1000,     		        --@entryType  
  	    @reference,             --@reference  
  	    null,    				--@batchNum   
  	    null,    				--@papClmNum  
  	    @dos,    				--@dos        
  	    @clientID,     		    --@clientID   
  	    @pracID,    			--@pracID     
  	    @patID,    			    --@patID      
  	    @isIEPOrIFSP,		    --@isIFSPorIEP
  	    @nameID,                --@nameID    
  	    @hasOrpDocID,           --@hasOrpDocID
  	    @orpDocID,			    --@orpDocID   
  	    null,				    --@orpNPI     
  	    @hasSvcDetFlags,	    --@hasSvcDetailFlag
  	    @svcDetFlag1,		    --@svcDetFlag1    
  	    @svcDetFlag2,		    --@svcDetFlag2    
  	    @svcDetFlag3,		    --@svcDetFlag3    
  	    @svcDetFlag4,		    --@svcDetFlag4    
  	    '',	  		            --@startTime     
  	    @numMins,    		    --@numMin        
  	    0,    				    --@trip1Start    
  	    0,    				    --@trip1End      
  	    0,    				    --@trip2Start    
  	    0,    				    --@trip2End      
  	    0,    				    --@trip3Start    
  	    0,    				    --@trip3End      
  	    0,    				    --@trip4Start    
  	    0,					    --@trip4End      
  	    0, --@patAbsent
  		0, --@pracAbsent
  		0, --@makeupSession
		0, --@attendanceSelectionID
  	    '',                  --@notes         
  		null, --@svcNotesFormBuilderQuestionsJSON,
        null, --@svcNotesFormBuilderAnswersJSON,
  		null, --@patientGoalProgressJSON,
  		0,    --@hasPatientGoalTrackingData,
  	    1,    /* Billing program id (TODO: Add this parm) */
		 0,   /* Has fillable pdf*/
		'[]', /* Fillable pdf selections */
		'[]', /* Fillable pdf answers*/
		@editDelReason,    	     --@editDelReason 
  	    @validateRec,    		 --@validateRec   
  	    1,        		         --@saveType      
  	    null,    			     --@recID         
  	    @msgDupRec, 			 --@msgDupRec     
  	    @msgInvCombo ,   		 --@msgInvCombo   
  	    @MsgNoRec,      		 --@MsgNoRec      
  	    @MsgNoEdit,     		 --@MsgNoEdit     
  	    @MsgDataError,       	 --@MsgDataError  
  	    @MsgMinReq,    		     --@MsgMinReq      
  	    @MsgMinDef,     		 --@MsgMinDef      
  	    @MsgMilReq,    		     --@MsgMilReq      
  	    @MsgPatElg,			     --@MsgPatElg      
  	    @MsgPatDOBGteDOS,		 --@MsgPatDOBGteDOS
  	    @MsgNotActive,  		 --@MsgNotActive   
  	    @MsgPatAbsent,		     --@MsgPatAbsent   
  	    @MsgFutureDOS,		     --@MsgFutureDOS    
  	    @spDetailsOut OUTPUT,    --@spDetails 
  	    @recordIDOut  OUTPUT     --@recordID     
 							   						
      set @recordID  = @recordIDOut
      set @spDetails = @spDetails + @spDetailsOut
  	
	/*============================================================
	 * Assign the unique batch ID 
	 *============================================================*/  
	
	set @batchIDAssRecID = null			
    exec SERVICE_RECORD_BATCH_ID_Assign @userID, @userGroup, @userRank, @saveType, @validateRec, @batchID, 1, @recordID, @batchIDAssRecID OUTPUT 

	/*============================================================
	 * Remove record from QForms
	 * Same logic as delete
	 *============================================================*/  

    update dbo.SERVICE_RECORD_DATA_INCOMPLETE
    set 
        active         = 0
	  , lastModified   = @today
	  , lastModifiedBy = @userID
      , svcRecID       = @recordID
	where ( 
	      ([id]   = @recID)
	  and ((@clientID is null) or (clientID = @clientID)) /* Middleware forces clientID selection for client users.  This logic partitions by client making sure client users cant change records that are not associated with their clientID */
	  and (active = 1)
    )
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
 
GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_DATA_INCOMPLETE_SAVE] TO [webuser]
GO
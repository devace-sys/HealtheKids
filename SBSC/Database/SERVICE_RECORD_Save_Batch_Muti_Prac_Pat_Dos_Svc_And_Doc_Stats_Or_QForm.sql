USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc_And_Doc_Stats_Or_QForm') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc_And_Doc_Stats_Or_QForm
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc_And_Doc_Stats_Or_QForm] (
    @userID               BIGINT
  , @userGroup            INT  
  , @userRank             INT        
  , @reference            VARCHAR(500)
  , @svcRecsJSON          VARCHAR(max)
  , @svcetrmde            INT
  , @editDelReason        VARCHAR(7000)
  , @validateRec          BIT
  , @saveType             INT    
  , @recID                INT  
  , @MsgNoRec             VARCHAR(1000)
  , @MsgNoEdit            VARCHAR(1000) 
  , @MsgDupRec            VARCHAR(1000)     
  , @MsgDataError         VARCHAR(1000)
  , @MsgNotActive         VARCHAR(1000)     
  , @MsgInvCombo          VARCHAR(1000)     
  , @MsgMinReq            VARCHAR(1000)     
  , @MsgMinDef            VARCHAR(1000)     
  , @MsgMilReq            VARCHAR(1000)     
  , @MsgPatElg            VARCHAR(1000)     
  , @MsgPatDOBGteDOS      VARCHAR(1000)    
  , @MsgPatAbsent         VARCHAR(1000)     
  , @MsgFutureDOS         VARCHAR(1000)     
  , @spDetails            VARCHAR(8000) OUTPUT
  , @recordID             BIGINT        OUTPUT )    
AS    
BEGIN     
    	
/***************************************************************************    
 * SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc */    
/**    
 * Create service records using the passed in JSON 
 *          
 ***************************************************************************/         
     
SET NOCOUNT ON    

declare @today            as datetime   
declare @tranOpen         as bit    = 0
declare @batchIDAssRecID  as bigint = null
					      
declare @minIdx           as bigint
declare @maxIdx           as bigint
declare @nameID           as bigint
					      
DECLARE @batchID          AS UNIQUEIDENTIFIER = null
DECLARE @batchIDRecID     AS BIGINT           = null
declare @spDetailsOut     as varchar(8000) = ''
declare @recordIDOut      as bigint = 0
declare @rmtsSvcRecID     as bigint = 0

declare @dos                as datetime
declare @hasSvcDetFlags     as bit	 = null
declare	@svcDetFlag1   	    as bit	 = null
declare	@svcDetFlag2   	    as bit	 = null
declare	@svcDetFlag3   	    as bit	 = null
declare	@svcDetFlag4   	    as bit	 = null
declare	@hasOrpDocID   	    as bit	 = null
declare	@orpDocID   	    as bigint = null
declare @RMTSMoment         as bit    = null
declare @createQuestionForm as bit    = null
declare @rmtsNameID         as bigint = null

--declare @pracGroupID        as bigint = null
--declare @svcClassNameID     as bigint = null
--declare @svcClassName       as varchar(1000) = ''
declare @patName            as varchar(150) = ''
declare @vMsg               as varchar(4000) = ''

  /*-------------------------------    
   * Declare variables for     
   * our JSON object
   *------------------------------*/

  declare @curIdx                           int
  declare @sessionDeliveryStatus            int = null
  declare @clientID                         bigint
  declare @pracID                           bigint
  declare @groupID                          bigint
  declare @patID                            bigint
  declare @viaTelehealth                    bit
  declare @planTypeID                       int
  declare @isIEPOrIFSP                      bit
  declare @startTime                        datetime
  declare @numMins                          int
  declare @patAbsent                        bit 
  declare @pracAbsent                       bit
  declare @makeupSession                    bit
  declare @notes                            varchar(max)
  declare @svcNotesFormBuilderQuestionsJSON varchar(max)
  declare @svcNotesFormBuilderAnswersJSON   varchar(max)
  declare @patientGoalProgressJSON          varchar(max)
  declare @hasPatientGoalTrackingData       bit
  declare @billingProgramID                 tinyint
  declare @hasFillablePdfSelections         bit         
  declare @fillablePdfSelectionsJSON        varchar(max)
  declare @fillablePdfAnswersJSON           varchar(max)
  declare @skipRecord                       as bit = 0

  declare @svcRecs table (id int IDENTITY(1,1), jsonObj VARCHAR(max))

  declare @qFormSvcRecJSON    as varchar(max)
  declare @inputBatchID       as bigint
  declare @inputBatchClientID as bigint
  declare @inputBatchParentID as bigint
 
  declare @svcDetails table (
      idx                      bigint identity(1,1)
    , clientID                 bigint
	, pracID                   bigint
	, groupID                  bigint
	, patID                    bigint
	, nameID                   bigint 
	, viaTelehealth            bit        
    , isIEPOrIFSP              bit
	, svcNamesListDataSourceID smallint
    , billingProgramID         tinyint
    , startTime                time(0)
    , numMins                  int
    , sessionDeliveryStatus    int
    , notes                            varchar(max)
	, svcNotesFormBuilderQuestionsJSON varchar(max)
	, svcNotesFormBuilderAnswersJSON   varchar(max)
	, patientGoalProgressJSON          varchar(max)
	, hasPatientGoalTrackingData       bit
	, hasFillablePdfSelections         bit         
    , fillablePdfSelectionsJSON        varchar(max)
    , fillablePdfAnswersJSON           varchar(max)
	, dateOfService                    datetime
	, hasSvcDetFlags        bit
	, svcDetFlag1           bit
	, svcDetFlag2           bit
	, svcDetFlag3           bit
	, svcDetFlag4           bit
	, hasOrpDocID           bit
	, orpDocID              bigint
	, RMTSMoment            bit
	, createQuestionForm    bit
    , patAbsent             bit
	, pracAbsent            bit
	, makeupSession         bit
	, svcRecID              bigint
	, skipRecord            bit default(0)
	unique clustered (idx)
)

BEGIN TRY    
    
set @today = GETDATE()

/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @spDetails  = ''    
SET @recordID   = 0 
SET @TranOpen = 0

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    

--IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1) 

/*============================================================
  * Break the details in the incoming json into something 
  * easier to work with
  *============================================================*/

insert into @svcRecs (
  jsonObj
)
select 
  jsonObj = svr.[value]
FROM OPENJSON(@svcRecsJSON) as svr

/*============================================================
 * Partially populate svc details with the details passed in
 *============================================================*/

insert into @svcDetails ( 
    clientID 
  , pracID
  , groupID
  , patID                
  , nameID 
  , viaTelehealth        
  , svcNamesListDataSourceID 
  , startTime            
  , numMins              
  , sessionDeliveryStatus
  , notes       
  , svcNotesFormBuilderQuestionsJSON 
  , svcNotesFormBuilderAnswersJSON
  , patientGoalProgressJSON
  , hasPatientGoalTrackingData
  , hasFillablePdfSelections 
  , fillablePdfSelectionsJSON 
  , fillablePdfAnswersJSON 
  , dateOfService         
  , hasSvcDetFlags
  , svcDetFlag1   
  , svcDetFlag2   
  , svcDetFlag3   
  , svcDetFlag4
  , hasOrpDocID
  , orpDocID 
  , RMTSMoment
  , createQuestionForm 
  , patAbsent            
  , pracAbsent
  , makeupSession
  , svcRecID 
) 
select 
    TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.clientid')      as bigint)
  , TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.pracid')        as bigint)
  , TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.groupID')       as bigint)
  , TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.patid')         as bigint)
  , TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.nameid')        as bigint)
  , JSON_VALUE(svr.jsonObj, '$.viatelehealth')
  , TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.svcnameslistdatasourceid') as smallint)
  , TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.startTime')     as time(0))
  , TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.numMins')       as int)
  , TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.attendanceStatusSelectionID') as int)
  , JSON_VALUE(svr.jsonObj, '$.notes')

  , nq2.frmBldrQuestions
  , na2.frmBldrAnswers
  , pgp.patGoalProg
  , JSON_VALUE(svr.jsonObj, '$.hasPatientGoalTrackingData')
  , JSON_VALUE(svr.jsonObj, '$.hasFillablePdfSelections')
  , fps2.fpsJSON
  , fpa2.fpaJSON  
  , TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.dos') as datetime)
  , JSON_VALUE(svr.jsonObj, '$.hasSvcDetFlags')
  , JSON_VALUE(svr.jsonObj, '$.svcDetFlag1')
  , JSON_VALUE(svr.jsonObj, '$.svcDetFlag2')
  , JSON_VALUE(svr.jsonObj, '$.svcDetFlag3')
  , JSON_VALUE(svr.jsonObj, '$.svcDetFlag4')
  , JSON_VALUE(svr.jsonObj, '$.hasOrpSel')
  , TRY_PARSE(JSON_VALUE(svr.jsonObj, '$.orpDocumentID') as bigint)
  , JSON_VALUE(svr.jsonObj, '$.RMTSMoment')
  , JSON_VALUE(svr.jsonObj, '$.createQuestionForm')
  , null
  , null
  , null
  , null

from @svcRecs as svr
 
outer apply (
  select top 1 
    nq1.[value] as frmBldrQuestions
  FROM OPENJSON(svr.jsonObj) as nq1
  where 
    (nq1.[key] = 'svcNotesFormBuilderQuestionsJSON')
) as nq2
 
outer apply (
  select top 1 
    na1.[value] as frmBldrAnswers
  FROM OPENJSON(svr.jsonObj) as na1
  where 
    (na1.[key] = 'svcNotesFormBuilderAnswersJSON')
) as na2

outer apply (
select top 1 
    na1.[value] as patGoalProg
  FROM OPENJSON(svr.jsonObj) as na1
  where 
    (na1.[key] = 'patientGoalProgressJSON')
) as pgp

outer apply (
  select top 1  
    fps1.[value] as fpsJSON
  FROM OPENJSON(svr.jsonObj) as fps1
  where 
    (fps1.[key] = 'fillablePdfSelectionsJSON')
) as fps2

outer apply (
  select top 1  
    fpa1.[value] as fpaJSON
  FROM OPENJSON(svr.jsonObj  ) as fpa1
  where 
    (fpa1.[key] = 'fillablePdfAnswersJSON')
) as fpa2

/*============================================================
 * Get iep/ifsp and billing program values based on 
 * svcNamesListDataSourceID.  We will pass the iep and billing
 * program flag to the service record save routine.
 *============================================================*/
 
 update sd
 set 
     sd.isIEPOrIFSP      = csnlds.isIEPOrIFSP
   , sd.billingProgramID = csnlds.billingProgramID
 from @svcDetails                           as sd
 join dbo.CLAIM_Svc_Names_List_Data_Sources as csnlds on csnlds.id = sd.svcNamesListDataSourceID

/*============================================================
 * Get control values we will use for our loops
 *============================================================*/

select @minIdx = min(idx), @maxIdx = max(idx) from @svcDetails
set @curIdx = @minIdx

/*============================================================
 * Begin the first loop
 *============================================================*/
 
while (@curIdx <= @maxIdx)
begin

	/*============================================================
     * Get incoming columns
     *============================================================*/
	 
	 select top 1
		  @isIEPOrIFSP            = isIEPOrIFSP
	    , @billingProgramID       = billingProgramID
		, @nameID				  = nameID
		, @sessionDeliveryStatus  = sessionDeliveryStatus
		, @clientID               = clientID
		, @pracID                 = pracID
		, @patID                  = patID
		, @startTime              = startTime
		, @numMins                = numMins
		, @dos                    = dateOfService
		, @hasSvcDetFlags         = hasSvcDetFlags
		, @svcDetFlag1   		  = svcDetFlag1   
		, @svcDetFlag2   		  = svcDetFlag2   
		, @svcDetFlag3   		  = svcDetFlag3   
		, @svcDetFlag4   		  = svcDetFlag4
		, @hasOrpDocID   		  = hasOrpDocID   
		, @orpDocID     		  = orpDocID   
		, @RMTSMoment             = RMTSMoment
		, @createQuestionForm     = createQuestionForm
	 from @svcDetails 
	 where 
	   (idx = @curIdx)
	 	   
	 /*============================================================
      * Derive attendance flags from session delivery status
      *============================================================*/ 
	 
	 select 
		  @patAbsent     = t1.patAbsent
		, @pracAbsent    = t1.pracAbsent
		, @makeupSession = t1.makeupSession
	 from dbo.SERVICE_RECORD_ATTENDANCE_SELECTION_ID_TO_FLAGS (@sessionDeliveryStatus) as t1

	 update @svcDetails 
	 set 
	     patAbsent = @patAbsent
	   , pracAbsent = @pracAbsent
	   , makeupSession = @makeupSession 
	 where 
	   (idx = @curIdx)

     set @curIdx = @curIdx + 1
 end

/*============================================================
  * Record service records
  *============================================================*/
    
BEGIN TRANSACTION    
    
  set @TranOpen = 1    
  
  /*============================================================
   * Create a unique batch ID (not used in validates)
   *============================================================*/  
		 
  EXEC dbo.SERVICE_RECORD_BATCH_ID_Create @userID, @userGroup, @userRank, @saveType, @validateRec, @batchIDRecID OUTPUT , @batchID OUTPUT 
	      	        
  /*============================================================
   * Begin our second loop
   *============================================================*/
	
  set @curIdx = @minIdx
	
  while (@curIdx <= @maxIdx)
  begin
	 
    /*============================================================
     * Get incoming and derived columns
	 *============================================================*/
		 
	select top 1
		      @nameID           = sd.nameID
			, @isIEPOrIFSP      = sd.isIEPOrIFSP
			, @billingProgramID = sd.billingProgramID
		    , @viaTelehealth    = sd.viaTelehealth
			, @clientID         = sd.clientID
			, @pracID           = sd.pracID
			, @patID            = sd.patID
			, @startTime        = sd.startTime
			, @numMins          = sd.numMins
		    , @notes            = sd.notes
			, @svcNotesFormBuilderQuestionsJSON = sd.svcNotesFormBuilderQuestionsJSON
            , @svcNotesFormBuilderAnswersJSON   = sd.svcNotesFormBuilderAnswersJSON
			, @patientGoalProgressJSON          = sd.patientGoalProgressJSON
			, @hasPatientGoalTrackingData       = sd.hasPatientGoalTrackingData
			, @hasFillablePdfSelections         = sd.hasFillablePdfSelections
            , @fillablePdfSelectionsJSON        = sd.fillablePdfSelectionsJSON
            , @fillablePdfAnswersJSON           = sd.fillablePdfAnswersJSON
			, @patAbsent          = sd.patAbsent
			, @pracAbsent         = sd.pracAbsent
			, @makeupSession      = sd.makeupSession
			, @dos                = sd.dateOfService
			, @hasSvcDetFlags     = sd.hasSvcDetFlags
			, @svcDetFlag1        = sd.svcDetFlag1
			, @svcDetFlag2        = sd.svcDetFlag2
			, @svcDetFlag3        = sd.svcDetFlag3
			, @svcDetFlag4	      = sd.svcDetFlag4
			, @hasOrpDocID        = sd.hasOrpDocID
			, @orpDocID           = sd.orpDocID
			, @RMTSMoment         = sd.RMTSMoment
			, @createQuestionForm    = sd.createQuestionForm
			, @sessionDeliveryStatus = sd.sessionDeliveryStatus
			, @skipRecord            = sd.skipRecord
		 from @svcDetails as sd
		 where 
		   (idx = @curIdx)	
		 
		 /*============================================================
		   * This row is not qformed.  Create a service record
		   *
		   * Note: All note related columns are replaced with empty
		   * strings, nulls, or empty sets since pcal staff does not 
		   * record service record notes.  The note column is used however
		   * for qforms
		   *============================================================*/ 
			
		 if (@createQuestionForm = 0)
		 begin			 
			 set @recordID = 0
			  
			   EXEC dbo.SERVICE_RECORD_Save_Core
			            @userID,                --@userID                              
				  	    @userGroup,    		    --@userGroup  
					    @userRank,			    --@userRank   
					    1,
						158,     		        --@entryType  
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
					    @startTime,			    --@startTime     
					    @numMins,    		    --@numMin        
					    0,    				    --@trip1Start    
					    0,    				    --@trip1End      
					    0,    				    --@trip2Start    
					    0,    				    --@trip2End      
					    0,    				    --@trip3Start    
					    0,    				    --@trip3End      
					    0,    				    --@trip4Start    
					    0,					    --@trip4End      
					    @patAbsent,             --@patAbsent 
						@pracAbsent,
						@makeupSession,
						@sessionDeliveryStatus, /* @attendanceSelectionID*/
					    '',                  --@notes         
						null, --@svcNotesFormBuilderQuestionsJSON
			            null, --@svcNotesFormBuilderAnswersJSON
						null, --@patientGoalProgressJSON
						0, --@hasPatientGoalTrackingData
						@billingProgramID,				
						0, --@hasFillablePdfSelections
                        '[]', --@fillablePdfSelectionsJSON
                        '[]', --@fillablePdfAnswersJSON
					    @editDelReason,    	     --@editDelReason 
					    @validateRec,    		 --@validateRec   
					    @saveType,    		     --@saveType      
					    @recID,    			     --@recID         
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
											   						
			     set @recordID = @recordIDOut
			     set @spDetails = @spDetails + @spDetailsOut	
				 			     
				/*============================================================
			     * Assign the unique batch ID (not used in validates)
			     *============================================================*/  
	
			    set @batchIDAssRecID = null			
			    EXEC dbo.SERVICE_RECORD_BATCH_ID_Assign @userID, @userGroup, @userRank, @saveType, @validateRec, @batchID, @curIdx, @recordID, @batchIDAssRecID OUTPUT 
			 	   
				if (@validateRec = 0)
				begin
				   update @svcDetails set svcRecID = @recordID where idx = @curIdx
			    end	  
			
			end

		   /*============================================================
		    * This row IS qformed.  Create a qform request.
		    *============================================================*/ 

			else
			begin
			
			/*============================================================
			 * REFERENCE DOCUMENT CHECK
			 *
			 * If this is an SBSC user perform reference document lookup
			 *============================================================*/  
				
				   
		     set @inputBatchID       = null
			 set @inputBatchClientID = null
			 set @inputBatchParentID = null
				  
			 select top 1 
				      @inputBatchID       = ib.id 
				    , @inputBatchClientID = ib.ClientID
				    , @inputBatchParentID = ib.ParentBatchID
			 from dbo.INPUT_BATCHES as ib 
			 where 
			  (ib.File_Name = @reference + '.pdf')
				  
			 if (@inputBatchID is null) 
			  RAISERROR ('Reference document file not found in Input Batches', 11, 1)    
				    
			 if (@inputBatchClientID != @clientID)
			  RAISERROR ('Client ID mismatch between reference file and service record', 11, 1)    
								
			 /*============================================================
			  * Convert data to JSON
			  *============================================================*/
								
			 set @qFormSvcRecJSON = (select *
									   from @svcDetails as sd
									   where (idx = @curIdx) for json auto)

			/*============================================================
			 * Save incomplete service records data
			 *============================================================*/
				 
			if (@validateRec = 0)
	        begin
			  insert into dbo.SERVICE_RECORD_DATA_INCOMPLETE (
				  clientID
			    , reference
				, batchID
				, svcRecJSON
				, created 
				, createdBy
				, active     
			   ) 
			  values (
				  @clientID
				, @reference
				, @batchID
				, @qFormSvcRecJSON
				, @today
				, @userID
				, 1    
			  )
		    end /* Validate*/				 

		end /* Qform */

	    /*============================================================
	     * Get index for next record
	     *============================================================*/ 
	
	    set @curIdx = @curIdx + 1
	end   
   
 /*============================================================
  * If we reach this point all is good.  Commit and exit
  *============================================================*/ 
	    
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

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc_And_Doc_Stats_Or_QForm] TO [webuser]
GO

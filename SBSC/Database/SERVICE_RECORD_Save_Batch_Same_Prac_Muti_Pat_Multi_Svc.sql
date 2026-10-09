/* TODO: This is no longer used.  Refactor and remove when possible.  */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_Batch_Same_Prac_Muti_Pat_Multi_Svc') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save_Batch_Same_Prac_Muti_Pat_Multi_Svc
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Save_Batch_Same_Prac_Muti_Pat_Multi_Svc]     
 (@userID               BIGINT,    
  @userGroup            INT,    
  @userRank             INT,    
  @clientID             BIGINT,    
  @pracID               BIGINT,    
  @reference            VARCHAR(500),
  @svcRecsJSON          VARCHAR(max),
  @svcetrmde            INT,
  @editDelReason        VARCHAR(7000),    
  @validateRec          BIT,    
  @saveType             INT,    
  @recID                INT,  
  @MsgNoRec             VARCHAR(1000),    
  @MsgNoEdit            VARCHAR(1000), 
  @MsgDupRec            VARCHAR(1000),     
  @MsgDataError         VARCHAR(1000),
  @MsgNotActive         VARCHAR(1000),     
  @MsgInvCombo          VARCHAR(1000),     
  @MsgMinReq            VARCHAR(1000),     
  @MsgMinDef            VARCHAR(1000),     
  @MsgMilReq            VARCHAR(1000),     
  @MsgPatElg            VARCHAR(1000),     
  @MsgPatDOBGteDOS      VARCHAR(1000),     
  @MsgPatAbsent         VARCHAR(1000),     
  @MsgFutureDOS         VARCHAR(1000),     
  @spDetails            VARCHAR(8000) OUTPUT,    
  @recordID             BIGINT        OUTPUT)    
AS    
BEGIN     
    

/***************************************************************************    
 * SERVICE_RECORD_Save_Batch_Same_Prac_Muti_Pat_Multi_Svc */    
/**    
 * Create service records for caseloads using the passed in JSON
 *    
 * @param   @userID             
 * @param   @userGroup          
 * @param   @userRank           
 * @param   @clientID           
 * @param   @pracID             
 * @param   @reference          
 * @param   @svcRecsJSON
 * @param   @editDelReason      
 * @param   @validateRec        
 * @param   @saveType           
 * @param   @recID              
 * @param   @MsgNoRec           
 * @param   @MsgNoEdit          
 * @param   @MsgDupRec          
 * @param   @MsgDataError          
 * @param   @MsgNotActive       
 * @param   @MsgInvCombo        
 * @param   @MsgMinReq          
 * @param   @MsgMinDef          
 * @param   @MsgMilReq          
 * @param   @MsgPatElg          
 * @param   @MsgPatDOBGteDOS    
 * @param   @MsgPatAbsent       
 * @param   @MsgFutureDOS               
 * @returns @spDetails
 * @returns @recordID 
 *          
 ***************************************************************************/         
     
SET NOCOUNT ON    

DECLARE @tranOpen                           AS BIT            -- Is a transaction open    
DECLARE @serviceTypeID                      AS BIGINT
DECLARE @batchIDAssRecID                    AS BIGINT = null
declare @svcNameID                          AS BIGINT = null

declare @planType         as int
declare @serviceType      as int
					      
declare @minIdx           as bigint
declare @maxIdx           as bigint
declare @nameID           as bigint
					      
DECLARE @batchID          AS UNIQUEIDENTIFIER = null
DECLARE @batchIDRecID     AS BIGINT           = null
declare @spDetailsOut     as varchar(8000) = ''
declare @recordIDOut      as bigint = 0
declare @recordIDOutBatch as bigint = 0
declare @rmtsSvcRecID     as bigint = 0

declare @dos               as datetime
declare @hasSvcDetFlags    as bit	 = null
declare	@svcDetFlag1   	   as bit	 = null
declare	@svcDetFlag2   	   as bit	 = null
declare	@svcDetFlag3   	   as bit	 = null
declare	@svcDetFlag4   	   as bit	 = null
declare	@hasOrpDocID   	   as bit	 = null
declare	@orpDocID   	   as bigint = null
declare @RMTSMoment        as bit    = null
declare @rmtsNameID        as bigint = null
declare	@assmtMode   	   as int    = 3

declare @groupID as bigint = null
declare @svcClassNameID as bigint = null
declare @svcClassName as varchar(1000) = ''
declare @patName as varchar(500) = ''

  /*-------------------------------    
   * Declare variables for     
   * our JSON object
   *------------------------------*/

  declare @curIdx int
  declare @planSelection int = null
  declare @sessionDeliveryStatus int = null
  declare @patID bigint
  declare @planTypeID int
  declare @isIEPOrIFSP bit
  declare @startTime datetime
  declare @numMins int
  declare @patAbsent bit 
  declare @pracAbsent bit
  declare @makeupSession bit
  declare @notes                            varchar(max)
  declare @svcNotesFormBuilderQuestionsJSON varchar(max)
  declare @svcNotesFormBuilderAnswersJSON   varchar(max)
  declare @patientGoalProgressJSON          varchar(max)
  declare @hasPatientGoalTrackingData       bit
  declare @svcRecs table (id int IDENTITY(1,1), jsonObj VARCHAR(max))
 
 
 declare @svcDetails table (
      idx                   bigint identity(1,1)
    , patID                 bigint
	, nameID                bigint         
    , planSelection         int
    , startTime             time(0)
    , numMins               int
    , sessionDeliveryStatus int
    , notes                            varchar(max)
	, svcNotesFormBuilderQuestionsJSON varchar(max)
	, svcNotesFormBuilderAnswersJSON   varchar(max)
	, patientGoalProgressJSON          varchar(max)
	, hasPatientGoalTrackingData       bit
	, dateOfService         Datetime
	, hasSvcDetFlags        bit
	, svcDetFlag1           bit
	, svcDetFlag2           bit
	, svcDetFlag3           bit
	, svcDetFlag4           bit
	, hasOrpDocID           bit
	, orpDocID              bigint
	, RMTSMoment            bit

	, iepOrIFSP             bit 
    , patAbsent             bit
	, pracAbsent            bit
	, makeupSession         bit
    --, svcTypeID             int
    --, svcSubTypeID          int
    --, planTypeID            int    
    --, recordSvcRec          bit 
	, svcRecID              bigint
)

BEGIN TRY    
    
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

IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
if (@pracID      IS NULL) RAISERROR ('Practitioner required', 11, 1) 
if (@clientID    IS NULL) RAISERROR ('Client required', 11, 1) 



/*============================================================
  * Break the details in the incoming json into something 
  * easier to work with
  *============================================================*/

insert into @svcRecs 
select 
  svr.value
FROM OPENJSON(@svcRecsJSON) as svr

/*============================================================
 * Partially populate svc details with the details passed in
 *============================================================*/
 
insert into @svcDetails (  
    patID                
  , nameID         
  , planSelection        
  , startTime            
  , numMins              
  , sessionDeliveryStatus
  , notes       

  , svcNotesFormBuilderQuestionsJSON 
  , svcNotesFormBuilderAnswersJSON
  , patientGoalProgressJSON
  , hasPatientGoalTrackingData

  , dateOfService         
  , hasSvcDetFlags
  , svcDetFlag1   
  , svcDetFlag2   
  , svcDetFlag3   
  , svcDetFlag4
  , hasOrpDocID
  , orpDocID 
  , RMTSMoment 
      
  , iepOrIFSP            
  , patAbsent            
  , pracAbsent
  , makeupSession
  , svcRecID
 
 ) 
select 
    JSON_VALUE(svr.jsonObj, '$.patID')
  , JSON_VALUE(svr.jsonObj, '$.serviceNameID')
  , JSON_VALUE(svr.jsonObj, '$.planTypeSelectionID')
  , JSON_VALUE(svr.jsonObj, '$.startTime')
  , JSON_VALUE(svr.jsonObj, '$.numMins')
  , JSON_VALUE(svr.jsonObj, '$.sessionDeliveryStatus')
  , JSON_VALUE(svr.jsonObj, '$.notes')

  , nq2.frmBldrQuestions
  , na2.frmBldrAnswers
  , pgp.patGoalProg
  , hpgp.hasPatGoalProg

  , JSON_VALUE(svr.jsonObj, '$.dosStr')
  , JSON_VALUE(svr.jsonObj, '$.hasSvcDetFlags')
  , JSON_VALUE(svr.jsonObj, '$.svcDetFlag1')   
  , JSON_VALUE(svr.jsonObj, '$.svcDetFlag2')   
  , JSON_VALUE(svr.jsonObj, '$.svcDetFlag3')   
  , JSON_VALUE(svr.jsonObj, '$.svcDetFlag4')
  , JSON_VALUE(svr.jsonObj, '$.hasOrpDocumentID')   
  , JSON_VALUE(svr.jsonObj, '$.orpDocumentID')  
  , JSON_VALUE(svr.jsonObj, '$.RMTSMoment')  

  , null
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
    na1.[value] as hasPatGoalProg
  FROM OPENJSON(svr.jsonObj) as na1
  where 
    (na1.[key] = 'hasPatientGoalTracking')
) as hpgp

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
		  @planSelection          = planSelection
		, @nameID				  = nameID
		, @sessionDeliveryStatus  = sessionDeliveryStatus
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
	 from @svcDetails 

	 where (idx = @curIdx)

	 /*============================================================
      * Skip if plan type is not selected for assessments
      *============================================================*/

	 if (@svcetrmde = @assmtMode and ((isnull(@planSelection,'') = '') or (isnull(@nameID,'') = '')))
	 begin
		set @curIdx = @curIdx + 1
	    continue
	 end
	 
	 /*============================================================
      * RMTS Moment
      *============================================================*/
	 
	 if ((@RMTSMoment = 1) and (@startTime is null))
	 begin
	   RAISERROR ('Time entry is required for RMTS moment reporting', 11, 1)
	 end

	 /*============================================================
      * Derive isIEPOrIFSP from plan selection
      *============================================================*/

	 if (@planSelection = 1) /* IEP/ISP */
	 begin
	    set @isIEPOrIFSP = 1
	 end

	 else if (@planSelection = 2) /* Other Authorized Plan */
	 begin
		set @isIEPOrIFSP = 0
	 end

	 else if (@planSelection = 3) /* No Authorized Plan */
	 begin
		set @isIEPOrIFSP = 0
	 end
     else 
	 begin
	  RAISERROR ('Invalid plan selection', 11, 1)
	 end
	 
	 update @svcDetails set iepOrIFSP = @isIEPOrIFSP where idx = @curIdx

	 /*============================================================
      * Assessment validations
      *============================================================*/

	  set @groupID  = null
	  set @svcClassNameID = null
	  set @svcClassName = ''
	  set @patName = (select (FIRST_NAME + ' ' + LAST_NAME) from dbo.PATIENTS_Patient where PATIENT_ID = @patID )
 
	  select top 1
	      @groupID        = gg.GROUP_ID
	    , @svcClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID
	    , @svcClassName   = png.GROUP_SERVICE_CLASS_NAME
	   
	   
	  from dbo.PRACTITIONER_Client       as pc
	  join dbo.PRACTITIONER_Practitioner as pp on  pp.PRACTITIONER_ID = pc.PRACTITIONER_ID
	  join dbo.PRACTITIONER_GROUPS       as pg on  pg.PRACTITIONER_ID = pp.PRACTITIONER_ID
	                                           and pg.GROUP_TYPE in (1,2)
	  join dbo.GROUP_Group               as gg on  gg.GROUP_ID = pg.GROUP_ID
	                                           and gg.GROUP_TYPE in (1,2)
	   
	  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as png on png.GROUP_SERVICE_CLASS_PARTITION_ID = 100
	                                                                         and png.GROUP_ID = gg.GROUP_ID
	   
	  where (
	   
	        (pc.CLIENT_ID       = @clientID) 
	    and (pc.PRACTITIONER_ID = @pracID) 
	  )
	   
	  declare @currentFyID  as bigint = null
	   
	  declare @assmtSvcsRecordedDetails as table (
	   
	      svcRecID    bigint
	    , svcSubType1 bigint
	    , pracID      bigint
	    , svcName     varchar(2000)
	    , dos          date
	    , fyID         bigint
	  )

	  delete from @assmtSvcsRecordedDetails 

	  declare @assmtSvcsRecordedSummary as table (
	   
	      fyID           bigint
	    , hasTri   bit default(0)
	    , hasAnn         bit default(0)
	    , hasAmd         bit default(0)
	  )
	   
      delete from @assmtSvcsRecordedSummary


	  /* Get current fiscal year */
	   
	  select top 1
	    @currentFyID = fy.ID
	  from dbo.COMPANY_FISCAL_YEARS as fy
	  where (@dos between fy.FY_START and fy.FY_END)
	   
	  /* Initial popululation of our summary table (put placeholder data in) */
	   
	  insert into @assmtSvcsRecordedSummary (fyID) values (@currentFyID)
	   
	  insert into @assmtSvcsRecordedSummary (fyID)
	  select top 1 fyID = fy.ID from dbo.COMPANY_FISCAL_YEARS as fy
	  where dateadd(year,-1,@dos) between fy.FY_START and fy.FY_END
	   
	  insert into @assmtSvcsRecordedSummary (fyID)
	  select top 1 fyID = fy.ID from dbo.COMPANY_FISCAL_YEARS as fy
	  where dateadd(year,-2,@dos) between fy.FY_START and fy.FY_END
	   
	  insert into @assmtSvcsRecordedSummary (fyID)
	  select top 1 fyID = fy.ID from dbo.COMPANY_FISCAL_YEARS as fy
	  where dateadd(year,-3,@dos) between fy.FY_START and fy.FY_END
	   
	  /* Find initial assessement (if any) regardless of time window */
	   
	  declare @hasInitialAssmt       as bit = 0
	  declare @initialAssmtSvcRecID  as bigint = 0
	  declare @initialAssmtDos       as date = null
	   
	  select top 1  
	    @hasInitialAssmt       = 1
	  , @initialAssmtSvcRecID  = sr.id
	   ,@initialAssmtDos       = sr.dos 
	  from dbo.SERVICE_RECORDS                     as sr
	  where (
	        (sr.clientID             = @clientID)
	    and (sr.patID                = @patID)  
	    and (sr.pracGrpSvcClsNameID  = @svcClassNameID)
	    
	    /* Included columns */
	    
	    and (sr.isIFSPorIEP  = @isIEPOrIFSP)
	    and (sr.svcType      = 1) /* Assessements */
	    and (sr.svcSubType1 = 1000)
	    and (sr.patAbsent    = 0)
	    and (sr.pracAbsent   = 0)
	    and (sr.state not in (99,199))
	  )
	  order by 
	    sr.dos asc
	   
	  insert into @assmtSvcsRecordedDetails
	  select 
	      svcRecID = sr.id
	    , sr.svcSubType1
	    , sr.pracID
	    , svcName = @svcClassName 
	       + ' ' 
	       + isnull(st2.SERVICE_TYPE_NAME,'') 
	       + ' ' 
	       + iif( (@isIEPOrIFSP = 1),'IEP','Non IEP')
	       + ' '
	       + st1.SERVICE_TYPE_NAME  
	   
	     , dos = sr.dos 
	     , fyID  = null
	   
	  from dbo.SERVICE_RECORDS                     as sr
	  join dbo.CLAIM_Procedures_Service_Types      as st1 on st1.SERVICE_TYPE_ID = sr.svcType
	  left join dbo.CLAIM_Procedures_Service_Types as st2 on st2.SERVICE_TYPE_ID = sr.svcSubType1
	   
	  where (
	        (sr.clientID             = @clientID)
	    and (sr.patID                = @patID)  
	    and (sr.pracGrpSvcClsNameID  = @svcClassNameID)
	   
	    /* Included columns */
	    and (sr.isIFSPorIEP  = @isIEPOrIFSP)
	    and (sr.svcType      = 1) /* Assessements */
	    and (sr.patAbsent    = 0)
	    and (sr.pracAbsent   = 0)
	    and (sr.state not in (99,199))
	  )
	   
	  /* Remove any initial so all we have in the details is tri*/
	   
	  if (@hasInitialAssmt = 1)
	  begin
	    delete @assmtSvcsRecordedDetails where svcRecID = @initialAssmtSvcRecID
	  end
	   
	  /* Get summary data on what has been recorded over our time window */
	   
	  update t1
	  set 
	      t1.fyId = fy.id
	  from @assmtSvcsRecordedDetails as t1
	  join dbo.COMPANY_FISCAL_YEARS as fy on t1.dos between fy.FY_START and fy.FY_END
	   
	  update ss
	    set ss.hasTri  = 1
	  from @assmtSvcsRecordedSummary as ss
	  join @assmtSvcsRecordedDetails as sd on sd.fyID = ss.fyID
	  where (sd.svcSubType1 = 1000)
	   
	   
	  update ss
	    set ss.hasAnn = 1
	  from @assmtSvcsRecordedSummary as ss
	  join @assmtSvcsRecordedDetails as sd on sd.fyID = ss.fyID
	  where (sd.svcSubType1 = 1001)
	   
	  update ss
	    set ss.hasAmd = 1
	  from @assmtSvcsRecordedSummary as ss
	  join @assmtSvcsRecordedDetails as sd on sd.fyID = ss.fyID
	  where (sd.svcSubType1 = 1002)
	   
	  /* Find out what is being recorded */
	   
	  declare @planSelID as int
	  declare @dob        as date 
	   
	  select top 1 
	    @dob = pap.DATE_OF_BIRTH
	  from dbo.PATIENTS_Patient as pap 
	  where (pap.PATIENT_ID = @patID)
	   
	  set @planSelID = dbo.DOS_DOB_IEP_TO_PLAN_TYPE(@dos,@dob,@isIEPOrIFSP)
	   
	  declare @svcTypeBeingRecorded as bigint
	  declare @svcSubTypeBeingRecorded as bigint
	  declare @svcNameBeingRecorded as nvarchar(100)
	   
	  select top 1
	    @svcTypeBeingRecorded = sva.SERVICE_TYPE_ID
	  , @svcSubTypeBeingRecorded = sva.SERVICE_SUB_TYPE_1_ID
	  , @svcNameBeingRecorded = sva.SERVICE_NAME
	  from dbo.SERVICES_VIEW_ALL_CORE(@clientID,@groupID,@planSelID,1,@nameID,1,1,@dos,1) as sva
	   
	  
	  if (@svcSubTypeBeingRecorded = 1000)
	  begin
	    if ((@svcNameBeingRecorded like '%initial%') and (@hasInitialAssmt = 1))
	    begin
	      set @spDetails = dbo.UPDATE_DETAILS(@spDetails, 'An initial assessment for ' + @patName + ' has already been recorded.  Are you sure you want to record this type of assessment?', dbo.CONST_RET_WARN())
	    end
	    else
	    begin
	  	if exists (select * from @assmtSvcsRecordedSummary
	  				where (fyID in (@currentFyID, @currentFyID - 1, @currentFyID - 2)
	  				and (hasTri = 1)))
	        set @spDetails = dbo.UPDATE_DETAILS(@spDetails, 'An triennial assessment for ' + @patName + ' has already been recorded within the past 3 years. Please select either an “Annual” or "Amended” assessment', dbo.CONST_RET_WARN())
	    end
	  end
	  else if (@svcSubTypeBeingRecorded = 1001)
	  begin
	    if exists (select * from @assmtSvcsRecordedSummary
	  				where (fyID = fyID)
	  				and (hasAnn = 1))
	    set @spDetails = dbo.UPDATE_DETAILS(@spDetails, 'An Annual Assessment has already been recorded for the billing fiscal year, Are you sure you want to record this type of assessment?', dbo.CONST_RET_WARN())
	  end
	 
	 /*============================================================
      * Derive attendance flags from session delivery status
      *============================================================*/ 
	 
	 select 
		  @patAbsent     = t1.patAbsent
		, @pracAbsent    = t1.pracAbsent
		, @makeupSession = t1.makeupSession
	 from dbo.SERVICE_RECORD_ATTENDANCE_SELECTION_ID_TO_FLAGS (@sessionDeliveryStatus) as t1


	 update @svcDetails set patAbsent = @patAbsent, pracAbsent = @pracAbsent, makeupSession = @makeupSession where (idx = @curIdx)


     set @curIdx = @curIdx + 1
 end


/*============================================================
  * Record service records
  *============================================================*/
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
  
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
		      @planSelection  = planSelection
		    , @nameID         = sd.nameID
		    , @isIEPOrIFSP    = sd.iepOrIFSP
			, @patID          = sd.patID
			, @startTime      = sd.startTime
			, @numMins        = sd.numMins
		    , @notes          = sd.notes
			, @svcNotesFormBuilderQuestionsJSON = sd.svcNotesFormBuilderQuestionsJSON
            , @svcNotesFormBuilderAnswersJSON   = sd.svcNotesFormBuilderAnswersJSON
			, @patientGoalProgressJSON          = sd.patientGoalProgressJSON
			, @hasPatientGoalTrackingData       = sd.hasPatientGoalTrackingData
			, @patAbsent      = sd.patAbsent
			, @pracAbsent     = sd.pracAbsent
			, @makeupSession  = sd.makeupSession
			, @dos            = sd.dateOfService
			, @hasSvcDetFlags = sd.hasSvcDetFlags
			, @svcDetFlag1    = sd.svcDetFlag1
			, @svcDetFlag2    = sd.svcDetFlag2
			, @svcDetFlag3    = sd.svcDetFlag3
			, @svcDetFlag4	  = sd.svcDetFlag4
			, @hasOrpDocID    = sd.hasOrpDocID
			, @orpDocID       = sd.orpDocID
			, @RMTSMoment     = sd.RMTSMoment

		 from @svcDetails as sd
		 where (idx = @curIdx)	

		 /*============================================================
		  * Skip if plan type is not selected for assessments
		  *============================================================*/
		 
		 if (@svcetrmde = @assmtMode and ((isnull(@planSelection,'') = '') or (isnull(@nameID,'') = '')))
		 begin
			set @curIdx = @curIdx + 1
		    continue
		 end

		/*============================================================
	     * Call the core service record save routine
	     *============================================================*/ 
		 
		 set @recordID = 0
	
		  
		   EXEC dbo.SERVICE_RECORD_Save_Core
		            @userID,                --@userID                              
			  	    @userGroup,    		    --@userGroup  
				    @userRank,			    --@userRank   
				    1,
					128,     		        --@entryType  
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
					null, /* @attendanceSelectionID*/
				    @notes,                  --@notes         
					@svcNotesFormBuilderQuestionsJSON,
                    @svcNotesFormBuilderAnswersJSON,
					@patientGoalProgressJSON,
					@hasPatientGoalTrackingData,
				    1,
						0,    /* Has fillable pdf (TODO: Add these 3 parms) */
    '[]', /* Fillable pdf selections */
	'[]', /* Fillable pdf answers*/

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
	          * Create a service record for rmts moment if needed
			  * and associate the two service records
	          *============================================================*/  
			 
			 if (@RMTSMoment = 1 
				and (
					 (@isIEPOrIFSP = 1 and @nameID != 192)
				  or (@isIEPOrIFSP = 0 and @nameID != 110)
				))
			 begin
			
				set @rmtsNameID = iif((@isIEPOrIFSP = 1),192,110)

			 	EXEC dbo.SERVICE_RECORD_Save_Core
		            @userID,                --@userID                              
			  	    @userGroup,    		    --@userGroup  
				    @userRank,			    --@userRank   
					1,
				    128,     		        --@entryType  
				    @reference,             --@reference  
				    null,    				--@batchNum   
				    null,    				--@papClmNum  
				    @dos,    				--@dos        
				    @clientID,     		    --@clientID   
				    @pracID,    			--@pracID     
				    @patID,    			    --@patID      
				    @isIEPOrIFSP,		    --@isIFSPorIEP
				    @rmtsNameID,            --@nameID    
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
					null, /* @attendanceSelectionID*/
				    @notes,                  --@notes 
					@svcNotesFormBuilderQuestionsJSON,
                    @svcNotesFormBuilderAnswersJSON,  
					null,   /* pat goal tracking not needed for RMTS moment */
					0,
				    1,
						0,    /* Has fillable pdf (TODO: Add these 3 parms) */
    '[]', /* Fillable pdf selections */
	'[]', /* Fillable pdf answers*/

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
				    @spDetailsOut OUTPUT,        --@spDetails 
				    @rmtsSvcRecID  OUTPUT     --@recordID  
		            
					set @spDetails = @spDetails + @spDetailsOut	
					
					if (@validateRec = 0)
					begin
					  insert into dbo.SERVICE_RECORDS_RMTS_MOMENTS 
					    (clientID, svcRecSvcProvided, svcRecRMTSMoment)
					  values 
					     (@clientID, @recordID, @rmtsSvcRecID) 
					end
			 end
		     
			/*============================================================
	         * Assign the unique batch ID (not used in validates)
	         *============================================================*/  
	
	        set @batchIDAssRecID = null			
		    EXEC dbo.SERVICE_RECORD_BATCH_ID_Assign @userID, @userGroup, @userRank, @saveType, @validateRec, @batchID, @curIdx, @recordID, @batchIDAssRecID OUTPUT 
		 	   
			if (@validateRec = 0)
			begin
			   update @svcDetails set svcRecID = @recordID where idx = @curIdx
		    end
		 
		  
			
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

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Save_Batch_Same_Prac_Muti_Pat_Multi_Svc] TO [webuser]
GO

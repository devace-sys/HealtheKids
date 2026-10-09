USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_Vision_Hearing_Screening') AND type in (N'P', N'PC'))
	DROP PROCEDURE dbo.SERVICE_RECORD_Save_Vision_Hearing_Screening
GO


CREATE PROCEDURE [dbo].[SERVICE_RECORD_Save_Vision_Hearing_Screening](
  @userID           BIGINT,    
  @userGroup        INT,    
  @userRank         INT,    
  @reference        VARCHAR(500),           
  @clientID         BIGINT,     
  @visionPracID     BIGINT,    
  @hearingPracID    BIGINT, 
  @dos              DATETIME, 
  @patID            BIGINT,    
  @notes            VARCHAR(max),
  
  @serviceTypesJSON VARCHAR(max),
  @editDelReason    VARCHAR(7000),    
  @validateRec      BIT,    
  @saveType         INT,    
  @recID            BIGINT,    
  @msgDupRec        VARCHAR(1000),
  @MsgNotActive     VARCHAR(1000),
  @MsgNoRec         VARCHAR(1000),
  @MsgNoEdit        VARCHAR(1000),
  @MsgDataError     VARCHAR(1000),
  @MsgInvCombo    	VARCHAR(1000),
  @MsgMinReq		VARCHAR(1000),
  @MsgMinDef		VARCHAR(1000),
  @MsgMilReq		VARCHAR(1000),
  @MsgPatElg		VARCHAR(1000),
  @MsgPatDOBGteDOS	VARCHAR(1000),
  @MsgPatAbsent		VARCHAR(1000),
  @MsgFutureDOS		VARCHAR(1000),
  @spDetails        VARCHAR(8000) OUTPUT,    
  @recordID         BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_Save_Vision_Hearing_Screening */    
/**    
 * Creates a new, edits existing, or deletes (hides) existing service record    
 * and manages any associated claim records for vision and hearing.    
 *     
 * @returns      Validation or error details    
 * @returns      New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    
  
DECLARE @tranOpen                           AS BIT            -- Is a transaction open    
DECLARE @pracVisionGroupID                  AS BIGINT
DECLARE @pracHearingGroupID                 AS BIGINT
DECLARE @serviceTypeIDVision                AS BIGINT
DECLARE @serviceTypeIDHearingThreshold      AS BIGINT
DECLARE @serviceTypeIDHearingPureTone       AS BIGINT
DECLARE @batchIDAssRecID                    AS BIGINT = null
DECLARE @recordVision                       AS BIT
DECLARE @recordHearingThreshold             AS BIT
DECLARE @recordHearingPureTone              AS BIT
declare @svcNameIDForVisionSvcRec           AS BIGINT  = null
declare @svcNameIDForHearingThresholdSvcRec AS BIGINT = null
declare @svcNameIDForHearingPureToneSvcRec  AS BIGINT = null

declare @planType      as int = 3
declare @serviceType   as int = 1

declare @minIdx        as bigint
declare @maxIdx        as bigint
declare @curIdx        as bigint
declare @pracID        as bigint
declare @nameID        as bigint
declare @groupID       as bigint
DECLARE @batchID       AS UNIQUEIDENTIFIER = null
DECLARE @batchIDRecID  AS BIGINT           = null
declare @spDetailsOut  as varchar(8000) = ''
declare @recordIDOut   as bigint = 0

declare @svcsToRecord as table (
    idx        int identity(1,1)
  , pracID     bigint 
  , groupID    bigint
  , nameID     bigint
  unique clustered (idx)
)

/*============================================================
 * Init
 *============================================================*/  
 
set @spDetails    = ''
set @recordID     = 0
set @tranOpen     = 0
set @planType     = 3 /* Always non iep */
set @serviceType  = 1 /* Always assmt */
set @saveType     = 1 /* Always new rec */
set @spDetailsOut = ''
set @recordIDOut  = 0

/*============================================================
 * Clean up incoming parms
 *============================================================*/  

set @notes         = trim(isnull(@notes,''))
set @visionPracID  = isnull(@visionPracID,0)
set @hearingPracID = isnull(@hearingPracID,0)

BEGIN TRY

/*============================================================
 * Extract flags for service selection(s)
 *============================================================*/  

set @recordVision           = JSON_VALUE(@serviceTypesJSON,'$.vision')
set	@recordHearingThreshold = JSON_VALUE(@serviceTypesJSON,'$.hearingthreshold')
set	@recordHearingPureTone  = JSON_VALUE(@serviceTypesJSON,'$.hearingpuretone')

/*============================================================
 * If no services are selected exit
 *============================================================*/  

if (
		(@recordVision           = 0 ) 
	and (@recordHearingThreshold = 0 )
	and (@recordHearingPureTone  = 0 )
)
begin
	RAISERROR ('No screenings selected to record', 11, 1) 
end


/*============================================================
 * If we are recording a vision screen, verify that a
 * practitioner is selected to perform tests and they 
 * have a discipine group ID
 *============================================================*/  

if (@recordVision = 1)
begin
  if (@visionPracID <= 0) RAISERROR ('Please select a vision practitioner', 11, 1) 
  set @pracVisionGroupID = null
  select top 1 @pracVisionGroupID = pg.[GROUP_ID] from dbo.PRACTITIONER_GROUPS as pg
  where ((pg.[PRACTITIONER_ID] = @visionPracID) and (pg.[GROUP_TYPE] in( 1,2)))
  set @pracVisionGroupID = isnull(@pracVisionGroupID,0)
  if (@pracVisionGroupID <= 0) RAISERROR ('The practitioner selected for vision does not have a discipline group assigned', 11, 1) 
end

/*============================================================
 * If we are recording any hearing screens, verify that a
 * practitioner is selected to perform tests and they
 * have a discipline group ID
 *============================================================*/  

if ((@recordHearingThreshold = 1) or (@recordHearingPureTone = 1))
begin
	if (@hearingPracID <= 0) RAISERROR ('Please select a hearing practitioner', 11, 1) 
	set @pracHearingGroupID = null
	select top 1 @pracHearingGroupID = pg.[GROUP_ID] from dbo.PRACTITIONER_GROUPS as pg
	where ((pg.[PRACTITIONER_ID] = @hearingPracID) and (pg.[GROUP_TYPE] in( 1,2)))
	set @pracHearingGroupID = isnull(@pracHearingGroupID,0)
	if (@pracHearingGroupID <= 0) RAISERROR ('The practitioner selected for hearing does not have a discipline group assigned', 11, 1)
end

/*============================================================
 * If we are recording a vision screen
 * get the service selection nameID for the 
 * in person vision screen.  If no selection is found then 
 * we exit.  Otherwise insert the unique service
 * data into a table var for later processing
 *============================================================*/  

if (@recordVision = 1)
begin
  set @svcNameIDForVisionSvcRec = null
  select top 1
    @svcNameIDForVisionSvcRec = svac.SERVICE_NAME_ID
		from dbo.SERVICES_VIEW_ALL_CORE (  
				   @clientID
				 , @pracVisionGroupID
				 , @planType
				 , @serviceType
				 , null
				 , 1
				 , 1
				 , @dos
				 , 1) as svac
		where (svac.SERVICE_NAME_ID in (12))

    set @svcNameIDForVisionSvcRec = isnull(@svcNameIDForVisionSvcRec,0)
	if (@svcNameIDForVisionSvcRec <= 0) RAISERROR ('According to our data the practitioner selected for vision screening either has no approved in person option or they are not allowed to render this service', 11, 1) 

    insert into @svcsToRecord (pracID,groupID,nameID) values (@visionPracID, @pracVisionGroupID, @svcNameIDForVisionSvcRec) 

end

/*============================================================
 * If we are recording a hearing threshold screen
 * get the service selection nameID for the 
 * in person threshold screen 
 *
 * If no selection is found then the practitioner is not
 * qualified and we exit.  Otherwise insert the unique service
 * data into a table var for later processing
 *============================================================*/  

if (@recordHearingThreshold = 1)
begin
	set @svcNameIDForHearingThresholdSvcRec = null
	select top 1 
	  @svcNameIDForHearingThresholdSvcRec = svac.SERVICE_NAME_ID
	from dbo.SERVICES_VIEW_ALL_CORE (  
	           @clientID
			 , @pracHearingGroupID
			 , @planType
			 , @serviceType
			 , null
			 , 1
			 , 1
			 , @dos
			 , 1) as svac
	where (svac.SERVICE_NAME_ID in (30))
	set @svcNameIDForHearingThresholdSvcRec = isnull(@svcNameIDForHearingThresholdSvcRec,0)
	if (@svcNameIDForHearingThresholdSvcRec <= 0) RAISERROR ('According to our data the practitioner selected for hearing (threshold) screening either has no approved in person option or they are not allowed to render this service', 11, 1) 
    insert into @svcsToRecord (pracID,groupID,nameID)  values (@hearingPracID, @pracHearingGroupID,@svcNameIDForHearingThresholdSvcRec) 
end

/*============================================================
 * If we are recording a hearing pure tone screen
 * get the service selection nameID for the 
 * in person pure tone screen 
 * If no selection is found then the practitioner is not
 * qualified and we exit.  Otherwise insert the unique service
 * data into a table var for later processing
 *============================================================*/  

if (@recordHearingPureTone = 1)
begin 
	set @svcNameIDForHearingPureToneSvcRec = null
	select top 1 
	  @svcNameIDForHearingPureToneSvcRec = svac.SERVICE_NAME_ID 
	from dbo.SERVICES_VIEW_ALL_CORE (  
				@clientID
				, @pracHearingGroupID
				, @planType
				, @serviceType
				, null
				, 1
				, 1
				, @dos
				, 1) as svac
 
	where (svac.SERVICE_NAME_ID in (3))
	
	set @svcNameIDForHearingPureToneSvcRec = isnull(@svcNameIDForHearingPureToneSvcRec,0)
	if (@svcNameIDForHearingPureToneSvcRec <= 0) RAISERROR ('According to our data the practitioner selected for hearing (pure tone) screening either has no approved in person option or they are not allowed to render this service', 11, 1) 

    insert into @svcsToRecord (pracID,groupID,nameID)  values (@hearingPracID, @pracHearingGroupID,@svcNameIDForHearingPureToneSvcRec) 

end

/*============================================================
 * If we reach this point we have service records to either
 * validate or save
 *============================================================*/  

BEGIN TRANSACTION  
SET @TranOpen  = 1 

/*============================================================
 * Create a unique batch ID (not used in validates)
 *============================================================*/  

EXEC dbo.SERVICE_RECORD_BATCH_ID_Create @userID, @userGroup, @userRank, @saveType, @validateRec, @batchIDRecID OUTPUT , @batchID OUTPUT 

/*============================================================
 * Create 1 to 3 new service records
 *============================================================*/  

select @minIdx = min(idx), @maxIdx = max(idx) from @svcsToRecord
set @curIdx = @minIdx

while (@curIdx <= @maxIdx)
begin
  
  set @pracID = null
  set @groupID = null
  set @nameID = null
  set @spDetailsOut = ''
  set @recordIDOut  = 0

 /*============================================================
   * Get data for service
   *============================================================*/  

  select top 1 
      @pracID     = str.pracID
    , @groupID    = str.groupID
	, @nameID     = str.nameID 
  from @svcsToRecord as str 
  where (str.idx = @curIdx)
  
  /*============================================================
   * Call the core service record save routine
   *============================================================*/  

  EXEC dbo.SERVICE_RECORD_Save_Core
	          @userID,                                             
			  @userGroup,    
			  @userRank,
			  1, /* Claimable */
			  100,     
			  @reference,           
			  null,    
			  null,    
			  @dos,    
			  @clientID,     
			  @pracID,    
			  @patID,    
			  0,          /*Always non iep */   
			  @nameID,
			  0,         /* No ORP required for screening */
			  null,
			  null,
			  0,
			  null,
			  null,
			  null,
			  null,
			  null,
			  0,    
			  0,    
			  0,    
			  0,    
			  0,    
			  0,    
			  0,    
			  0,    
			  0,
			  0,  /* Patient is never absent */
			  0,  /* Practitioner is never absent */
			  0,  /* This is never a makup session */
			  null, /* @attendanceSelectionID*/
			  @notes,    
			  null,
	          null,
			  null,
			  0, /* goal tracking */
			  1, /* Billing program */
			  0,    /* Has fillable pdf (TODO: Add these 3 parms) */
             '[]', /* Fillable pdf selections */
	         '[]', /* Fillable pdf answers*/
			  @editDelReason,    
			  @validateRec,    
			  @saveType,    
			  @recID,    
			  @msgDupRec, 
			  @msgInvCombo ,   
			  @MsgNoRec,      
			  @MsgNoEdit,     
			  @MsgDataError,       
			  @MsgMinReq,    
			  @MsgMinDef,     
			  @MsgMilReq,    
			  @MsgPatElg,
			  @MsgPatDOBGteDOS,
			  @MsgNotActive,  
			  @MsgPatAbsent,
			  @MsgFutureDOS,
			  @spDetailsOut OUTPUT,    
			  @recordIDOut  OUTPUT      

	 /*============================================================
      * Pass back current details and record id just in case we
	  * have an exception thrown
      *============================================================*/  

      set @spDetails = @spDetails + @spDetailsOut
      set @recordID  = @recordIDOut
	 
	 /*============================================================
      * Assign the unique batch ID (not used in validates)
      *============================================================*/  

     set @batchIDAssRecID = null			
	 EXEC dbo.SERVICE_RECORD_BATCH_ID_Assign @userID, @userGroup, @userRank, @saveType, @validateRec, @batchID, @curIdx, @recordIDOut, @batchIDAssRecID OUTPUT 
    
     /*============================================================
      * Get index for next record
      *============================================================*/  

	 set @curIdx = @curIdx + 1

end /* While*/

COMMIT TRANSACTION
set @tranOpen = 0

RETURN(0)    

END TRY    

BEGIN CATCH    
   
if (@tranOpen  = 1) ROLLBACK TRANSACTION

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
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Save_Vision_Hearing_Screening] TO [webuser]
GO

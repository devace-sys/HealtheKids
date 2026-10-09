USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_ALL_INFO_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PLAN_WRITER_PLANS_ALL_INFO_Save
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[PLAN_WRITER_PLANS_ALL_INFO_Save] (
  @userID              BIGINT,
  @userGroup           INT,
  @userRank            INT, 
  @clientID            BIGINT,  
  @planTypeID          bigint,
  @planDataJSON        varchar(max),
  @editDelReason       VARCHAR(7000),    
  @validateRec         BIT,    
  @saveType            INT,    
  @recID               INT,    
  @MsgNoRec            VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000), 
  @MsgDupRec     VARCHAR(1000),     
  @MsgDataError  VARCHAR(1000),
  @MsgNotActive  VARCHAR(1000),     
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
 
/***************************************************************************    
 * PLAN_WRITER_PLANS_ALL_INFO_Save */    
/**    
 * Creates a new 
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 
 * @param   editDelReason   Reason for record edit or delete    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @param   recID           Record id of existing patient record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found    
 * @param   MsgNoSite       Desired error message if a siteID is not found     
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
 
SET NOCOUNT ON    
 
DECLARE @TranOpen            AS BIT  
DECLARE @auditRecID          AS BIGINT
DECLARE @today               as DATETIME = GETDATE()
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in
DECLARE @groupSvcClassNameID AS bigint = null
  
DECLARE @spDetailsOrpDocs             VARCHAR(8000)
DECLARE @recordIDOrpDocs              bigint
DECLARE @patID                        bigint		
DECLARE @planDate                     datetime		
DECLARE @diagnosisID		          bigint		
DECLARE @diagnosisName		          varchar(256)	
DECLARE @diagnosisDesc		          varchar(max)	
DECLARE @orpDocSelectionsJSON         varchar(max)	
DECLARE @participantsJSON             varchar(max)	
DECLARE @participantID                bigint
DECLARE @participantAction            bigint
DECLARE @planCreatorSigned            bit
DECLARE @planCreatorSignedDate        datetime
DECLARE @planCreatorSignatureImg      varchar(max)
DECLARE @prevPlanCreatorSignatureImg  varchar(max) -- used for saving user signature if it has changed
DECLARE @prevPlanCreatorSignatureDate datetime
DECLARE @prevSignatureRecID           bigint
DECLARE @planCreatorUserID            bigint
DECLARE @curIdx int
DECLARE @minIdx	int
DECLARE @maxIdx	int

DECLARE @orpDocRefID   bigint
DECLARE @orpDocType    bigint

DECLARE @planORPDocsRecs table (id int IDENTITY(1,1), jsonObj VARCHAR(max))
DECLARE @planParticipantsRecs table (id int IDENTITY(1,1), jsonObj VARCHAR(max))

DECLARE @planORPDocs table (
      idx                   bigint identity(1,1)
    , orpDocRefID              bigint
	, orpDocType            bigint
)

DECLARE @planParticipants table (
      idx                   bigint identity(1,1)
    , participantID			bigint
	, participantAction     bigint
)


BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @spDetails  = ''    
SET @recordID = NULL 
SET @today    = GETDATE()
  
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
 
IF (@userID      IS NULL) RAISERROR ('userID is required',   11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*-------------------------------    
 * Parse JSON data
 *------------------------------*/  
set @patID                   = JSON_VALUE(@planDataJSON           , '$.patID')			
set @planDate                = JSON_VALUE(@planDataJSON           , '$.planDate')
set @diagnosisID		     = JSON_VALUE(@planDataJSON           , '$.diagnosisID')
set @diagnosisName		     = JSON_VALUE(@planDataJSON           , '$.diagnosisName')
set @diagnosisDesc		     = JSON_VALUE(@planDataJSON           , '$.diagnosisDesc')
set @orpDocSelectionsJSON    = JSON_QUERY(@planDataJSON           , '$.orpDocSelectionsJSON')
set @participantsJSON        = JSON_QUERY(@planDataJSON           , '$.participantsJSON')
set @planCreatorSigned       = JSON_VALUE(@planDataJSON           , '$.planCreatorSigned')
set @planCreatorSignedDate   = JSON_VALUE(@planDataJSON           , '$.planCreatorSignedDate')
select @planCreatorSignatureImg = [value] from OPENJSON(@planDataJSON) where [key] = 'planCreatorSignatureImg'

if (@planDate is null) set @planDate = CONVERT(date,@today)

if (@diagnosisName is null) RAISERROR('No diagnosis name was provided! Please select a diagnosis for plan.',11,2)

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
 
  SET @TranOpen = 1     
 
/*-------------------------------    
 * create plan
 *------------------------------*/ 
 exec dbo.PLAN_WRITER_PLANS_SAVE_CORE
     @userID            
   , @userGroup          
   , @userRank           
   , @clientID           
   , @patID          
   , @groupSvcClassNameID
   , @planTypeID         
   , @planDate           
   , @editDelReason      
   , @validateRec        
   , @saveType           
   , @recID              
   , @MsgNoRec           
   , @MsgNoEdit    
   , @MsgDupRec    
   , @MsgDataError 
   , @MsgNotActive 
   , @spDetails    OUTPUT
   , @recordID     OUTPUT

if ((@recordID is null) or (@recordID = 0))
begin
	RAISERROR('Call to create a plan failed. Could not create plan', 11, 1)
end

update dbo.PLAN_WRITER_PLANS
set planCreatorSigned       = @planCreatorSigned
  , planCreatorSignedDate   = @planCreatorSignedDate
  , planCreatorSignatureImg = @planCreatorSignatureImg
where id = @recordID

/*============================================================
 * save user's signature if needed
 *============================================================*/
 if (@planCreatorSignatureImg is not null)
 begin
	select top 1 
		@planCreatorUserID = CREATED_BY
	from dbo.PLAN_WRITER_PLANS
	where id = @recordID

	--only a user is allowed to save their own signature
	if (@planCreatorUserID = @userID)
	begin
		select top 1 
			  @prevSignatureRecID           = id
			, @prevPlanCreatorSignatureImg  = signatureBase64 
			, @prevPlanCreatorSignatureDate = createdOrLastModifiedOn
		from users.dbo.USER_SIGNATURES_VIEW_CORE (
			  @userID             
			, @userGroup          
			, @userRank           
			, @planCreatorUserID    
			, null  --@signaturePersonID  
			, null  --@active
			, null  --@recID 
		) as us
		order by us.id desc	

		-- if signature has changed, update
		if (	((@prevPlanCreatorSignatureImg is null)  or (@prevPlanCreatorSignatureImg != @planCreatorSignatureImg)) 
			and ((@prevPlanCreatorSignatureDate is null) or (@prevPlanCreatorSignatureDate < @planCreatorSignedDate))
		)
		begin	
			declare @signatureSaveType int = iif(@prevSignatureRecID is null, 1, 2)

			exec users.[dbo].[USER_SIGNATURES_SAVE_CORE]		             
				  @userID              
				, @userGroup           
				, @userRank            
				, @planCreatorSignatureImg   --@signatureBase64	
				, @planCreatorUserID         --@signatureUserID	
				, null  --@signaturePersonID
				, 1     --@active     		
				, ''    --@editDelReason       
				, 0     --@validateRec         
				, @signatureSaveType     --@saveType            
				, @prevSignatureRecID  --@recID               
				, @MsgNoRec            
				, @MsgNoEdit           
				, @MsgDupRec           
				, @MsgDataError        
				, @MsgNotActive        
				, null  --@spDetails              
				, null  --@recordID 
		end    
	end       
 end
/*============================================================
 * save diagnosis
 *============================================================*/
delete from [dbo].[PLAN_WRITER_PLANS_DIAGNOSES] where (PLAN_ID = @recordID)

insert into [dbo].[PLAN_WRITER_PLANS_DIAGNOSES] 
(
		  CLIENT_ID
		, PLAN_ID
		, DIAGNOSIS_ID
		, NAME
		, DESCRIPTION
) values
(
		  @clientID        
		, @recordID          
		, @diagnosisID     
		, @diagnosisName             
		, @diagnosisDesc 
)     

/*============================================================
 * Populate ORP Docs tbl var
 *============================================================*/
 delete from [dbo].[PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_FLAGGED_FOR_USE] where (PLAN_ID = @recordID)
 delete from [dbo].[PLAN_WRITER_PLANS_CONDITIONS_SERVICE_DESCRIPTIONS_FLAGGED_FOR_USE] where (PLAN_ID = @recordID)

 insert into @planORPDocsRecs
 select 
  orps.value
 FROM OPENJSON(@orpDocSelectionsJSON) as orps

 insert into @planORPDocs (orpDocRefID, orpDocType)
 select 
		  JSON_VALUE(orps.jsonObj, '$.orpDocRefID')
		, JSON_VALUE(orps.jsonObj, '$.orpDocType')

from @planORPDocsRecs as orps

/*============================================================
 * Get control values we will use for our loop
 *============================================================*/

select @minIdx = min(idx), @maxIdx = max(idx) from @planORPDocs
set @curIdx = @minIdx

/*============================================================
 * Begin the orders loop
 *============================================================*/
 
while (@curIdx <= @maxIdx)
begin

	/*============================================================
     * Get incoming columns
     *============================================================*/
	 select top 1
		  @orpDocRefID      = orpDocRefID
		, @orpDocType	 = orpDocType
		
	 from @planORPDocs 
	 where (idx = @curIdx)

	/*============================================================
     * Flag order or profile for inclusion in plan
     *============================================================*/
	 if (@orpDocType = 2)
	 begin
		exec [dbo].[PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_TOGGLE_FLAGGED_FOR_USE_CORE]
			  @userID             
			, @userGroup          
			, @userRank           
			, @clientID           
			, @groupSvcClassNameID
			, @recordID -- @planID             
			, null      -- @conditionID       
			, @editDelReason 
			, @validateRec   
			, @orpDocRefID         
			, @MsgNoRec      
			, @MsgNoEdit     
			, @spDetailsOrpDocs      OUTPUT    
			, @recordIDOrpDocs       OUTPUT  
	 end

	 else if (@orpDocType = 3)
	 begin
		exec [dbo].[PLAN_WRITER_PLANS_CONDITIONS_SERVICE_DESCRIPTIONS_TOGGLE_FLAGGED_FOR_USE_CORE] 
			  @userID             
			, @userGroup          
			, @userRank           
			, @clientID           
			, @groupSvcClassNameID
			, @recordID -- @planID             
			, null      -- @conditionID        
			, @editDelReason 
			, @validateRec   
			, @orpDocRefID         
			, @MsgNoRec      
			, @MsgNoEdit     
			, @spDetailsOrpDocs     OUTPUT 
			, @recordIDOrpDocs      OUTPUT   
	 end

     set @curIdx = @curIdx + 1
 end

/*============================================================
 * Populate participants tbl var
 *============================================================*/
 delete from [dbo].[PLAN_WRITER_PLANS_PATIENT_PERSONS] where (PLAN_ID = @recordID)

 insert into @planParticipantsRecs
 select 
  parts.value
 FROM OPENJSON(@participantsJSON) as parts

 insert into @planParticipants
 (
    participantID   
  , participantAction   
 )
 select 
    JSON_VALUE(parts.jsonObj, '$.participantID')    
  , JSON_VALUE(parts.jsonObj, '$.participantAction')   

 from @planParticipantsRecs as parts

/*============================================================
 * Get control values we will use for our loop
 *============================================================*/

select @minIdx = min(idx), @maxIdx = max(idx) from @planParticipants
set @curIdx = @minIdx

/*============================================================
 * Begin the participants loop
 *============================================================*/
while (@curIdx <= @maxIdx)
begin

	/*============================================================
     * Get incoming columns
     *============================================================*/
	 select top 1
		   @participantID       =   participantID   
		 , @participantAction   = 	participantAction   

	 from @planParticipants 
	 where (idx = @curIdx)
			 
	/*============================================================
     * Save participants to plan
     *============================================================*/
	 insert into dbo.PLAN_WRITER_PLANS_PATIENT_PERSONS
	 (
		  CLIENT_ID        
		, PLAN_ID          
		, PATIENT_PERSON_ID
		, ACTION          
	 )
	 values
	 (
		  @clientID        
		, @recordID          
		, @participantID
		, @participantAction          
	 )

     set @curIdx = @curIdx + 1
 end


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
 
GRANT EXECUTE ON  [dbo].[PLAN_WRITER_PLANS_ALL_INFO_Save] TO [webuser]
GO
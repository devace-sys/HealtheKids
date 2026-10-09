USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SAVE_CORE
GO

/*-------------------------------
 * Create 
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SAVE_CORE] (
    @userID                 BIGINT
  , @userGroup              INT  
  , @userRank               INT 
  , @clientID               BIGINT   
  , @planTypeID             BIGINT
  , @groupID                BIGINT
  , @nameID                 BIGINT
  , @formDataJSON           VARCHAR(MAX)
  , @hasPatientGoalTracking    BIT
  , @hasSessionRatingTracking  BIT 
  , @spEdSvcCodeValue          INT
  , @fillablePdfSelectionsJSON varchar(max)    
  , @editDelReason          VARCHAR(7000)
  , @validateRec            BIT
  , @saveType               INT
  , @recID                  BIGINT
  , @MsgNoRec               VARCHAR(1000)
  , @MsgNoEdit              VARCHAR(1000)
  , @MsgDupRec              VARCHAR(1000)
  , @MsgDataError           VARCHAR(1000)
  , @MsgNotActive           VARCHAR(1000)
  , @spDetails              VARCHAR(8000) OUTPUT
  , @recordID               BIGINT        OUTPUT )
AS    
BEGIN     
    
/***************************************************************************    
 * CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SAVE_CORE */    
/**    
 * Creates new or edits existing
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
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
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @today              AS DATETIME       -- Current date/time stamp

    
--  DECLARE @tranOpen           AS BIT            -- Is a transaction open

declare @iepIfspNameId            as bigint
declare @noPlanNameId             as bigint
declare @cybhiNameId              as bigint 
declare @ruHealthNameID           as bigint

declare @serviceNameIdIsInIfspIep  as bit
declare @serviceNameIdIsInNoPlan   as bit
declare @serviceNameIdIsInCybhi    as bit
declare @serviceNameIdIsInRuHealth as bit

declare @hasFormData              as bit = 0
declare @checkClientID            as bit = 0
declare @checkForDups             as bit = 0
declare @isStandard               as bit = null
declare @hasClientID              as bit = null

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID  = 0    
SET @spDetails = ''    
SET @today     = GETDATE()    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
IF (@planTypeID    IS NULL) RAISERROR ('Plan type is required',   11, 1)    
IF (@groupID       IS NULL) RAISERROR ('Group is required',       11, 1)    
IF (@nameID        IS NULL) RAISERROR ('Name is required',        11, 1)    

/*============================================================
 * Defaults
 *============================================================*/  

set @spEdSvcCodeValue = isnull(@spEdSvcCodeValue,-1)
set @fillablePdfSelectionsJSON = trim(isnull(@fillablePdfSelectionsJSON,'[]'))
if (@fillablePdfSelectionsJSON = '') set @fillablePdfSelectionsJSON = '[]'

/*============================================================
 * A record is being cloned
 * Only custom clones of existing records are allowed
 * And each client is only allowed one custom clone per
 * @planTypeID, @groupID, @nameID pair
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin
  
  /* Fillable pdfs must be added per client after a clone */

  set @fillablePdfSelectionsJSON = '[]'

  /*-------------------------------
   * We need to check that a client
   * id was provided and there are
   * no duplicates so set the 
   * appropriate flags so we can
   * check later
   *------------------------------*/

  set @checkClientID  = 1
  set @checkForDups   = 1

   /*-------------------------------
    * We need additional data to save
    * the clone and we get this by
    * finding the standard version
    * of this data.
    *------------------------------*/

   select top 1 

      @iepIfspNameId             = t1.iepIfspNameId
    , @noPlanNameId              = t1.noPlanNameId
	, @cybhiNameId               = t1.cybhiNameId
	, @ruHealthNameID            = t1.ruHealthNameId
    , @serviceNameIdIsInIfspIep  = t1.serviceNameIdIsInIfspIep
    , @serviceNameIdIsInNoPlan   = t1.serviceNameIdIsInNoPlan
	, @serviceNameIdIsInCybhi    = t1.serviceNameIdIsInCybhi
	, @serviceNameIdIsInRuHealth = t1.serviceNameIdIsInRuHealth
    , @spEdSvcCodeValue          = t1.spEdSvcCodeValue   
  from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA as t1
  where (
          (t1.planTypeID  = @planTypeID)
      and (t1.groupID     = @groupID)
      and (t1.nameID      = @nameID)
	  and (t1.isStandard  = 1)
      and (t1.hasClientID = 0)
   )
   
end

/*============================================================
 * Existing standard or a cloned record is being edited
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  
   /*-------------------------------
    * Find the existing record
    *------------------------------*/

  select top 1 
      @isStandard  = t1.isStandard
	, @hasClientID = t1.hasClientID
    , @recordID    = t1.id
  from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA as t1 
  where (
        (t1.id = @recID)
    and (t1.active = 1)
  )
  
  /*-------------------------------
   * Not found?  Get out!
   *------------------------------*/

  if (isnull(@recordID,0) = 0)
  begin
    RAISERROR ('Record not found or no longer active', 11, 1)
  end

  /*-------------------------------
   * The record is a standard
   * record (not a clone)
   *------------------------------*/

  if ((@isStandard = 1) and (@hasClientID = 0))
  begin
     
	 /* If a client is being associated with this, get out!*/
     
	 if (@clientID is not null) RAISERROR ('You cannot associate a client with this record', 11, 1)
     
	 /* Otherwise the only time standard records are being edited is to change form data and there
	    SHOULD only be one standard record per @planTypeID, @groupID, @nameID pair.  So we do not need
		to check for client or dups */

	 set @checkClientID = 0
	 set @checkForDups  = 0
  
     /* Fillable pdfs are only for client specific records so we reset any passed value */

     set @fillablePdfSelectionsJSON = '[]'

  end
  
  /*-------------------------------
   * The record is a clone of
   * either a standard or another
   * clients clone.  
   *------------------------------*/

  else if ((@isStandard = 0) and (@hasClientID = 1))
  begin
    
	/* We do need to check for client id and for duplicates */

    set @checkClientID = 1
	set @checkForDups  = 1
  end
  else
  begin
    RAISERROR ('There is a problem with our existing data.  Please contact IT.', 11, 1)
  end

end

/*============================================================
 * See if the clientid is valid
 *============================================================*/  

if (@checkClientID = 1)
begin
  if not exists (
    select top 1 
      numOf = 1 
    from dbo.CLIENTS_Client   as cc   
    where cc.CLIENT_ID        = @clientID 
  )
  begin
    RAISERROR ('Invalid client', 11, 1)
  end
end

/*============================================================
 * Check for dups
 *============================================================*/ 

if (@checkForDups = 1)
begin
  if exists (
    select 
	  t1.id 
    from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA as t1
    where (
          (t1.clientID    = @clientID)
	  and (t1.planTypeID  = @planTypeID)
      and (t1.groupID     = @groupID)
      and (t1.nameID      = @nameID)
      and (t1.active      = 1)
	  and (t1.isStandard  = 0)
	  and (t1.hasClientID = 1)
      and ((@recID is null) or (t1.id != @recID))
   )
  )
  begin
    RAISERROR ('Form data already exists for this client', 11, 1)
  end
end

/*-------------------------------
 * Set flag if data is passed 
 * in formDataJson
 *------------------------------*/

if (len(trim((isnull(@formDataJSON,'')))) != 0) 
begin
  set @hasFormData = 1
end
else
begin
  set @hasFormData  = 0
  set @formDataJSON = null  /* Matches what we do in Claim_Procedures_Services_Create.sql */
end

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END        

-- BEGIN TRANSACTION
-- SET @TranOpen = 1
  
if (@saveType = dbo.CONST_SAVE_TYPE_NEW())

/*============================================================
 * Create new
 *===========================================================*/   

begin
  
  /*-------------------------------
   * Insert new record
   *------------------------------*/ 

  insert into dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA (  
	  planTypeID
    , groupID
    , nameID
    , iepIfspNameId
    , noPlanNameId
    , cybhiNameId
	, ruHealthNameId
	, serviceNameIdIsInIfspIep
    , serviceNameIdIsInNoPlan
    , serviceNameIdIsInCybhi
	, serviceNameIdIsInRuHealth
	, isStandard
	, hasFormData
    , hasClientID
    , formDataJSON
    , clientID
    , createdOn
    , createdBy
    , active
	, hasPatientGoalTracking
	, spEdSvcCodeValue
	, hasSessionRatingTracking
    , fillablePdfSelectionsJSON
  ) 
  values (
	  @planTypeID
	, @groupID
	, @nameID
	, @iepIfspNameId
	, @noPlanNameId
	, @cybhiNameId
	, @ruHealthNameID
	, @serviceNameIdIsInIfspIep
	, @serviceNameIdIsInNoPlan
	, @serviceNameIdIsInCybhi
	, @serviceNameIdIsInRuHealth
	, 0 /* We never save standard, only clones */
	, @hasFormData
	, 1 /* All clones will always be associated with a client */
	, @formDataJSON
	, @clientID
	, @today
	, @userID
	, 1 
	, @hasPatientGoalTracking
	, @spEdSvcCodeValue 
    , @hasSessionRatingTracking
	, @fillablePdfSelectionsJSON
  )
  
  set @recordID = SCOPE_IDENTITY()

end

/*============================================================
 * Edit existing
 *===========================================================*/   

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  update dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA
  set        
	  hasFormData               = @hasFormData
	, formDataJSON              = @formDataJSON
	, spEdSvcCodeValue          = @spEdSvcCodeValue
	, hasPatientGoalTracking    = @hasPatientGoalTracking
	, hasSessionRatingTracking  = @hasSessionRatingTracking
	, fillablePdfSelectionsJSON = @fillablePdfSelectionsJSON
    , lastModifiedOn            = @today
    , lastModifiedBy            = @userID


  where [id] = @recID
  
  set @recordID = @recID

end

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
  -- COMMIT TRANSACTION    
  -- SET @TranOpen = 0    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  -- IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

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

GRANT EXECUTE ON  [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SAVE_CORE] TO [webuser]
GO

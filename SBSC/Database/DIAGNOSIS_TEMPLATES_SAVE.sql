USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DIAGNOSIS_TEMPLATES_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DIAGNOSIS_TEMPLATES_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[DIAGNOSIS_TEMPLATES_SAVE] (
    @userID                   BIGINT
  , @userGroup                INT  
  , @userRank                 INT      
  , @clientID                 BIGINT
  , @diagnosisName		      VARCHAR(1000)
  , @diagnosisDescription     VARCHAR(MAX)
  , @groupServiceClassNameID  BIGINT
  , @templateType             BIGINT
  , @editDelReason            VARCHAR(7000)
  , @validateRec              BIT
  , @saveType                 INT
  , @recID                    BIGINT
  , @MsgNoRec                 VARCHAR(1000)
  , @MsgNoEdit                VARCHAR(1000)
  , @MsgDupRec                VARCHAR(1000)
  , @MsgDataError             VARCHAR(1000)
  , @MsgNotActive             VARCHAR(1000)
  , @spDetails                VARCHAR(8000) OUTPUT
  , @recordID                 BIGINT        OUTPUT )    
AS    
BEGIN     
    
/***************************************************************************    
 * DIAGNOSIS_TEMPLATES_SAVE */    
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

DECLARE @today                    AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen                 AS BIT            -- Is a transaction open
DECLARE @isPCALStaff			  AS BIT
DECLARE @userGroupSvcClassNameID  AS BIGINT
DECLARE @userClientID             AS BIGINT


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

/*============================================================
 * See if the clientid is valid
 *============================================================*/  
 if (isNull(@clientID, '') != '')
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
 * Get isPCALStaff and userGroupSvcClassNameID
 *============================================================*/  
 
select top 1  
    @isPCALStaff             = ua.pcalStaff
  , @userGroupSvcClassNameID = png2.GROUP_SERVICE_CLASS_NAME_ID
  , @userClientID            = ua.clientID
from users.dbo.USERS_ALL as ua
outer apply (
  select 
    png1.GROUP_SERVICE_CLASS_NAME_ID 
  , png1.GROUP_SERVICE_CLASS_NAME
  from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as png1
  where 
        (png1.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
 and (png1.GROUP_ID = ua.pracDispGroupID)
) as png2
where ( 
      (ua.appName = 'spedcare')
  and (ua.id = @userID)
)

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END        

BEGIN TRANSACTION
SET @TranOpen = 1
  
if (@saveType = dbo.CONST_SAVE_TYPE_NEW())

/*============================================================
 * Create new
 *===========================================================*/   

begin

  /*============================================================
   * Validation
   *============================================================*/  
  if (@templateType = 1) -- template for everyone
  begin
	-- if @userID is NOT a practical staff person then exit with exception
	if (@isPCALStaff = 0)
	begin
		RAISERROR('User is not Practi-Cal staff', 11, 1) 
	end
  end

  if (@templateType in (2, 3)) -- client templates and favorites
  begin 
    --if user is not a practi-cal staff person, make sure they have the correct groupServiceClassNameID
	if (@isPCALStaff = 0)
	begin
		-- if @userID is not associated with @clientID exit with error
		if (@userClientID != @clientID)
		begin
			RAISERROR('User is not associated with the requested client', 11, 1) 
		end

		-- if @userID is not in @groupServiceClassNameID then exit with error
		--if (@userGroupSvcClassNameID != @groupServiceClassNameID)
		--begin
		--	RAISERROR('User does not have the correct group service class name id', 11, 1) 
		--end
	end
  end
  

  /*-------------------------------
   * Create diagnosis
   * record.
   *------------------------------*/ 

  insert into dbo.DiagnosisTemplates (  
	  [typeOfTemplateID]       
	, [clientID]               
	, [groupServiceClassNameID]
	, [ownerUserID]            
	, [name]                   
	, [description]            
	, [createdBy]              
	, [createdOn]              
	, [lastModifiedBy]         
	, [lastModifiedOn]         
	, [active]                 
  ) 
  values (                   
	  @templateType       
	, @clientID               
	, @groupServiceClassNameID
	, @userID            
	, @diagnosisName		             
	, @diagnosisDescription            
	, @userID              
	, @today              
	, null         
   	, null         
  	, 1 
	)                
  
  set @recordID = SCOPE_IDENTITY()

end

/*============================================================
 * Edit existing
 *===========================================================*/   

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  /*============================================================
   * Validation
   *============================================================*/  
  if (@templateType = 1) -- template for everyone
  begin
	-- if @userID is NOT a practical staff person then exit with exception
	if (@isPCALStaff = 0)
	begin
		RAISERROR('User is not Practi-Cal staff', 11, 1) 
	end
  end

  if (@templateType = 2) -- client templates
  begin 
    --if user is not a practi-cal staff person, make sure they have the correct groupServiceClassNameID
	if (@isPCALStaff = 0)
	begin

		-- if @userID is not associated with @clientID exit with error
		if (@userClientID != @clientID)
		begin
			RAISERROR('User is not associated with the requested client', 11, 1) 
		end

	end
  end

  if (@templateType = 3) -- user favorites
  begin 
    --if user is not a practi-cal staff person, make sure they have the correct groupServiceClassNameID
	if (@isPCALStaff = 0)
	begin

		-- if @userID is not associated with @clientID exit with error
		if (@userClientID != @clientID)
		begin
			RAISERROR('User is not associated with the requested client', 11, 1) 
		end

		
		-- if @userID is not in @groupServiceClassNameID then exit with error
		--if (@userGroupSvcClassNameID != @groupServiceClassNameID)
		--begin
		--	RAISERROR('User does not have the correct group service class name id', 11, 1) 
		--end

		-- if @userID is not ownerUserID then exit with error
		if (@userID != (select ownerUserID from dbo.DiagnosisTemplates))
		begin
			RAISERROR('User does not have access to this template', 11, 1) 
		end

	end
  end

  update dbo.DiagnosisTemplates
  set        
	  name               = @diagnosisName		
    , description        = @diagnosisDescription
    , lastModifiedOn     = @today
    , lastModifiedBy     = @userID
  where (((clientID is null) or (clientID   = @clientID)) and (id = @recID))
  
  set @recordID = @recID

end

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
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
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
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

GRANT EXECUTE ON  [dbo].[DIAGNOSIS_TEMPLATES_SAVE] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISIT_REASONS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISIT_REASONS_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTICE_OFFICE_VISIT_REASONS_SAVE] (
    @userID                 			BIGINT
  , @userGroup              			INT  
  , @userRank               			INT      
  , @name                   			VARCHAR(256)
  , @groupSvcClassNameID    			BIGINT
  , @formDataJSON           			VARCHAR(MAX)
  , @practiceOfficeVisitResolutionID    BIGINT
  , @hideVisitSection           				BIT
  , @editDelReason          			VARCHAR(7000)
  , @validateRec            			BIT
  , @saveType               			INT
  , @recID                  			BIGINT
  , @MsgNoRec               			VARCHAR(1000)
  , @MsgNoEdit              			VARCHAR(1000)
  , @MsgDupRec              			VARCHAR(1000)
  , @MsgDataError           			VARCHAR(1000)
  , @MsgNotActive           			VARCHAR(1000)
  , @spDetails              			VARCHAR(8000) OUTPUT
  , @recordID               			BIGINT        OUTPUT )    
AS    
BEGIN     
    
/***************************************************************************    
 * PRACTICE_OFFICE_VISIT_REASONS_SAVE */    
/**    
 * Creates new or edits existing
 *    
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @today              AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen           AS BIT            -- Is a transaction open
declare @hasFormData        as bit = 0

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID  = 0    
SET @spDetails = ''    
SET @today     = GETDATE()    
set @tranOpen  = 0

/*============================================================
 * Defaults
 *============================================================*/

set @formDataJSON = trim(isnull(@formDataJSON,''))

BEGIN TRY

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
IF (@hideVisitSection = 1 and @practiceOfficeVisitResolutionID = -1)
	RAISERROR ('Practice Office Visit Resolution is not valid.',   11, 1)    
/*============================================================
 * If this is an edit
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  
   /*-------------------------------
    * Find the existing record
    *------------------------------*/

  select top 1 
    @recordID    = t1.id
  from dbo.PRACTICE_OFFICE_VISIT_REASONS as t1 
  where (
        (t1.id = @recID)
    and (t1.active = 1)
  )
  
  /*-------------------------------
   * Not found?  Get out!
   *------------------------------*/

  if (isnull(@recordID,0) = 0)
  begin
    RAISERROR (@MsgNoRec, 11, 1)
  end

end

/*============================================================
 * Check for duplicates
 *============================================================*/  

if exists (
    select top 1 
	  t1.id 
    from dbo.PRACTICE_OFFICE_VISIT_REASONS as t1
    where (
         (t1.name                 = @name)
      and (t1.groupSvcClassNameID = @groupSvcClassNameID)
      and ((@recID is null) or (t1.id != @recID))
    )
)
begin
  RAISERROR (@MsgDupRec, 11, 1)
end

/*============================================================
 * Determine flag values
 *============================================================*/  

set @hasFormData = 1
if (len(@formDataJSON) = 0) set @hasFormData = 0

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
  
/*============================================================
 * New 
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin 
	insert into dbo.PRACTICE_OFFICE_VISIT_REASONS ( 
			[name]          
		  , [groupSvcClassNameID]
		  , hasFormData 
		  , formDataJSON
		  , practiceOfficeVisitResolutionID
		  , hideVisitSection
		  , [created]
		  , [createdBy]
		  , [active] 
	  )
	  values (
		  @name
		, @groupSvcClassNameID
		, @hasFormData
		, @formDataJSON
		, @practiceOfficeVisitResolutionID
		, @hideVisitSection
		, @today
		, @userID
		, 1
	  )
	  
	  set @recordID = SCOPE_IDENTITY()
end
/*============================================================
 * Edit 
 *===========================================================*/   

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  update dbo.PRACTICE_OFFICE_VISIT_REASONS
  set        
	  [name]                 			= @name
	, hasFormData            			= @hasFormData
	, formDataJSON           			= @formDataJSON
	, practiceOfficeVisitResolutionID 	= @practiceOfficeVisitResolutionID
	, hideVisitSection					= @hideVisitSection
    , lastModified             			= @today
    , lastModifiedBy           			= @userID

  where ([id] = @recID)
  
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

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_VISIT_REASONS_SAVE] TO [webuser]
GO

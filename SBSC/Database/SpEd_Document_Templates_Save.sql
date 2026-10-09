USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SpEd_Document_Templates_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SpEd_Document_Templates_Save
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SpEd_Document_Templates_Save] (
    @userID                 BIGINT
  , @userGroup              INT  
  , @userRank               INT    
  , @clientID               BIGINT  
  , @name                   varchar(256)
  , @description            varchar(512)
  , @formBuilderContentJSON varchar(max)
  , @display                bit
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
 * SpEd_Document_Templates_Save */    
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

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
IF (@name          IS NULL) RAISERROR ('Name is required',        11, 1)


/*============================================================
 * Duplicate check
 *============================================================*/  


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

    
  insert into dbo.SpEd_Document_Templates (
      [clientID] 
	, [name] 
	, [description]  
	, [formBuilderContentJSON]
    , [display]
	, [spEdPlanTypeCode]   
    , [created]   
    , [createdBy] 
    , [active]
  )
  values (
      @clientID
    , @name
    , @description
    , @formBuilderContentJSON
    , @display
	, 100
    , @today
    , @userID
    , 1
  )
    
  set @recordID = SCOPE_IDENTITY()

  
end

/*============================================================
 * Edit existing
 *===========================================================*/   

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  update dbo.SpEd_Document_Templates 
  set   
	  [name]                   = @name 
	, [description]            = @description 
	, [formBuilderContentJSON] = @formBuilderContentJSON
    , [display]                = @display
    , [lastModified]           = @today
    , [lastModifiedBy]         = @userID
  
  where (id = @recID)
  
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

GRANT EXECUTE ON  [dbo].[SpEd_Document_Templates_Save] TO [webuser]
GO

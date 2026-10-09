USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTICE_OFFICE_VISIT_RESOLUTIONS_SAVE] (
    @userID                 BIGINT
  , @userGroup              INT  
  , @userRank               INT      
  , @name                   VARCHAR(256)
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
 * PRACTICE_OFFICE_VISIT_RESOLUTIONS_SAVE */    
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

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID  = 0    
SET @spDetails = ''    
SET @today     = GETDATE()    
SET @tranOpen  = 0

/*============================================================
 * Defaults
 *============================================================*/

BEGIN TRY

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
if (@name          is null) RAISERROR ('Name is required',        11, 1)    

/*============================================================
 * Clean up name
 *============================================================*/  

set @name = trim(@name)
if (len(@name) = 0) RAISERROR ('Name is required', 11, 1)    

/*============================================================
 * If this is an edit
 *============================================================*/  

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN
  
 /*-------------------------------
  * Find the existing record
  *------------------------------*/
    
  select top 1 
    @recordID = povr.ID
  from dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS as povr
  where ( 
        (povr.id = @recID)
    and (povr.active = 1)
  )

  if (isnull(@recordID,0) = 0)
  begin
    set @recordID = 0
    RAISERROR (@MsgNoRec, 11, 1)
  end

end

/*============================================================
 * Check for duplicates
 *============================================================*/  

if exists (
    select top 1 
	  povr.id 
    FROM dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS as povr
    WHERE (
         (povr.[name] = @name)
      and ((@recID is null) or (povr.id != @recID))
	  and (povr.active = 1)
    )
)
begin
  RAISERROR (@MsgDupRec, 11, 1)
end


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

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
BEGIN
  
  INSERT INTO dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS ( 
	    [name]          
	  , [created]
	  , [createdBy]
	  , [active] 
  )
  VALUES (
	  @name
	, @today
	, @userID
	, 1
  )
  
  SET @recordID = SCOPE_IDENTITY()

END

/*============================================================
 * Edit 
 *===========================================================*/   

ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  UPDATE dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS
  SET        
	  [name]                 = @name
    , [lastModified]         = @today
    , [lastModifiedBy]       = @userID
  WHERE ([id] = @recordID)
    
END

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

  IF (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[PRACTICE_OFFICE_VISIT_RESOLUTIONS_SAVE] TO [webuser]
GO

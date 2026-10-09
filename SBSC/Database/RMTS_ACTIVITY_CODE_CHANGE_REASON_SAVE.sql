USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_ACTIVITY_CODE_CHANGE_REASON_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_ACTIVITY_CODE_CHANGE_REASON_SAVE
GO
 
CREATE PROCEDURE dbo.RMTS_ACTIVITY_CODE_CHANGE_REASON_SAVE (
    @userID              BIGINT
  , @userGroup           INT
  , @userRank            INT
  , @rmtsCodeValue		 VARCHAR(10)
  , @name				 VARCHAR(512)
  , @description		 VARCHAR(MAX)
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT    
  , @recID               BIGINT
  , @MsgNoRec            VARCHAR(1000)   
  , @MsgDupRec           VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)
  , @MsgDataError        VARCHAR(1000)
  , @saveType            smallint
  , @spDetails           VARCHAR(8000) OUTPUT    
  , @recordID            BIGINT        OUTPUT)   
AS    
BEGIN    
     
SET NOCOUNT ON    
   
DECLARE @today      AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen   AS BIT            -- Is a transaction open
 
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID   = 0    
SET @spDetails  = '' 

/*-------------------------------    
 * Init working variables    
 *------------------------------*/    

SET @today = GETDATE()   
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
IF (@userGroup     IS NULL)  RAISERROR ('userGroup is required',   11, 1)
IF (@userID        IS NULL)  RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL)  RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL)  RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL)  RAISERROR ('Save type is required',   11, 1)    
IF (@rmtsCodeValue IS NULL)  RAISERROR ('RMTS code required' ,     11, 1)
IF (@name          IS NULL)  RAISERROR ('Name is required' ,       11, 1)
    
/*============================================================
 * If we are editing the record, make sure it exists 
 *============================================================*/  
  
if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  IF (@recID IS NULL) RAISERROR ('Record id is required', 11, 1)    
  
  select top 1 
    @recordID = cr.id
  from dbo.RMTS_ACTIVITY_CODE_CHANGE_REASONS as cr
  where (
        (1=1)
    and (cr.id = @recID)
	and (cr.active = 1)             
  )
  
  IF (@recordID != @recID)
  begin
    RAISERROR (@MsgNoRec, 11, 1)
  end

end

/*============================================================
 * Check for duplicate records in all active records
 *============================================================*/  

if exists (
  select top 1 
    cr.id
  from dbo.RMTS_ACTIVITY_CODE_CHANGE_REASONS as cr
  where (
        (1=1)
    and ((@recID IS NULL) or (cr.id != @recID))
	and (cr.rmtsCodeValue = @rmtsCodeValue)
	and (cr.[name] = @name)             
	and (cr.active = 1)

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
   
  /*-------------------------------    
   * New record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN        
    
    INSERT INTO [dbo].[RMTS_ACTIVITY_CODE_CHANGE_REASONS]
    (    
		 [name]   
	   , [description]
	   , rmtsCodeValue             
	   , ACTIVE
	   , created     
	   , createdBy
	)    
    VALUES    
    (    @name  
	   , @description
	   , @rmtsCodeValue
	   , 1
	   , @today
	   , @userID
    )      
    
    SET @recordID = SCOPE_IDENTITY()    
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/                      
       
     UPDATE [dbo].[RMTS_ACTIVITY_CODE_CHANGE_REASONS] 
     SET  
	      [name]         = @name
	    , [description]  = @description                               
        , rmtsCodeValue  = @rmtsCodeValue    
		, lastModified   = @today
        , lastModifiedBy = @userID
     WHERE (id = @recID)
 
     SET @recordID = @recid
    
  END    
  ELSE    
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
      
       
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
     
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ''    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.RMTS_ACTIVITY_CODE_CHANGE_REASON_SAVE TO webuser
GO
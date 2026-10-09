USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.KNOWN_HEALTH_PROBLEMS_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.KNOWN_HEALTH_PROBLEMS_SAVE
GO
 

CREATE PROCEDURE dbo.KNOWN_HEALTH_PROBLEMS_SAVE (
    @userID                 BIGINT
  , @userGroup              INT
  , @userRank               INT
  , @name                   varchar(512)

  , @belongsToHealthServices  bit
  , @belongsToMentalHealth    bit

  , @editDelReason          VARCHAR(7000)
  , @validateRec            BIT   
  , @recID                  BIGINT
  , @MsgNoRec               VARCHAR(1000)  
  , @MsgDupRec              VARCHAR(1000)
  , @MsgNoEdit              VARCHAR(1000)
  , @MsgNotActive           VARCHAR(1000)
  , @MsgDataError           VARCHAR(1000)
  , @saveType               smallint
  , @spDetails              VARCHAR(8000) OUTPUT   
  , @recordID               BIGINT        OUTPUT)  
AS   
BEGIN   
    
SET NOCOUNT ON   
  
DECLARE @today       AS DATETIME       -- Current date/time stamp   
DECLARE @tranOpen    AS BIT            -- Is a transaction open
 
/*============================================================
 * Init
 *============================================================*/ 
 
/*-------------------------------   
 * Init our output parameters   
 *------------------------------*/   
  
SET @recordID   = 0   
SET @spDetails  = ''
SET @today    = GETDATE()  
SET @tranOpen = 0  
 
/*-------------------------------   
 * Init working variables   
 *------------------------------*/   
 
BEGIN TRY   
 
/*============================================================
 * Required validation
 *============================================================*/ 
 
/*-------------------------------   
 * Verify all parameters that   
 * indicate what type of operation   
 * to perform have been passed in   
 * and any other parms that are   
 * neccessary for proper operation   
 *------------------------------*/   
  
IF (@userGroup           IS NULL) RAISERROR ('userGroup is required',     11, 1)
IF (@userID         IS NULL) RAISERROR ('user id is required',       11, 1)   
IF (@userRank        IS NULL) RAISERROR ('userRank is required',      11, 1)   
IF (@validateRec     IS NULL) RAISERROR ('Validate flag required',    11, 1)   
IF (@saveType        IS NULL) RAISERROR ('Save type is required',        11, 1)   
 
  
/*============================================================
 * If we are editing the record, make sure it exists
 * and that the calling user can access it.
 *============================================================*/ 

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN
 
  IF (@recID IS NULL) RAISERROR (@MsgNoRec, 11, 1)   
 
  select top 1
    @recordID = khp.id
  from dbo.KNOWN_HEALTH_PROBLEMS as khp
  where (
         (khp.id                  = @recID)
     and (khp.active              = 1)
  )
 
  if (@recordID != @recID)
  begin
    RAISERROR (@MsgNoRec, 11, 1)
  end
 
end
 
/*============================================================
 * Check for duplicate records in all active records
 *============================================================*/ 
 
if exists (
  select top 1
    khp.id
  from dbo.KNOWN_HEALTH_PROBLEMS as khp
  where (
        (1=1)
    and (khp.[name]              = @name) 
    and (khp.active              = 1)
    and ((@recID IS NULL) or (khp.id != @recID))  /* In the case of edits we skip the record being edited */              
  )
)
begin
  RAISERROR (@MsgDupRec, 11, 1)
end
 

/*============================================================
 * Exit if in validation mode
 *============================================================*/ 
 
IF (@validateRec = 1)
BEGIN 
  SET @recordID = 0
  RETURN(0)   
END                         
 

/*============================================================
 * Save Data
 *============================================================*/ 
 
   
BEGIN TRANSACTION
 

  SET @TranOpen = 1   
  
  /*-------------------------------   
   * New
   *------------------------------*/   
  
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())   
  BEGIN       
 
    insert into dbo.KNOWN_HEALTH_PROBLEMS (
        [name]

      , [belongsToHealthServices] 
      , [belongsToMentalHealth] 

      , [created]
      , [createdBy]
      , [active]
    )
    values (    
      @name

    , @belongsToHealthServices
    , @belongsToMentalHealth

    , @today
    , @userID
    , 1 )

     SET @recordID = SCOPE_IDENTITY()   
  END        
 
  /*-------------------------------   
   * Edit
   *------------------------------*/   
 
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())   
  BEGIN   
 
    update dbo.KNOWN_HEALTH_PROBLEMS
    set
     [name]            = @name
   , [lastModified]    = @today
   , [lastModifiedBy]  = @userID

   , [belongsToHealthServices]  =  @belongsToHealthServices
   , [belongsToMentalHealth]    =  @belongsToMentalHealth
   
    where (id = @recID)
 
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
    
  --SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ''   
    
  -- Reraise the error so it returns back to the server   
    
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)   
  
END CATCH   
END     
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.KNOWN_HEALTH_PROBLEMS_SAVE TO webuser
GO 
 
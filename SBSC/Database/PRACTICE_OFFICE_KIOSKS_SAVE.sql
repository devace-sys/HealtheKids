USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_KIOSKS_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_KIOSKS_SAVE
GO
 
CREATE PROCEDURE dbo.PRACTICE_OFFICE_KIOSKS_SAVE (
    @userID                 BIGINT
  , @userGroup              INT
  , @userRank               INT
  , @clientID               bigint
  , @groupSvcClassNameID    bigint
  , @siteID                 bigint
  , @name                   varchar(256)
  , @startTime              time(0)
  , @endTime                time(0)
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
declare @publicToken as varchar(512)   -- Used for accessing public kiosk
 
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
IF (@clientID            IS NULL) RAISERROR ('Client ID is required',        11, 1) 
IF (@groupSvcClassNameID IS NULL) RAISERROR ('Practice family is required',  11, 1) 
IF (@siteID              IS NULL) RAISERROR ('Site ID is required',          11, 1) 
 
  
set @startTime = convert(time(0),'00:00:00')
set @endTime   = convert(time(0),'23:59:59')

/*============================================================
 * If we are editing the record, make sure it exists
 * and that the calling user can access it.
 *============================================================*/ 

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN
 
  IF (@recID IS NULL) RAISERROR (@MsgNoRec, 11, 1)   
 
  select top 1
    @recordID = pok.id
  from dbo.PRACTICE_OFFICE_KIOSKS as pok
  where (
         (pok.id                  = @recID)
     and ((pok.clientID           = @clientID)            /* Per client access check */
     and (pok.groupSvcClassNameID = @groupSvcClassNameID) /* Practice family check */ 
     and (pok.id                  = @recID)
     and (pok.active              = 1))
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
    pok.id
  from PRACTICE_OFFICE_KIOSKS as pok
  where (
        (1=1)
    and (pok.clientID            = @clientID)            /* Per client access check */
    and (pok.groupSvcClassNameID = @groupSvcClassNameID) /* Practice family check */ 
    and (pok.siteID              = @siteID)
    and (pok.name                = @name) 
    and (pok.active              = 1)
    and ((@recID IS NULL) or (pok.id != @recID))  /* In the case of edits we skip the record being edited */              
  )
)
begin
  RAISERROR (@MsgDupRec, 11, 1)
end
 

/*============================================================
 * Generate new public token for new records
 *============================================================*/ 
 
if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin
 
  set @publicToken = ''
 
  /* Adds random length alpha numeric component 0 to 255 chars */
 
  set @publicToken = @publicToken + dbo.GENERATE_RANDOM_ALPHA_NUMERIC_STRING(CAST(CRYPT_GEN_RANDOM(1) AS tinyint),0)
 
  /* Adds unique component to token to reduce possibility of hash collision (32 chars) */
 
  select top 1
    @publicToken = @publicToken + gnui.NEW_UNIQUE_ID_STR_NO_DASH
  from GENERATE_NEW_UNIQUE_ID as gnui
 
  /* Adds fixed length alpha numeric component 32 chars */
 
  set @publicToken = @publicToken + dbo.GENERATE_RANDOM_ALPHA_NUMERIC_STRING(32,0)
 
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
 
    insert into dbo.PRACTICE_OFFICE_KIOSKS (
     [clientID] 
   , [groupSvcClassNameID]
   , [siteID]
   , [name] 
   , [startTime]  
   , [endTime]    
   , [publicToken]
      , [created]
   , [createdBy]
   , [active]
    )
    values (
      @clientID
    , @groupSvcClassNameID
    , @siteID
    , @name
    , @startTime
    , @endTime
    , @publicToken
    , @today
    , @userID
    , 1 )

     SET @recordID = SCOPE_IDENTITY()   
  END        
 
  /*-------------------------------   
   * Edit
   * Note: public token changes will
   * be handled through dedicated
   * recOp sproc
   *------------------------------*/   
 
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())   
  BEGIN   
 
    update dbo.PRACTICE_OFFICE_KIOSKS
    set
     [name]           = @name
   , [startTime]      = @startTime
   , [endTime]        = @endTime
   , [lastModified]    = @today
   , [lastModifiedBy] = @userID
   
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
 
GRANT EXECUTE ON  dbo.PRACTICE_OFFICE_KIOSKS_SAVE TO webuser
GO 
 
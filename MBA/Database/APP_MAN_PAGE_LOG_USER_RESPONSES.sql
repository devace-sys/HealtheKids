USE [users]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGE_LOG_USER_RESPONSES') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.APP_MAN_PAGE_LOG_USER_RESPONSES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[APP_MAN_PAGE_LOG_USER_RESPONSES]
 (@userID                BIGINT,    
  @userGroup             INT,    
  @userRank              INT, 
  @appName               varchar(50),    /* Application name (from web.config)*/
  @responseTypeID        int,
  @recIDMulti            varchar(8000),
  @spDetails             VARCHAR(8000) OUTPUT,    
  @recordID              BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * APP_ANNOUNCEMENT_LOG_USER_RESPONSES */    
/**    
 * @returns spDetails       Validation or error details    
 * @returns saveType        1 = New record created, 2 = Existing record edited
 * @returns recordID        New record id or record id of user record that    
 *                          was modified  
 ***************************************************************************/        
     
SET NOCOUNT ON    

DECLARE @tranOpen         AS BIT              -- Is a transaction open    
DECLARE @numRecIDs       as INT
DECLARE @numDupRecIDs    as INT
DECLARE @currentID       AS INT
DECLARE @recIDVal        AS BIGINT
DECLARE @recIDVals       as TABLE([id] int, [recid] bigint) 

/*============================================================
 * Init
 *============================================================*/  

SET @spDetails  = ''    
set @recordID   = 0

/*============================================================
 * Parse multirec value into individual record ids
 *============================================================*/  
 
INSERT INTO @recIDVals
  select [id],[recid] from dbo.MULTI_RECORD_ID_PARSE(@recIDMulti,',')
  
/*============================================================
 * Get number of record ids.  Exit if none.
 *============================================================*/  

SET    @numRecIDs = 0
SELECT @numRecIDs = COUNT(id) FROM @recIDVals

IF (@numRecIDs = 0)
BEGIN
  RETURN(0) 
END


/*============================================================
 * Check for duplicate record ids.  Exit with error if there are
 * dups.
 *============================================================*/  

SET    @numDupRecIDs = 0
SELECT @numDupRecIDs = COUNT([id]) FROM @recIDVals GROUP BY [recid] HAVING COUNT([id]) > 1

IF (@numDupRecIDs > 0) 
  RAISERROR ('Duplicate record ids are not allowed', 11, 1) 
  
  
BEGIN TRY    

BEGIN TRANSACTION    
SET @TranOpen = 1    

/*============================================================
 * Update all records
 *============================================================*/  

set @currentID = 1
set @recIDVal  = 0

while (@currentID <= @numRecIDs)                        
begin

  select top 1
    @currentID  = id, 
    @recIDVal   = recid          
  from @recIDVals 
  where 
    (id = @currentID)
  
  exec dbo.APP_MAN_PAGE_LOG_USER_RESPONSE_CORE   @userID   
                                               , @userGroup
                                               , @userRank
                                               , @appName
                                               , @responseTypeID
                                               , @recIDVal    
                                               , @spDetails   OUTPUT    
                                               , @recordID    OUTPUT

  set @currentID = @currentID + 1

end -- While

/*-------------------------------    
 * Return the number of records
 * updated as the recordID
 *------------------------------*/  

SET @recordID = @numRecIDs

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
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[APP_MAN_PAGE_LOG_USER_RESPONSES] TO [webuser]
GO


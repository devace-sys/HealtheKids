USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TELECOMM_SESSION_DELETE] (
    @userID        BIGINT    
  , @userGroup     BIGINT    
  , @userRank      INT
  , @appName       varchar(50)    /* Application name (from web.config)*/
  , @clientID      BIGINT
  , @editDelReason VARCHAR(7000)    
  , @validateRec   BIT    
  , @recID         BIGINT
  , @MsgNoRec      VARCHAR(1000)     
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT    
  , @recordID      BIGINT        OUTPUT
)    
AS    
BEGIN     
    
/***************************************************************************    
 * TELECOMM_SESSION_DELETE */    
/**    
 * Deletes session (if it can be deleted)    
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @TranOpen     AS BIT    
DECLARE @today        AS DATETIME       -- Current date/time stamp    
DECLARE @canEdit      AS BIT    
DECLARE @saveType     AS INT    
    
BEGIN TRY    
    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    
    
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
    
IF (@userID      IS NULL) RAISERROR ('User ID is required',  11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required', 11, 1)    
IF (@recID       IS NULL) RAISERROR ('Record id is required',  11, 1)    
    
/*-------------------------------    
 * See if the record exists and
 * and can be deleted 
 *------------------------------*/    
     
SET @recordID = null    
SET @canEdit  = 0    
      
select top 1
    @recordID  = id
  , @canEdit   = dbo.TELECOMM_SESSION_CAN_EDIT (ts.active,ts.startDate, ts.endDate) 
from dbo.TELECOMM_SESSIONS as ts
where (
      (ts.id       = @recID)
  and ((@clientID is null) or (ts.clientID = @clientID)) /* Prevents cross client deletes */
  and (ts.active   = 1)
)

/*-------------------------------    
 * If there is nothing to update
 * get out
 *------------------------------*/    

IF (@recordID IS NULL)
begin
  return(0)
end

if (@canEdit = 0)
begin
  return(0)
end

/*-------------------------------    
 * If we are just validating     
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    

  
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
    
  /*-------------------------------    
   * Update our session record
   * with the required data
   *------------------------------*/  

  update dbo.TELECOMM_SESSIONS
  set 
       cancelled     = 1
	 , attended      = 0
	 , completed     = 0
	 , expired       = 0
	 , active        = 0
     , lastModfied   = @today 
     , lastModifedBy = @userID    
  where (id = @recordID)    
    
  
           
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
    
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
    
  -- Reraise the error so it returns back to the server    
    
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_DELETE] TO [webuser]
GO

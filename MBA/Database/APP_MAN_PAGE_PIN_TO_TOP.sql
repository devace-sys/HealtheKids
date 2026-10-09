USE [users]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGE_PIN_TO_TOP') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.APP_MAN_PAGE_PIN_TO_TOP
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[APP_MAN_PAGE_PIN_TO_TOP]
 (@userID                BIGINT,    
  @userGroup             INT,    
  @userRank              INT, 
  
  @appName               varchar(50),    /* Application name (from web.config)*/
  @editDelReason         VARCHAR(7000),    
  @validateRec           BIT,    
  @recID                   BIGINT,    
  
  @MsgNoRec                VARCHAR(1000),    
  @MsgNoEdit               VARCHAR(1000), 
  @spDetails               VARCHAR(8000) OUTPUT,    
  @recordID                BIGINT        OUTPUT)  
AS    
BEGIN    
   
  

SET NOCOUNT ON    
   
DECLARE @today            AS DATETIME         -- Current date/time stamp    
DECLARE @tranOpen         AS BIT              -- Is a transaction open    
DECLARE @tempRecID        AS BIGINT
DECLARE @tempMsg          AS VARCHAR(1000)

BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters   
 *------------------------------*/    

SET @spDetails  = ''    
set @recordID   = 0

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today = GETDATE()    

/*-------------------------------    
 * Save a new record or replace
 * an existing record
 *------------------------------*/    
   
BEGIN TRANSACTION    
SET @TranOpen = 1    

-- Find rec

set @recordID = null

select top 1 
  @recordID = id
from dbo.AppManPages
where (
      (appName = @appName) 
  and (id = @recID)
)

if (@recordID is not null)
begin


  -- all other rows get pushed down, 1

  update dbo.AppManPages 
    set 
      display_order =  display_order + 1
    where (id != @recordID)


  update dbo.AppManPages 
    set 
      display_order = 1
    where (id = @recordID)


end


-- Update it
                                
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

GRANT EXECUTE ON  [dbo].[APP_MAN_PAGE_PIN_TO_TOP] TO [webuser]
GO
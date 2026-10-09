USE [spedmon]
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PREFERENCE_SPED_SERVICE_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PREFERENCE_SPED_SERVICE_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTITIONER_PREFERENCE_SPED_SERVICE_DELETE]
 (
  @userID                BIGINT,    
  @userGroup             INT,    
  @userRank              INT, 
  
  @clientID              bigint,
  @pracID                bigint,

  @recID                   BIGINT,


  @validateRec             BIT,
  @editDelReason           VARCHAR(4000),
                           -- not used

  
  @MsgNoRec                VARCHAR(1000),    
  @MsgNoEdit               VARCHAR(1000), 
  @spDetails               VARCHAR(8000) OUTPUT,    
  @recordID                BIGINT        OUTPUT
)


AS    
BEGIN    
  

SET NOCOUNT ON    
   
DECLARE @today            AS DATETIME         -- Current date/time stamp    
DECLARE @tranOpen         AS BIT              -- Is a transaction open

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
@recordID = isnull(ppss.id,0)
from dbo.PRACTITIONER_PREFERENCE_SPED_SERVICES as ppss

where (
(ppss.id = @recID)
and(ppss.pracID = @pracID)
and (ppss.clientID = @clientID)
and (ppss.active = 1)
)

if (@recordID != 0)
begin
update dbo.PRACTITIONER_PREFERENCE_SPED_SERVICES
set
active = 0
, lastModified = @today
, lastModifiedBy = @userID
where
(id = @recordID)
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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PREFERENCE_SPED_SERVICE_DELETE] TO [webuser]
GO
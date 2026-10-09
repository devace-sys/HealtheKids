USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_SAVE_FORM_WIP_DATA') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_SAVE_FORM_WIP_DATA
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_SAVE_FORM_WIP_DATA] (
    @userID                           BIGINT    
  , @userGroup                        INT    
  , @userRank                         INT 
  , @userIP                           varchar(500)
  , @userAgent                        varchar(8000)
  , @roomID                           varchar(256)
  , @email                            varchar(256)
  , @pin                              varchar(50)  
  , @formID                           varchar(256)
  , @formData                         varchar(max)
  , @editDelReason                    VARCHAR(7000)    
  , @validateRec               BIT    
  , @saveType                  INT    
  , @recID                     BIGINT    
  , @MsgNoRec                  VARCHAR(1000)    
  , @MsgNoEdit                 VARCHAR(1000) 
  , @MsgDupRec                 VARCHAR(1000)     
  , @MsgDataError              VARCHAR(1000)
  , @MsgNotActive              VARCHAR(1000)     
  , @recordID                  BIGINT        OUTPUT  
  , @spDetails                 VARCHAR(8000) OUTPUT)    

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_SESSION_SAVE_FORM_WIP_DATA */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   

/*============================================================
 * Init
 *============================================================*/  

declare @tranOpen      as  bit     = 0

/*============================================================
 * Call core method in a transation
 *============================================================*/  

BEGIN TRY    

BEGIN TRANSACTION
set @tranOpen = 1

exec dbo.TELECOMM_SESSION_SAVE_FORM_DATA_CORE
    @userID  
  , @userGroup
  , @userRank 
  , @userIP
  , @userAgent
  , @roomID   
  , @email  
  , @pin  
  , @formID 
  , @formData 
  , 0 /* Data finalized */
  , @editDelReason
  , @validateRec 
  , @saveType
  , @recID   
  , @MsgNoRec 
  , @MsgNoEdit
  , @MsgDupRec 
  , @MsgDataError 
  , @MsgNotActive 
  , @recordID OUTPUT  
  , @spDetails OUTPUT

set @tranOpen = 0

COMMIT TRANSACTION

RETURN(0)    

END TRY    
BEGIN CATCH    
   
if (@tranOpen  = 1) ROLLBACK TRANSACTION

  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
         
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

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_SAVE_FORM_WIP_DATA] TO [webuser]
GO

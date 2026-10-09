USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE](
    @userID                BIGINT    
  , @userGroup             INT  
  , @userRank              INT 
  , @clientID              BIGINT
  , @requestID             BIGINT
  , @responseCode          BIGINT
  , @effectiveDate         DATE
  , @svcAuthRequestMsgUrlBase   varchar(512)
  , @svcAuthRequestPaperUploadUrlBase  varchar(512)
  , @pwdMinLen                 INT
  , @editDelReason         VARCHAR(7000)
  , @validateRec           BIT
  , @saveType              INT
  , @recID                 BIGINT
  , @MsgNoRec              VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
  , @MsgDupRec             VARCHAR(1000)
  , @MsgDataError          VARCHAR(1000)
  , @MsgNotActive          VARCHAR(1000)
  , @recordID              BIGINT        OUTPUT
  , @jsonData              varchar(max)  OUTPUT
  , @spDetails             VARCHAR(8000) OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE */    
/**    
 * @returns spDetails       Validation or error details    
 * @returns saveType        1 = New record created, 2 = Existing record edited
 * @returns recordID        New record id or record id of user record that    
 *                          was modified  
 ***************************************************************************/        

/*============================================================
 * Variables
 *============================================================*/  

declare @tranOpen                       as bit            -- Is a transaction open  

BEGIN TRY

BEGIN TRANSACTION

SET @TranOpen = 1

exec dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE_CORE 
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @requestID
  , @responseCode
  , @effectiveDate
  , @svcAuthRequestMsgUrlBase
  , @svcAuthRequestPaperUploadUrlBase
  , @pwdMinLen
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
  , @jsonData OUTPUT
  , @spDetails OUTPUT


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

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE] TO [webuser]
GO

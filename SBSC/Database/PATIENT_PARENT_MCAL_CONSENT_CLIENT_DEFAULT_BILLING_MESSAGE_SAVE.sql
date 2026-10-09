USE [spedmon]
GO
 
DROP PROCEDURE if exists [dbo].[PATIENT_PARENT_MCAL_CONSENT_CLIENT_DEFAULT_BILLING_MESSAGE_SAVE]
GO
 
 
CREATE PROCEDURE [dbo].[PATIENT_PARENT_MCAL_CONSENT_CLIENT_DEFAULT_BILLING_MESSAGE_SAVE](
    @userID               BIGINT    
  , @userGroup            INT  
  , @userRank             INT 
  , @recID                bigint
  , @msgText              varchar(max)
  , @editDelReason        VARCHAR(7000)
  , @validateRec          VARCHAR(7000)
  , @MsgNoRec             varchar(max)
  , @MsgNoEdit            varchar(max)
 
  , @recordID             BIGINT        OUTPUT
  , @spDetails            VARCHAR(8000) OUTPUT)  
AS    
BEGIN
 
declare @updateState   as smallint
declare @today         as datetime = GETDATE()
declare @TranOpen      as bit = 0
declare @saveType      as int
declare @auditRecordID as bigint
   
set @spDetails     = ''
set @recordID      = 0
set @updateState   = dbo.CONST_REC_STATE_MOD() 
set @saveType      = dbo.CONST_SAVE_TYPE_EDIT()
set @auditRecordID = 0

BEGIN TRY  
BEGIN TRANSACTION    
    
  SET @TranOpen = 1   

  UPDATE [dbo].CLIENTS_Client
  SET 
      [defaultMCALBillingConsentMsgText] = trim(isnull(@msgText,''))
    , [DATE_MODIFIED]                    = @today
	, [state]                            = @updateState
  WHERE (CLIENT_ID = @recID)

  SET @recordID = @recID

 /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
       
 EXEC dbo.CLIENTS_Audit @recID, @today, @userID, @saveType, @updateState, 'user changing default consent message text via management screen', @auditRecordID output


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


end
GO
 
 
GRANT EXECUTE ON [dbo].[PATIENT_PARENT_MCAL_CONSENT_CLIENT_DEFAULT_BILLING_MESSAGE_SAVE] to webuser
GO
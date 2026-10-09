USE [spedmon]
GO

DROP PROCEDURE if exists [dbo].[PRACTITIONER_FLAG_CURRENTLY_W_CLIENT]
GO


CREATE PROCEDURE [dbo].[PRACTITIONER_FLAG_CURRENTLY_W_CLIENT](

    @userID               BIGINT    
  , @userGroup            INT  
  , @userRank             INT

  , @recID                bigint  
  , @clientID             bigint

  , @currentlyWClient          bit

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

   
set @spDetails     = ''
set @updateState   = dbo.CONST_REC_STATE_MOD() 
set @saveType      = dbo.CONST_SAVE_TYPE_EDIT()

set @editDelReason = ''

set @recordID      = isnull(@recID,0)

BEGIN TRY  
BEGIN TRANSACTION    
    
  set @TranOpen = 1    
  
  UPDATE pp
  SET 
      pp.currentlyWithClient             = @currentlyWClient
    , pp.DATE_MODIFIED                   = @today

    --, pp.createdByUserID                         = @userID
    -- TODO: figure out if this needs auditability

  from [dbo].[PRACTITIONER_Client] as pc
  join [dbo].PRACTITIONER_Practitioner  as pp on pp.PRACTITIONER_ID = pc.PRACTITIONER_ID
  where (
           (pc.CLIENT_ID  = @clientID)
       and (pp.PRACTITIONER_ID = @recordID)
  )
  

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


GRANT EXECUTE ON [dbo].[PRACTITIONER_FLAG_CURRENTLY_W_CLIENT] to webuser
GO
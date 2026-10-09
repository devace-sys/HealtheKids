USE [spedmon]
GO

DROP PROCEDURE if exists dbo.PATIENT_MCAL_OUTREACH_NOTES_SAVE
GO


CREATE PROCEDURE [dbo].[PATIENT_MCAL_OUTREACH_NOTES_SAVE](
    @userID               BIGINT    
  , @userGroup            INT  
  , @userRank             INT 
  , @clientID             bigint
  , @notes                varchar(max)
  , @recID                bigint  /* patID is passed here */
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
set @updateState   = dbo.CONST_REC_STATE_MOD() 
set @saveType      = dbo.CONST_SAVE_TYPE_EDIT()
set @auditRecordID = 0
set @notes         = trim(isnull(@notes,''))
set @editDelReason = 'user updating mcal outreach notes via dedicated management screen'
set @recordID      = isnull(@recID,0)

BEGIN TRY  
BEGIN TRANSACTION    
    
  set @TranOpen = 1    
    
  /*-------------------------------    
   * Update mcal outreach notes
   *------------------------------*/    
  
  UPDATE pp
  SET 
	  pp.mcalOutreachNotes              = @notes
    , pp.LAST_UPDATED                   = @today
    , pp.userID                         = @userID
    , pp.[state]                        = @updateState
  from [dbo].[PATIENTS_Client] as pc
  join [dbo].PATIENTS_Patient  as pp on pp.PATIENT_ID = pc.PATIENT_ID
  where (
           (pc.CLIENT_ID  = @clientID)	  
       and (pp.PATIENT_ID = @recordID)
  )
  
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
       
  EXEC PATIENT_Audit @recordID, @today, @userID, 2, @updateState, @editDelReason, @auditRecordID output

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

GRANT EXECUTE ON [dbo].[PATIENT_MCAL_OUTREACH_NOTES_SAVE] to webuser
GO
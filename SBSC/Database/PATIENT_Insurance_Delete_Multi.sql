USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_Insurance_Delete_Multi') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_Insurance_Delete_Multi
GO



CREATE PROCEDURE [dbo].[PATIENT_Insurance_Delete_Multi] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT  
  , @clientID      BIGINT
  , @recIDMulti    VARCHAR(max) -- svcrecID
  , @MsgNoRec      VARCHAR(1000)    
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT)

AS    
BEGIN    
     
SET NOCOUNT ON    

set @spDetails = ''
set @recordID  = 0

declare @today    as datetime = getdate()
declare @tranOpen as bit      = 0
declare @currIDX  as int      = 1
declare @maxIDX   as int      = 0
declare @recID    as bigint   = 0

declare @recs AS TABLE (  
      idx        int    identity(1,1)
    , recID      bigint
	unique clustered (idx)  
)

BEGIN TRY
 
  INSERT INTO @recs (recID)
  select 
    recID = convert(bigint,t1.[value])
  from STRING_SPLIT(@recIDMulti,',') as t1
  
  set @maxIdx = 0
  select @maxIDX = MAX(t1.idx) from @recs as t1
  if (@maxIdx = 0) return

  BEGIN TRANSACTION

  set @tranOpen = 1

  while ( @currIdx <= @maxIdx )
  begin
 
    select  top 1 
	  @recID = recID
    from  @recs as t1
    where 
	  (t1.idx = @currIDX)

    exec dbo.PATIENT_Insurance_Delete_Core  
        @userID        
      , @userGroup    
      , @userRank     
      , @editDelReason
      , @validateRec  
      , @clientID     
      , @recID        
  	  , @today        
      , @MsgNoRec     
      , @MsgNoEdit    
      , @spDetails    OUTPUT
      , @recordID     OUTPUT

    set @currIdx = @currIdx + 1
     
  END /* while */
  
  set @recordID = @maxIDX

  if (@tranOpen  = 1) COMMIT TRANSACTION    

  /*-------------------------------    
   * And we are done
   *------------------------------*/  

  set @tranOpen = 0  
 
  RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
 
  -- Error or raise error with severity 11 to 19 will be caught here    
   
  /*-------------------------------    
   * Cancel any pending    
   * transactions  
   *------------------------------*/    
     
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
     
  /*-------------------------------    
   * Identify error
   *------------------------------*/    
 
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
  SET @ErrorMessage = @ErrorMessage
     
 /*-------------------------------    
   * Return the error message to
   * the caller.
   *------------------------------*/    
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[PATIENT_Insurance_Delete_Multi] TO [webuser]
GO
USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_MULTI') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_MULTI
GO

CREATE PROCEDURE [dbo].[CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_MULTI] (

    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT 

  , @recIDMulti    VARCHAR(max) 

  , @MsgNoRec      VARCHAR(1000)    
  , @MsgNoEdit     VARCHAR(1000)

  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT

)

AS    
BEGIN    
     
SET NOCOUNT ON    

set @spDetails = ''
set @recordID  = 0

if (@validateRec is null)  RAISERROR ('Validate flag required',  11, 1)    
if (@userID      is null)  RAISERROR ('User id required',        11, 1)    

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

     -- raiserror if problem
     -- exec [dbo].[CLAIM_SERVICE_NAME_XREF_AMD_XFORM_CAN_DELETE_VALIDATE]    
     --   @recID  
     -- , @MsgNoRec
     -- , @recordID   OUTPUT

    IF (@validateRec = 0)
    begin
	    exec dbo.CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_CORE
          @userID        
        , @recID        
	end

    set @currIdx = @currIdx + 1
     
  END /* while */
  
  set @recordID = @maxIDX
  
  /*============================================================
   * Update cached cross ref snx data if we are not validating
   *============================================================*/  

  if (@validateRec = 0)
  begin
    exec dbo.CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED_UPDATE_CORE
  end

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
 
GRANT EXECUTE ON  [dbo].[CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_MULTI] TO [webuser]
GO
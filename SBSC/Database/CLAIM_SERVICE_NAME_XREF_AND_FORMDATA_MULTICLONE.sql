USE SPEDMON
GO

/* Note: Used for bulk creation of new non standard form data */

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_SERVICE_NAME_XREF_AND_FORMDATA_MULTICLONE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_SERVICE_NAME_XREF_AND_FORMDATA_MULTICLONE
GO

CREATE PROCEDURE [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORMDATA_MULTICLONE] (

    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT 

  , @recIDMulti    VARCHAR(max) 

  , @clientIDsForClones   bigint
      -- NOTE: clientIDsForClones shouldn't be pluralized.  Consider FIXING all the way up and down the callstack

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

IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1) 

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

     declare  	    @planTypeID             BIGINT
				  , @groupID                BIGINT
				  , @nameID                 BIGINT
				  , @formDataJSON           VARCHAR(MAX)
				  , @hasPatientGoalTracking    BIT
				  , @hasSessionRatingTracking  BIT 
				  , @spEdSvcCodeValue          INT
				  , @fillablePdfSelectionsJSON varchar(max) ;

    SELECT
	  	    @planTypeID        = planTypeID
		  , @groupID           = groupID           
		  , @nameID            = svcNameID  
		  , @formDataJSON      = formDataJSON       
		  , @hasPatientGoalTracking      = hasPatientGoalTracking
		  , @hasSessionRatingTracking     = hasSessionRatingTracking
		  , @spEdSvcCodeValue             = spEdSvcCodeValue        
		  , @fillablePdfSelectionsJSON    = fillablePdfSelectionsJSON
	FROM
	[dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW_CORE] (
                                     
			null  -- @clientID            BIGINT
		  , null  -- @planTypeID          BIGINT
		  , null  -- @groupID             BIGINT
		  , null  -- @nameID              BIGINT
		  , null  -- @groupSvcClassNameID BIGINT
		  , null  -- @hasClientID         BIT

		  , 1  -- @active              BIT
		  , @recID
		)

    exec [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SAVE_CORE] 
			@userID                
		  , @userGroup          
		  , @userRank           

		  , @clientIDsForClones     

			--
		  , @planTypeID       
		  , @groupID           
		  , @nameID               
		  , @formDataJSON           
		  , @hasPatientGoalTracking   
		  , @hasSessionRatingTracking 
		  , @spEdSvcCodeValue         
		  , @fillablePdfSelectionsJSON
			--

		  , @editDelReason    
		  , @validateRec  
		  , 1      /* Important that this is preset to 1 = New */ --@saveType               INT
		  , null    -- @recID                  BIGINT

		  , @MsgNoRec              
		  , @MsgNoEdit   
		  
		  , 'duplicate rec' -- @MsgDupRec              
		  , 'data error' -- @MsgDataError           
		  , 'not active' -- @MsgNotActive           

		  , @spDetails              OUTPUT
		  , @recordID               OUTPUT

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
 
GRANT EXECUTE ON  [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORMDATA_MULTICLONE] TO [webuser]
GO
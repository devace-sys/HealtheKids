USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_KNOWN_HEALTH_PROBLEMS_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_KNOWN_HEALTH_PROBLEMS_SAVE
GO
 
CREATE PROCEDURE dbo.PATIENT_KNOWN_HEALTH_PROBLEMS_SAVE (
    @userID                BIGINT
  , @userGroup             INT
  , @userRank              INT
  , @clientID              bigint
  , @patID                 bigint
  , @knownHealthProblemID  bigint
  , @isPriority            bit
  , @notes                 varchar(max)
  , @editDelReason         VARCHAR(7000)
  , @validateRec           BIT    
  , @recID                 BIGINT
  , @MsgNoRec              VARCHAR(1000)   
  , @MsgDupRec             VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
  , @MsgNotActive          VARCHAR(1000)
  , @MsgDataError          VARCHAR(1000)
  , @saveType              smallint
  , @spDetails             VARCHAR(8000) OUTPUT    
  , @recordID              BIGINT        OUTPUT)   
AS    
BEGIN    
     
SET NOCOUNT ON    
   
DECLARE @today      AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen   AS BIT            -- Is a transaction open


BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID   = 0    
SET @spDetails  = '' 

/*-------------------------------    
 * Init working variables    
 *------------------------------*/    

SET @today = GETDATE()   
   
/*-------------------------------    
 * Make sure notes has a value
 * even if its an empty string
 *------------------------------*/    

set @notes = trim(isnull(@notes,''))

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
IF (@userGroup         	IS NULL) RAISERROR ('userGroup is required',   		 11, 1)
IF (@userID      		IS NULL) RAISERROR ('user id is required',     		 11, 1)    
IF (@userRank     		IS NULL) RAISERROR ('userRank is required',   		 11, 1)    
IF (@validateRec  		IS NULL) RAISERROR ('Validate flag required', 		 11, 1)    
IF (@saveType     		IS NULL) RAISERROR ('Save type is required',   		 11, 1)    
IF (@clientID           IS NULL) RAISERROR ('Client Id is required',  11, 1)  
IF (@patID			    IS NULL) RAISERROR ('Patient Id is required',        11, 1) 


/*============================================================
 * If we are editing the record, make sure it exists 
 *============================================================*/  
  
if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  IF (@recID IS NULL) RAISERROR ('Record id is required', 11, 1)    
  
  select top 1 
    @recordID = pkhp.id
  from dbo.PATIENT_KNOWN_HEALTH_PROBLEMS as pkhp
  where (
        (1=1)
	and (pkhp.clientID = @clientID)
    and (pkhp.patID    = @patID)
    and (pkhp.id       = @recID)             
  )
  
  if (@recordID != @recID)
  begin
    RAISERROR (@MsgNoRec, 11, 1)
  end

end

/*============================================================
 * Check for duplicate records in all active records
 *============================================================*/  

if exists (
  select top 1 
    cd.id
  from dbo.PATIENT_KNOWN_HEALTH_PROBLEMS as cd
  where (
        (1=1)
    and (cd.clientID = @clientID)
    and ((@recID IS NULL) or (cd.id != @recID))             
    and (cd.patID = @patID)
	and (cd.knownHealthProblemID = @knownHealthProblemID)
	and (cd.ACTIVE = 1)
  )
)
begin
  RAISERROR (@MsgDupRec, 11, 1)
end

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END                          
    
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * New record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN        
    
    INSERT INTO [dbo].[PATIENT_KNOWN_HEALTH_PROBLEMS]
    ( 
	     clientID            
	   , patID
	   , knownHealthProblemID
	   , active
	   , created     
	   , createdBy
       , isPriority
	   , notes
	)    
    VALUES    
    (  
	     @clientID	              
	   , @patID
	   , @knownHealthProblemID
	   , 1
	   , @today
	   , @userID
       , @isPriority
	   , @notes
    )      
    
    SET @recordID = SCOPE_IDENTITY()    
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/                      
       
     UPDATE [dbo].[PATIENT_KNOWN_HEALTH_PROBLEMS]
     SET    	         
		     knownHealthProblemID  = @knownHealthProblemID
		   , lastModified          = @today
           , lastModifiedBy        = @userID
           , isPriority            = @isPriority
		   , notes                 = @notes
     WHERE ([id] = @recID)
 
     SET @recordID = @recid
    
  END    
  ELSE    
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
      
       
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
   
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
     
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ''    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.PATIENT_KNOWN_HEALTH_PROBLEMS_SAVE TO webuser
GO
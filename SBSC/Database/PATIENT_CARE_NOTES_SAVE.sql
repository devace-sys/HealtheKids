USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_CARE_NOTES_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_CARE_NOTES_SAVE
GO
 
CREATE PROCEDURE dbo.PATIENT_CARE_NOTES_SAVE (
    @userID                 BIGINT
  , @userGroup              INT
  , @userRank               INT
  , @clientID               BIGINT 
  , @groupSvcClassNameID    BIGINT 
  , @patID                  BIGINT    
  , @note           		VARCHAR(MAX)
  , @saveType               SMALLINT      OUTPUT
  , @spDetails              VARCHAR(8000) OUTPUT   
  , @recordID               BIGINT        OUTPUT)  
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
set @saveType  = 0

/*-------------------------------    
 * Init working variables    
 *------------------------------*/    

SET @today = GETDATE() 

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
IF (@userGroup         	 IS NULL) RAISERROR ('userGroup is required',		11, 1)
IF (@userID      		 IS NULL) RAISERROR ('user id is required',     	11, 1)    
IF (@userRank     		 IS NULL) RAISERROR ('userRank is required',   		11, 1) 
IF (@clientID            IS NULL) RAISERROR ('Client Id is required',		11, 1)  
IF (@patID			     IS NULL) RAISERROR ('Patient Id is required',      11, 1) 
IF (@groupSvcClassNameID IS NULL) RAISERROR ('Patient Id is required',      11, 1)  


/*============================================================
 * If we are editing the record, make sure it exists 
 *============================================================*/  

set @recordID  = 0
set @saveType  = 0
  
  select top 1 
    @recordID = isnull(id, 0)
  from dbo.PATIENT_CARE_NOTES
  where (
        (1=1)
	and (clientID			 = @clientID)
    and (patID				 = @patID)
    and (groupSvcClassNameID = @groupSvcClassNameID)  
)

/*============================================================
 * Determine save type
 *============================================================*/  

if      (@recordID = 0) set @saveType = dbo.CONST_SAVE_TYPE_NEW()
else if (@recordID > 0) set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
else                    set @saveType = 0

/*============================================================
 * Exit if save type is unknown
 *============================================================*/  

if (@saveType = 0) RAISERROR ('Unknown save type', 11, 1)   

/*============================================================
 * Save
 *============================================================*/  

BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * New record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN        
    
    INSERT INTO [dbo].[PATIENT_CARE_NOTES]
    ( 
	     clientID 
	   , groupSvcClassNameID           
	   , patID
	   , note
	   , created     
	   , createdBy
	   , active
	)    
    VALUES    
    (  
	     @clientID	
	   , @groupSvcClassNameID	               
	   , @patID
	   , @note
	   , @today
	   , @userID
	   , 1
    )        
    
    SET @recordID = SCOPE_IDENTITY()    
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/                      
       
     UPDATE [dbo].[PATIENT_CARE_NOTES]
     SET    	       
		     note				 = @note
		   , lastModified        = @today
           , lastModifiedBy      = @userID
     WHERE (
			(clientID = @clientID)
		and (groupSvcClassNameID = @groupSvcClassNameID)    
		and (patID = @patID)
	)
    
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
 
GRANT EXECUTE ON  dbo.PATIENT_CARE_NOTES_SAVE TO webuser
GO
USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SITES_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SITES_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SITES_Save]     
(

  @userID							BIGINT
, @userGroup						INT
, @userRank							INT 
--, @SITE_ID INT
, @SITE_CLIENT_ID					INT
, @SITE_CDS							VARCHAR(1000)
, @SITE_NAME						VARCHAR(1000)
, @CLIENT_PROVIDED_SITE_UID			VARCHAR(20)
, @ADDRESS_1						NVARCHAR(1000)
, @ADDRESS_2						NVARCHAR(1000)
, @CITY								NVARCHAR(1000)
, @STATE							NVARCHAR(1000)
, @ZIP								NVARCHAR(5)
, @ZIP4								NVARCHAR(4)
, @PHONE_NUMBER						VARCHAR(50)
, @cybhiTpaApproved                 BIT
, @cybhiTpaApprovedOn               DATE
, @attemptFuzzyMatchByNameAndCode	BIT
, @editDelReason					VARCHAR(7000)
, @validateRec						BIT 
, @saveType							INT 
, @recID							BIGINT
, @MsgNoRec							VARCHAR(1000) 
, @MsgNoEdit						VARCHAR(1000)
, @MsgDupRec						VARCHAR(1000) 
, @MsgDataError						VARCHAR(1000)
, @MsgNotActive						VARCHAR(1000)
, @spDetails						VARCHAR(8000) OUTPUT
, @recordID							BIGINT OUTPUT
, @recData1							VARCHAR(255)  OUTPUT
, @recData2							VARCHAR(255)  OUTPUT
, @recData3							VARCHAR(255)  OUTPUT
, @recData4							VARCHAR(255)  OUTPUT


) 
 
AS 
BEGIN

SET NOCOUNT ON


DECLARE @today        AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen     AS BIT            -- Is a transaction open    
DECLARE @dupCount     AS INT            -- Duplicate counter used for validation    
DECLARE @updateState  AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @canEdit      AS BIT   
DECLARE @tempRecID    AS INT            -- Used for determining if a rec exists    
DECLARE @auditRecID   AS BIGINT     

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @recData1   = ''
SET @recData2   = ''    
SET @recData3   = ''
SET @recData4   = ''

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
    
IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))     
  RAISERROR ('updateRecID is required', 11, 1)    
                                  
/*-------------------------------    
 * Prep worker variables                
 *------------------------------*/    
     
SET @today = GETDATE()    
    
/*-------------------------------    
 * If this is an edit
 *------------------------------*/       
  
IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())     
BEGIN  
  
  /*-------------------------------    
   * Check to see if the record
   * exists and if it can be edited 
   *------------------------------*/       
  
  SET @recordID = NULL    
  SET @canEdit  = 0   
  
  SELECT 
    @recordID = SITE_ID, 
    @canEdit  = Active 
  FROM dbo.SITES_Site        
  WHERE SITE_ID = @recID
     
  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1)  
         
END    
        
/*-------------------------------    
 * Validation    
 *------------------------------*/    
/*
IF (((@saveType = dbo.CONST_SAVE_TYPE_NEW()) OR    
     (@saveType = dbo.CONST_SAVE_TYPE_EDIT())))    
*/

IF (@validateRec = 1)
  RETURN(0)  

declare @loweredSiteName as varchar(50) = null
if (@SITE_NAME is not null) set @loweredSiteName = LOWER(@SITE_NAME)

BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
    
  /*-------------------------------    
   * New subscription record 
   *------------------------------*/    
    
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
    
    SET @updateState = dbo.CONST_REC_STATE_NEW()    
        
    INSERT INTO dbo.SITES_Site
    (
      
      SITE_CLIENT_ID,
      SITE_CDS,
      SITE_NAME,
      LOWERED_SITE_NAME,
	  attemptFuzzyMatchByNameAndCode,
      DATE_CREATED,
      CREATED_BY,
      CLIENT_PROVIDED_SITE_UID,
	  cybhiTpaApproved,
	  cybhiTpaApprovedOn,
      ACTIVE
	 )  
    VALUES
     (
	  @SITE_CLIENT_ID,
      @SITE_CDS,
      @SITE_NAME,
      @loweredSiteName,
	  @attemptFuzzyMatchByNameAndCode,
      @today,
      @userID,
      @CLIENT_PROVIDED_SITE_UID,
	  @cybhiTpaApproved,
	  @cybhiTpaApprovedOn,
      1
	 )      
    
    SET @recordID = SCOPE_IDENTITY()       
            
  
  
  END  
  
  /*-------------------------------    
   * Edit existing subscription
   * record    
   *------------------------------*/     
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN               
      
     SET @updateState = dbo.CONST_REC_STATE_MOD()     
                      
     UPDATE SITES_Site
     
     SET
      SITE_CLIENT_ID				    = @SITE_CLIENT_ID,
      SITE_CDS						    = @SITE_CDS,
      SITE_NAME					        = @SITE_NAME,	  
      @loweredSiteName			        = LOWER(@SITE_NAME),
	  attemptFuzzyMatchByNameAndCode    = @attemptFuzzyMatchByNameAndCode,
	  cybhiTpaApproved					= @cybhiTpaApproved,
	  cybhiTpaApprovedOn				= @cybhiTpaApprovedOn,
      DATE_MODIFIED				        = @today,
      LAST_MODIFIED_BY			        = @userID
     
     WHERE 
     
       (SITE_ID = @recordID)
      
             
  END    
  ELSE     
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
  
  /* Populate site address data */
  
  declare @siteAddressID as bigint 
  set @siteAddressID = null
  
  select top 1 
    @siteAddressID = SITE_ADDRESS_ID 
  from dbo.SITES_ADDRESS 
  where (SITE_ID = @recordID)
  
  if (@siteAddressID is null)
  begin  
    
    insert into dbo.SITES_ADDRESS (
          SITE_ID
        , ADDRESS_1
        , ADDRESS_2
        , CITY
        , [STATE]
        , ZIP
		, ZIP_PLUS_FOUR
		, PHONE_NUMBER
    )
    values (
       @recordID
     , @ADDRESS_1
	 , @ADDRESS_2
     , @CITY
     , @STATE
     , @ZIP
	 , @ZIP4
	 , @PHONE_NUMBER
    )
  end
  else
  begin
  
    update dbo.SITES_ADDRESS 
    set           
        ADDRESS_1     = @ADDRESS_1
      , ADDRESS_2     = @ADDRESS_2
      , CITY          = @CITY
      , STATE         = @STATE
      , ZIP           = @ZIP
	  , ZIP_PLUS_FOUR = @ZIP4
	  , PHONE_NUMBER  = @PHONE_NUMBER
    where 
	  (SITE_ADDRESS_ID = @siteAddressID)
       
  end
    
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
  
  EXEC SITES_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT        
       
  /*-------------------------------    
   * Get place id
   *------------------------------*/    

   select top 1
   
      @recData1 = placeID                  

   from dbo.SITE_PLACES_VIEW_CORE (  @userID
                                   , @userGroup
                                   , @userRank
                                   , @SITE_CLIENT_ID
                                   , null                              
                                   , 1
                                   , @recordID ) as t1
   where (t1.id = @recordID)
   


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
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[SITES_Save] TO [webuser]
GO
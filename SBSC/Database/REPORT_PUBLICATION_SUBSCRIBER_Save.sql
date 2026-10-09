USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_SUBSCRIBER_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.REPORT_PUBLICATION_SUBSCRIBER_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[REPORT_PUBLICATION_SUBSCRIBER_Save]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @clientID      INT,
  @email          VARCHAR(1000),
  @internalSubscriber BIT,
  @lastName       VARCHAR(1000),
  @firstName      VARCHAR(1000),
  @editDelReason           VARCHAR(7000),    
  @validateRec             BIT,    
  @saveType                INT,    
  @recID                   BIGINT,    
  @MsgNoRec                VARCHAR(1000),    
  @MsgNoEdit               VARCHAR(1000), 
  @MsgDupRec               VARCHAR(1000),     
  @MsgNoClient             VARCHAR(1000),
  @MsgDataError            VARCHAR(1000),
  @MsgNotActive            VARCHAR(1000),     
  @spDetails               VARCHAR(8000) OUTPUT,    
  @recordID                BIGINT        OUTPUT)    
AS    

BEGIN     
    
/***************************************************************************    
 * REPORT_PUBLICATION_SUBSCRIBER_Save */    
/**    
 * Creates a new or edits existing report publication subscriber record
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Patient's client id    
 * @param   editDelReason   Reason for record edit or delete    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @param   recID           Record id of existing patient record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found    
 * @param   MsgNoSite       Desired error message if a siteID is not found     
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @today        AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen     AS BIT            -- Is a transaction open    
DECLARE @dupCount     AS INT            -- Duplicate counter used for validation    
DECLARE @updateState  AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @canEdit      AS BIT   
DECLARE @tempRecID    AS BIGINT         -- Used for determining if a rec exists    
DECLARE @XrefUserID   AS BIGINT         -- Cross reference UserID
DECLARE @auditRecID   AS BIGINT     

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @recordID   = 0    
SET @spDetails  = ''    
    
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
IF (@email         IS NULL) RAISERROR ('Email is required',       11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
    
IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))     
  RAISERROR ('updateRecID is required', 11, 1)    
                                  
/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today      = GETDATE()    
set @XRefUserId = null
    
/*-------------------------------    
 * If this is an edit
 *------------------------------*/       
  
IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())     
BEGIN  
  
  /*-------------------------------    
   * Check to see if the record
   * exists and if it can be edited 
   *------------------------------*/       
  
  SET @recordID = null    
  SET @canEdit  = 0   
  
  SELECT 
    @recordID = ID, 
    @canEdit  = Active 
  from 
    dbo.REPORT_PUBLICATION_SUBSCRIBERS  
  where 
    ID = @recID
     
  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1)  
         
END    
        
/*-------------------------------    
 * If this is a new record
 *------------------------------*/      

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin 

  /*-------------------------------    
   * Cross reference to existing
   * user record
   *------------------------------*/    

  select 
    @XRefUserId = uv.id 
  from 
    users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) as uv
  where 
    uv.email = @email

end

/*-------------------------------    
 * Validation    
 *------------------------------*/    
    
IF (((@saveType = dbo.CONST_SAVE_TYPE_NEW()) OR    
     (@saveType = dbo.CONST_SAVE_TYPE_EDIT())))    
BEGIN    
       
  /*-------------------------------    
   * Verify client id exists    
   *-------------------------------*/    
    
  if (@clientID != null)
  begin
    SET    @tempRecID = NULL    
    SELECT top 1 @tempRecID = CLIENT_ID FROM dbo.CLIENTS_CLIENT WHERE CLIENT_ID = @clientID    
    
    IF (@tempRecID <> @clientID) RAISERROR (@MsgNoClient, 11, 1)            
  end
    
  /*-------------------------------    
   * Look for duplicate records 
   * excluding the record specified
   * by recid    
   *------------------------------*/    

  SET @dupCount = 0   
    
  select 
    @dupCount = COUNT(id) 
  from 
    dbo.REPORT_PUBLICATION_SUBSCRIBERS
  where
    (((@recID IS NULL) OR (id != @recID)) 
    and (Active = 1) 
    and (email = @email)) 
   
   /*-------------------------------    
    * If a duplicate record was 
    * found, get out!
    *------------------------------*/    
    
   if (@dupCount > 0) RAISERROR (@MsgDupRec, 11, 1) 

   /*-------------------------------    
    * Internal user check
    *------------------------------*/    

   if (@internalSubscriber is null) set @internalSubscriber = 0

   if (@internalSubscriber = 0) 
   begin

     if (dbo.IS_EMAIL_IN_CLIENT_DOMAIN(@clientID,@email) = 0)
	 begin
       RAISERROR ('Please use an official e-mail provided by the subscriber’s employer', 11, 1)    
	 end
   
   end

   else 
   begin
     if (@userGroup != dbo.CONST_USER_GROUP_SBS())
	 begin
	   RAISERROR ('Practi-Cal staff only can set this value', 11, 1)    
	 end
   end
   

  /*-------------------------------    
   * Advisement validation    
   *------------------------------*/    
    
  IF (@validateRec = 1)    
  BEGIN    
         
    
    
    /*-------------------------------    
     * If we are providing advisement    
     * validation exit now    
     *------------------------------*/    
              
    IF (@validateRec = 1) RETURN(0)    
       
  END  

END  
      
/*-------------------------------    
 * Create or modify our     
 * subscription record
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
    
  /*-------------------------------    
   * New subscription record 
   *------------------------------*/    
    
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
    
    SET @updateState = dbo.CONST_REC_STATE_NEW()    
        
    INSERT INTO REPORT_PUBLICATION_SUBSCRIBERS
      (ClientID,
       Email,
       is_internal,
       LastName,
       FirstName,
       XRefUserID,
       Created,
       CreatedBy,
       Active)    
       
    VALUES     
    
      (@clientID,     
       @email,
       @internalSubscriber,     
       @lastName,     
       @firstName,    
       @XrefUserID, 
       @today,
       @userID,
       1)      
    
    SET @recordID = SCOPE_IDENTITY()       
            
  END  
  
  /*-------------------------------    
   * Edit existing subscription
   * record    
   *------------------------------*/     
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN               
      
     SET @updateState = dbo.CONST_REC_STATE_MOD()     
                      
     UPDATE REPORT_PUBLICATION_SUBSCRIBERS
     
     SET
     
       ClientID           = @clientID,
       Email              = @email,
       is_internal        = @internalSubscriber,
       LastName           = @lastName,
       FirstName          = @firstName,
       LastUpdated        = @today,
       LastUpdatedBy      = @userID 
     
     WHERE 
     
       ID = @recordID
                
  END    
  ELSE     
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
    
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
  
  EXEC REPORT_PUBLICATION_SUBSCRIBERS_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
            
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
 
GRANT EXECUTE ON  [dbo].[REPORT_PUBLICATION_SUBSCRIBER_Save] TO [webuser]
GO

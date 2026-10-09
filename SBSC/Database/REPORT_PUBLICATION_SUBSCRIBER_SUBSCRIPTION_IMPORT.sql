USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_SUBSCRIBER_SUBSCRIPTION_IMPORT') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.REPORT_PUBLICATION_SUBSCRIBER_SUBSCRIPTION_IMPORT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[REPORT_PUBLICATION_SUBSCRIBER_SUBSCRIPTION_IMPORT]     
( @clientID      INT,
  @firstName     VARCHAR(1000),
  @lastName      VARCHAR(1000),
  @email         VARCHAR(1000),
  @publicationID INT)    
AS    

BEGIN     
    
/***************************************************************************    
 * REPORT_PUBLICATION_SUBSCRIBER_SUBSCRIPTION_IMPORT */    
/**    
 * Throw away code.
 * Used for importing existing subscriber and subscription data
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE  @today          AS DATETIME       -- Current date/time stamp    
DECLARE  @tranOpen       AS BIT            -- Is a transaction open    
DECLARE  @subscriberID   AS BIGINT
DECLARE  @XrefUserID     AS BIGINT
DECLARE  @subscriptionID AS BIGINT
DECLARE  @tempRecID      AS BIGINT         -- Used for determining if a rec exists   
DECLARE  @dupCount       AS INT
DECLARE  @recText        AS VARCHAR(4000)

BEGIN TRY    
    
/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today = GETDATE()    

/*-------------------------------    
 * Clean up incoming variables
 *------------------------------*/    
 
 set @email     = rtrim(ltrim(@email))
 set @lastName  = rtrim(ltrim(@lastName))
 set @firstName = rtrim(ltrim(@firstName))    

/*-------------------------------    
 * Display info about record
 *-------------------------------*/    

set @recText = convert(varchar(50),@clientID) + ' ' + @firstName + ' ' + @lastName + ' ' + @email + ' ' + convert(varchar(50),@publicationID)
RAISERROR(@recText, 0, 1) WITH NOWAIT

/*-------------------------------    
 * Verify client id exists    
 *-------------------------------*/    
    
SET    @tempRecID = NULL    
SELECT @tempRecID = CLIENT_ID FROM CLIENTS_CLIENT WHERE CLIENT_ID = @ClientID    
    
IF (@tempRecID <> @clientID)
  RAISERROR ('Client does not exist', 11, 1)            

/*-------------------------------    
 * Verify publication id exists
 *-------------------------------*/    

SET    @tempRecID = NULL    
SELECT @tempRecID = ID FROM REPORT_PUBLICATIONS WHERE ID = @publicationID

IF (@tempRecID <> @publicationID)
  RAISERROR ('Publication does not exist', 11, 1)  

/*-------------------------------    
 * Verify email is OK
 *-------------------------------*/  
   
if (dbo.IS_EMAIL_IN_CLIENT_DOMAIN(@clientID,@email) = 0)
  RAISERROR ('You are only allowed to use official district emails', 11, 1)    

/*-------------------------------    
 * See if subscriber already
 * exists, if so we will use
 * the existing subscriber record 
 * to setup a subscription
 *------------------------------*/    
  
SET @subscriberID = null
  
SELECT 
  @subscriberID = ID
from 
  REPORT_PUBLICATION_SUBSCRIBERS  
where 
  email = @email


BEGIN TRANSACTION    
    
SET @TranOpen = 1    
    
/*-------------------------------    
 * This is a new subscriber
 *------------------------------*/    

if (@subscriberID is null)
begin
  
  RAISERROR('  New subscriber', 0, 1) WITH NOWAIT    
  
  /*-------------------------------    
   * Cross reference to existing
   * user record
   *------------------------------*/    
  
  set @XrefUserID = null
  
  select 
    @XRefUserId = uv.id 
  from 
    users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) as uv
  where 
    uv.email = @email

  if (@XrefUserID is not null)
  begin
    RAISERROR('  Has user account', 0, 1) WITH NOWAIT    
  end
  
  /*-------------------------------    
   * Insert new subscriber record
   *------------------------------*/    

  INSERT INTO REPORT_PUBLICATION_SUBSCRIBERS
   
    (ClientID,
     Email,
     LastName,
     FirstName,
     XRefUserID,
     Created,
     CreatedBy,
     Active)    
       
   VALUES     
       
    (@clientID,     
     @email,     
     @lastName,     
     @firstName,    
     @XrefUserID, 
     @today,
     0,
     1)
       
   set @subscriberID = SCOPE_IDENTITY()     

end
else
begin
  RAISERROR('  Subscriber record already exists', 0, 1) WITH NOWAIT    
end

/*-------------------------------    
 * See if subscription
 * already exists.  If so then
 * there must be a duplicate
 * import
 *------------------------------*/    

set @subscriptionID = null

select 
  @subscriptionID = ID
from 
  REPORT_PUBLICATION_SUBSCRIPTIONS 
where
  (Active = 1) 
  and (SubscriberID  = @subscriberID) 
  and (PublicationID = @publicationID)

/*-------------------------------    
 * New subscription record 
 *------------------------------*/    

if (@subscriptionID is null)
begin

  RAISERROR('  New subscription', 0, 1) WITH NOWAIT    
  
  INSERT INTO REPORT_PUBLICATION_SUBSCRIPTIONS 

    (ClientID,
     PublicationID,
     SubscriberID,
     AutoDistribute,
     DistributionNotes,
     Created,
     CreatedBy,
     Active)    

  VALUES         

    (@clientID,     
     @publicationID,     
     @subscriberID,     
     1,    
     '', 
     @today,
     0,
     1)      
    
  SET @subscriptionID = SCOPE_IDENTITY()       

end
else
begin
 RAISERROR('  Subscription record already exists', 0, 1) WITH NOWAIT    
end

            
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

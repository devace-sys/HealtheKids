USE [spedmon]
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGE_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGE_DELETE
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGE_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.NEWSLETTER_PAGE_DELETE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[NEWSLETTER_PAGE_DELETE]
 (@userID                BIGINT,    
  @userGroup             INT,    
  @userRank              INT, 
  
  @appName               varchar(50),    /* Application name (from web.config)*/
  @editDelReason         VARCHAR(7000),    
  @validateRec           BIT,    
  @recID                   BIGINT,    
  
  @MsgNoRec                VARCHAR(1000),    
  @MsgNoEdit               VARCHAR(1000), 
  @spDetails               VARCHAR(8000) OUTPUT,    
  @recordID                BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * NEWSLETTER_PAGE_DELETE */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   userID          The userID of who is requesting the new user account  
 * @param   userGroup       That users group    
 * @param   userRank        That user rank
 * @param   appDomain       Application domain (can be same as appName)
 * @param   appName         Application name (from web.config)
 * @param   usrid           Preference is for this user id
 * @param   selector        Scope of application of this preference.  Selectors 
 *                          could be CSS selectors, or names of end points.
 * @param   selectorType    Type of selector used.  Must set this properly.  CSS, END_POINT
 * @param   noun            Object name
 * @param   verb            Object method
 * @param   name            Method argument name
 * @param   value           Method argument value
 * @returns spDetails       Validation or error details    
 * @returns saveType        1 = New record created, 2 = Existing record edited
 * @returns recordID        New record id or record id of user record that    
 *                          was modified  
 ***************************************************************************/        

SET NOCOUNT ON    
   
DECLARE @today            AS DATETIME         -- Current date/time stamp    
DECLARE @tranOpen         AS BIT              -- Is a transaction open    
DECLARE @tempRecID        AS BIGINT
DECLARE @tempMsg          AS VARCHAR(1000)

BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters   
 *------------------------------*/    

SET @spDetails  = ''    
set @recordID   = 0

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today = GETDATE()    

/*-------------------------------    
 * Save a new record or replace
 * an existing record
 *------------------------------*/    
   
BEGIN TRANSACTION    
SET @TranOpen = 1    

-- Find rec

set @recordID = null

select top 1 
  @recordID = id
from dbo.NewsletterPages
where (
      (appName = @appName) 
  and (id = @recID)
)

if (@recordID is not null)
begin
  update dbo.NewsletterPages
  set 
      active         = 0
    , lastModified   = @today
    , lastModifiedBy = @userID  
  where (id = @recordID)
end

-- Update it
                                
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
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[NEWSLETTER_PAGE_DELETE] TO [webuser]
GO
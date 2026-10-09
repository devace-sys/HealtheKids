USE [spedmon]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PREFERENCE_SPED_SERVICE_SAVE_OR_REPLACE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PREFERENCE_SPED_SERVICE_SAVE_OR_REPLACE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE PROCEDURE [dbo].[PRACTITIONER_PREFERENCE_SPED_SERVICE_SAVE_OR_REPLACE]
(
  @userID                BIGINT,    
  @userGroup             INT,    
  @userRank              INT,

  @clientID bigint ,

  @pracID              bigint ,

  -- @disciplineGroupID   bigint ,

  @spEdServiceCode       bigint ,

  --@editDelReason         VARCHAR(7000),
      
  --@validateRec           BIT,    
  @saveType              INT             OUTPUT,
   
  @spDetails               VARCHAR(8000) OUTPUT,    
  @recordID                BIGINT        OUTPUT
)

AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONER_PREFERENCE_SPED_SERVICE_SAVE_OR_REPLACE */    
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

/*-------------------------------    
 * If we are providing advisement    
 * validation exit now    
 *------------------------------*/    
        
-- IF (@validateRec = 1) RETURN(0)  


BEGIN TRY    
  

SET @spDetails  = ''    
set @recordID   = 0

     
SET @today = GETDATE()    

/*
if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  select top 1 
    @recordID = id
  from dbo.PRACTITIONER_PREFERENCE_SPED_SERVICES

  where (
    (id = @recID)
    AND
    (pracID = @pracID)
    AND
    (clientID = @clientID)
  )


end
*/

declare @disciplineGroupID  bigint

select top 1 
     @disciplineGroupID = GROUP_ID
from [dbo].[PRACTITIONER_GROUPS]  pg

WHERE (
      (pg.PRACTITIONER_ID = @pracID)
  and (pg.GROUP_TYPE in (1,2))
  and (pg.ACTIVE = 1)
)

/*   NOTE: Existing record check code

- We will need to look for any active or inactive records that match the client, practitioner, and spEd service code as we only want to allow up to one complete set of spEd service code associations per practitioner
These associations can be active or not. For example if a practitioner adds a preference for spEdservice 415.... then they remove it it.... and later on they add a preference for 415 (same one they removed previously)
we would have initially inserted an new row, then updated it to active = 0, then updated it to active = 1.
You can facilte this in the save sproc by looking for a record for the client, prac, and speEd service code and if none is found, insert one... but if one is found include a active = 1 in the update statement
this will automatically ensure that if the record was active = 0, it gets reactivated, and it does not impact if the record is active.

*/

declare  @reac_ID  bigint

          SELECT
            @reac_ID = id
          FROM
            dbo.PRACTITIONER_PREFERENCE_SPED_SERVICES
          WHERE (
                [clientID]  = @clientID
	              AND
                [pracID]    = @pracID
	              -- AND
                -- [disciplineGroupID]   =   @disciplineGroupID
	              AND
                [spEdServiceCode]     =   @spEdServiceCode
          )

IF  ( 
    ISNULL(@reac_ID, 0) != 0  
  )

  SET @saveType = dbo.CONST_SAVE_TYPE_REACTIVATE()

ELSE
  SET @saveType = dbo.CONST_SAVE_TYPE_NEW()

   
BEGIN TRANSACTION    
SET @TranOpen = 1    



IF (@saveType = dbo.CONST_SAVE_TYPE_NEW()  )    
BEGIN    

  insert into dbo.PRACTITIONER_PREFERENCE_SPED_SERVICES (

    [clientID]
	, [pracID]
	, [disciplineGroupID]
	, [spEdServiceCode]

  , created
  , createdBy
  )                            
  values (

      @clientID
    , @pracID
    , @disciplineGroupID
    , @spEdServiceCode

    , @today
    , @userID

  )
    
  set @recordID = SCOPE_IDENTITY()    

END

ELSE IF (  @saveType = dbo.CONST_SAVE_TYPE_REACTIVATE()  ) 
BEGIN
  UPDATE  dbo.PRACTITIONER_PREFERENCE_SPED_SERVICES
     SET  active = 1
     WHERE id = @reac_ID
END

/*
ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT()) 
BEGIN

  update ..
  set
      ...

  where (ID = @recordID)

END
*/

ELSE
BEGIN
  RAISERROR ('Unknown save type', 11, 1)  
END
                                
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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PREFERENCE_SPED_SERVICE_SAVE_OR_REPLACE] TO [webuser]
GO
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_SAVE_REACTIVATE_PRAC_OR_PAT_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.RECURRING_SERVICES_SAVE_REACTIVATE_PRAC_OR_PAT_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[RECURRING_SERVICES_SAVE_REACTIVATE_PRAC_OR_PAT_CORE]    
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @validateRec   BIT,
  @clientID      INT,    
  @pracIDsStr    VARCHAR(8000),
  @patID         BIGINT)    
AS    
BEGIN    
   
/***************************************************************************    
 * RECURRING_SERVICES_SAVE_REACTIVATE_PRAC_OR_PAT_CORE */    
/**    
 * Reactivates prac or patient record on save if neccessary
 ***************************************************************************/        

SET NOCOUNT ON    
      
declare @editDelReason as VARCHAR(7000)    
declare @MsgNoRec      as VARCHAR(1000)    
declare @MsgNoEdit     as VARCHAR(1000) 
declare @spDetails     as VARCHAR(8000)    
declare @recordID      as bigint
DECLARE @pracIDs       as TABLE (id int, recid bigint)
declare @curID         as int
declare @maxID         as int
declare @pracID        as bigint

BEGIN TRY    

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
   
/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    

if (@userGroup = dbo.CONST_USER_GROUP_SBS())
BEGIN

  set @editDelReason = 'Received work for practitioner or patient'
  set @MsgNoEdit     = 'Cannot edit'
  set @MsgNoRec      = 'No record found'
  
  /*-------------------------------    
   * Get list of pracs
   *------------------------------*/

  insert into @pracIDs select * from dbo.MULTI_RECORD_ID_PARSE(@pracIDsStr,',')
  
  /*-------------------------------    
   * Reactivate practitioner if
   * the practitioner is not active
   *------------------------------*/
  
  select @curID = 1
  select @maxID = MAX(id)from @pracIds 
 
  while (@curID <= @maxID)
  begin
  
    select top 1 @pracID = recid from @pracIDs where id = @curID
  
    exec dbo.PRACTITIONERS_Undelete_Core 
         @userID
       , @userGroup
       , @userRank 
       , @editDelReason
       , @validateRec
       , @clientID
       , @pracID
       , @MsgNoRec
       , @MsgNoEdit
       , @spDetails OUTPUT
       , @recordID  OUTPUT    
  
    set @curID = @curID + 1
    --if (@curID > 1000) break
  end  
  
  /*-------------------------------    
   * Reactivate patient if
   * the patient is not active
   *------------------------------*/
  
  exec dbo.PATIENTS_Undelete_Core 
    @userID
  , @userGroup
  , @userRank 
  , @editDelReason
  , @validateRec
  , @clientID
  , @patID
  , @MsgNoRec
  , @MsgNoEdit
  , @spDetails OUTPUT
  , @recordID  OUTPUT    

END
     
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

GRANT EXECUTE ON  [dbo].[RECURRING_SERVICES_SAVE_REACTIVATE_PRAC_OR_PAT_CORE] TO [webuser]
GO

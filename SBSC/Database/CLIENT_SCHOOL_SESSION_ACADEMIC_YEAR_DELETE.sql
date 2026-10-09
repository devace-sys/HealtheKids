USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_DELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_DELETE] (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
  , @clientID      BIGINT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT  
  , @recID         INT
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_DELETE */    
/**    
 * Delete record and manages any associated records.    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @tranOpen     AS BIT    
DECLARE @today        AS DATETIME

/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    

set @recordID   = 0    
set @spDetails  = ''    

/*-------------------------------    
 * Init other vars
 *------------------------------*/    

set @tranOpen = 0
set @today      = GETDATE()    
   
BEGIN TRY    
   
    
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)    
   
declare @numRelatedBreaks      as int = 0

/*-------------------------------    
 * See if there are currently any
 * active breaks associated with
 * this school year.
 *------------------------------*/    

select 
    @numRelatedBreaks = count(ssb.id) 
from [dbo].[CLIENT_SCHOOL_SESSION_BREAKS] as ssb
where (
        (ssb.clientID       = @clientID) 
  and (ssb.academicYearID   = @recID)
  and (ssb.active           = 1)  
)

/*-------------------------------    
 * If so then let user know and
 * get out
 *------------------------------*/    

if (@numRelatedBreaks > 0)
begin
  RAISERROR ('There are breaks associated with this school year.  Please delete or reassociate these breaks with another school year before deleting this school year.', 11, 1)
end

/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
   
BEGIN TRANSACTION    
   
  /*-------------------------------    
   * Write changes to the data    
   *------------------------------*/    
   
  set @TranOpen = 1    
  set @recordID = @recID
  
  update dbo.[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS]
  set 
      active            = 0
    , lastModified      = @today
    , lastModifiedBy    = @userID
  where ( 
         ([id]    = @recID)
    and (clientID = @clientID)  /* Ensures that client users can only update their own recs */
  )

  /*-------------------------------    
   * If we reach this point    
   * everything is OK, commit our    
   * changes and exit    
   *------------------------------*/    
     
COMMIT TRANSACTION    
set @tranOpen = 0    
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
      
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_DELETE] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONER_PATIENT_GROUPS_Delete') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITONER_PATIENT_GROUPS_Delete
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PRACTITONER_PATIENT_GROUPS_Delete]    
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),
  @clientID      INT,
  @pracID        INT,
  @endDate       DATETIME,    
  @validateRec   BIT,
  @recID         INT,    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITONER_PATIENT_GROUPS_Delete */    
/**    
 * Deletes (hides) an existing Patients record    
 * and manages any associated records.    
 *    
 * @param   userID          The userid of who saved the record   
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT deleting the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng Patient to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message for edit/delete service record    
 *                          operations when record is not found    
 * @param   MsgNoEdit       Desired error message for edit/delete service record    
 *                          operations if the service record cannot be edited or    
 *                          deleted    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @TranOpen      AS BIT    
DECLARE @tempRecID     AS INT               -- Used for determining if a rec exists    
DECLARE @today         AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID    AS BIGINT            -- Audit record id    
DECLARE @recUserID     AS BIGINT            -- Associated user id   
DECLARE @canEdit       AS BIT    
DECLARE @saveType      AS INT    
DECLARE @svcSchCount   AS INT
DECLARE @startDate     as DATETIME
DECLARE @minEffDate    as DATETIME
DECLARE @maxEffDate    as DATETIME
DECLARE @deleteRecord  as bit
DECLARE @updateState   as SMALLINT

DECLARE @pracPatDatesRecID as BIGINT

BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType     = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID     = 0    
SET @spDetails    = ''    
SET @today        = GETDATE()    
SET @updateState  = dbo.CONST_REC_STATE_DEL()
SET @deleteRecord = 0

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',       11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',        11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',      11, 1)
IF (@endDate     IS NULL) RAISERROR ('End date is required',        11, 1)     
IF (@recID       IS NULL) RAISERROR ('updateRecID is required',     11, 1)    
   
/*-------------------------------    
 * Fetch record in order to
 * populate id fields required
 * to determine min/max service
 * dates
 *------------------------------*/         
 
select 
  
  @recordID          = ID, 
  @startDate         = dbo.DATE_ONLY(startDate),
  @canEdit           = active

from PRACTITIONER_PATIENT_TREATMENT_GROUPS 
where 
       (id = @recID)
   and ((@clientID is null) or (clientID = @clientID))
   and ((@pracID   is null) or (pracID   = @pracID))
   
/*-------------------------------    
 * Get out if we can't find the
 * record
 *------------------------------*/         

IF (@recordID IS NULL)
  RAISERROR (@MsgNoRec, 11, 1)       

/*-------------------------------    
 * Get out if we are not allowed
 * to edit this record
 *------------------------------*/         
     
if (@canEdit = 0)
  RAISERROR (@MsgNoEdit, 11, 1)       
   
/*-------------------------------    
 * Strip time component from
 * date
 *------------------------------*/         

set @endDate = dbo.DATE_ONLY(@endDate)

/*-------------------------------    
 * Determine min and max
 * effective dates
 *------------------------------*/         

set @svcSchCount = 0

select @minEffDate  = MIN(effectiveDate), 
       @maxEffDate  = MAX(effectiveDate), 
       @svcSchCount = COUNT(id)       
from PRACTITIONER_PATIENT_TREATMENT_GROUP_SERVICE_SCHEDULE 
WHERE treatmentGroupID = @recID

/*-------------------------------    
 * If there are no records this
 * is a problem!
 *------------------------------*/         

IF (@svcSchCount = 0)
  RAISERROR ('Data Error', 11, 1)       

/*-------------------------------    
 * Create message for date we
 * expect to see
 *------------------------------*/         

declare @msgEndDateMustBe as varchar(1000)
set @msgEndDateMustBe = 'End date must be ' + dbo.RPT_DATE_FMT(@maxEffDate) + ' or later'

/*-------------------------------    
 * Test the end date
 *------------------------------*/         

if (@startDate > @endDate)
  RAISERROR (@msgEndDateMustBe, 11, 1) 
  
if (@minEffDate > @endDate)
  RAISERROR (@msgEndDateMustBe, 11, 1) 

if @maxEffDate > @endDate
  RAISERROR (@msgEndDateMustBe, 11, 1) 

/*-------------------------------    
 * If the start date and end date
 * are the same value we want
 * to actually delete the record
 *------------------------------*/    

if (@startDate = @endDate)
  set @deleteRecord = 1

/*-------------------------------    
 * Advisement validation
 *------------------------------*/    
     
IF (@validateRec = 1)
BEGIN 
  if (@deleteRecord = 1)
  begin
    declare @msgDelete as varchar(1000) = 'You will be permanently deleting this group!'
    SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,@msgDelete,dbo.CONST_RET_WARN()) 
  end
  
  RETURN(0)    
END

/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
      
  /*-------------------------------    
   * Deactivate record and set
   * end date
   *------------------------------*/    
  
  if (@deleteRecord = 0)
  begin
  
    UPDATE dbo.PRACTITIONER_PATIENT_TREATMENT_GROUPS
    SET 
      ACTIVE           = 0,
      endDate          = @endDate,
      lastUpdatedBy    = @userID,
      lastUpdated      = @today
    WHERE
      ID = @recID
    
    SET @recordID = @recID
  end
  else 
  begin
  
    DELETE dbo.PRACTITIONER_PATIENT_TREATMENT_GROUP_SERVICE_SCHEDULE 
    WHERE treatmentGroupID = @recID
    
    DELETE dbo.PRACTITIONER_PATIENT_TREATMENT_GROUPS                 
    WHERE ID = @recID
  
  end
     
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
       
  EXEC PRACTITIONER_PATIENT_GROUP_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
      
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

GRANT EXECUTE ON  [dbo].[PRACTITONER_PATIENT_GROUPS_Delete] TO [webuser]
GO

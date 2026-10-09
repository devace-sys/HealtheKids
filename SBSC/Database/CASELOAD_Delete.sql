USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CASELOAD_Delete') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CASELOAD_Delete
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CASELOAD_Delete]    
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
 * CASELOAD_Delete */    
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
   
DECLARE @TranOpen     AS BIT    
DECLARE @tempRecID    AS INT               -- Used for determining if a rec exists    
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @recUserID    AS BIGINT            -- Associated user id   
DECLARE @canEdit      AS BIT    
DECLARE @saveType     AS INT    
DECLARE @refClientID  AS INT
DECLARE @refPracID    as INT
DECLARE @refPatID     as INT
DECLARE @tempStartDate as DATETIME
DECLARE @tempEndDate   as DATETIME
DECLARE @tempRecCount  as INT
DECLARE @startDate     as DATETIME
DECLARE @testDate      as DATETIME  
DECLARE @updateState   as SMALLINT
DECLARE @pracPatDatesRecID as BIGINT

BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType    = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID    = 0    
SET @spDetails   = ''    
SET @today       = GETDATE()    
SET @updateState = dbo.CONST_REC_STATE_DEL()

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)    
IF (@endDate     IS NULL) RAISERROR ('End date is required', 11, 1) 
   
/*-------------------------------    
 * Fetch record in order to
 * populate id fields required
 * to determine min/max service
 * dates
 *------------------------------*/         
 
select 
  @recordID          = ID,
  @refClientID       = clientID,
  @refPracID         = pracID,
  @refPatID          = patid,
  @pracPatDatesRecID = pracPatDateID,
  @startDate         = dbo.DATE_ONLY(startDate)
from dbo.CASELOAD_VIEW(@userID, @userGroup, @userRank, @clientID, @pracID, 1, @recID)

/*-------------------------------    
 * Get out if we can't find the
 * record
 *------------------------------*/         

IF (@recordID IS NULL)
  RAISERROR (@MsgNoRec, 11, 1)       

/*-------------------------------    
 * Test start and end date range
 *------------------------------*/    

if (@startDate > @endDate)
  RAISERROR ('End date is before start date.', 11, 1)  
  
/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) 
  RETURN(0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
      
  /*-------------------------------    
   * Deactivate record
   *------------------------------*/    
       
  UPDATE dbo.PRACTITIONER_PATIENTS
  SET 
    ACTIVE           = 0,
    LAST_MODIFIED_BY = @userID,
    LAST_MODIFIED_ON = @today
  WHERE
    ID = @recID
    
  /*-------------------------------    
   * Update prac patient dates
   * with an end date
   *------------------------------*/    
  
  UPDATE dbo.PRACTITIONER_PATIENTS_DATES
  SET 
    END_DATE = @endDate
  WHERE 
    ID = @pracPatDatesRecID
         
  SET @recordID = @recID      

  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
       
  EXEC CASELOAD_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
        
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

GRANT EXECUTE ON  [dbo].[CASELOAD_Delete] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_OpEnd') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.RECURRING_SERVICES_OpEnd
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[RECURRING_SERVICES_OpEnd]    
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @clientID      INT,  
  @effectiveDate DATETIME,
  @recID         INT,    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN    
   
/***************************************************************************    
 * RECURRING_SERVICES_OpEnd */    
/**    
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
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @recUserID    AS BIGINT            -- Associated user id   
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    
DECLARE @startDate    AS DATETIME
DECLARE @endDate      AS DATETIME
DECLARE @fiscalYearID AS BIGINT
DECLARE @fyStartDate  AS DATETIME
DECLARE @fyEndDate    AS DATETIME
   
BEGIN TRY    

/*============================================================
 * Init
 *============================================================*/     
   
SET @recordID    = 0    
SET @spDetails   = ''    
SET @today       = GETDATE()    
SET @saveType    = dbo.CONST_SAVE_TYPE_EDIT()
SET @updateState = dbo.CONST_REC_STATE_MOD()   

/*============================================================
 * Verify required parameters are passed
 *============================================================*/     
   
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',      11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',       11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',     11, 1)    
IF (@recID         IS NULL) RAISERROR ('updateRecID is required',    11, 1)    
IF (@effectiveDate IS NULL) RAISERROR ('Effective date is required', 11, 1)

/*============================================================
 * Look up existing record
 *============================================================*/ 
 
 select 
    @recordID     = id, 
    @startDate    = startDate,
    @endDate      = endDate,
    @fiscalYearID = fiscalYearID
 from RECURRING_SERVICES 
 where (id = @recID)

/*============================================================
 * Look up fiscal year data
 *============================================================*/ 

SELECT
  @fyStartDate = startDate,
  @fyEndDate   = endDate
FROM CLIENT_ATTENDANCE_YEARS_VIEW(@userID,@userGroup,@userRank,null,null) 
where (id = @fiscalYearID)


/*============================================================
 * Check to make sure effective date is valid
 *============================================================*/ 

if (datediff(day, @fyStartDate,   @effectiveDate) < 0) RAISERROR ('Effective date cannot be before the start of the school year', 11, 1)
if (datediff(day, @fyEndDate,     @effectiveDate) > 0) RAISERROR ('Effective date cannot be after the end of the school year',    11, 1)
if (datediff(day, @startDate,     @effectiveDate) < 0) RAISERROR ('Effective date cannot be before the start date',               11, 1)

IF (@validateRec = 1) RETURN(0)    
      

/*============================================================
 * Peform update
 *============================================================*/ 
 
BEGIN TRANSACTION    
   
  SET @TranOpen = 1            
     
  /*============================================================
   * "End" the recurring service record
   *============================================================*/  

  UPDATE RECURRING_SERVICES
  SET
    endDate       = @effectiveDate,
    lastUpdated   = @today,
    lastUpdatedBy = @userID    
  WHERE id = @recID

  /*============================================================
   * Create audit record
   *============================================================*/  

  EXEC RECURRING_SERVICES_Audit @recID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT

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
   
  --SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RECURRING_SERVICES_OpEnd] TO [webuser]
GO

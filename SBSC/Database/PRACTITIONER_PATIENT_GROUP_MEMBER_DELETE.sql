USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_GROUP_MEMBER_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_GROUP_MEMBER_DELETE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_GROUP_MEMBER_DELETE]     
 (@userID         BIGINT,    
  @userGroup      INT,    
  @userRank       INT,    
  @editDelReason VARCHAR(7000),
  @clientID       BIGINT,    
  @pracID         BIGINT,
  @pracPatGroupID BIGINT,  
  @patID          BIGINT,  
  @validateRec   BIT,
  @recID         BIGINT,    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * PRACTITIONER_PATIENT_GROUP_MEMBER_DELETE */    
/**    
 * Creates a new caseload record or edits an exiting one
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   pracID          Practitioner id
 * @param   patID           Patient id
 * @param   minsInd
 * @param   minsGrp
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

   
DECLARE @TranOpen      AS BIT    
DECLARE @tempRecID     AS INT               -- Used for determining if a rec exists    
DECLARE @today         AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID    AS BIGINT            -- Audit record id    
DECLARE @recUserID     AS BIGINT            -- Associated user id   
DECLARE @canEdit       AS BIT    
DECLARE @saveType      AS INT    
DECLARE @updateState   as SMALLINT
DECLARE @recCount      AS INT

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType     = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID     = 0    
SET @spDetails    = ''    
SET @today        = GETDATE()    
SET @updateState  = dbo.CONST_REC_STATE_DEL()

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',       11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',        11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',      11, 1)

select top 1 
  @recordID = ppgm.id
from dbo.PRACTITIONER_PATIENT_GROUP        as ppg
join dbo.PRACTITIONER_PATIENT_GROUP_MEMBER as ppgm on ppgm.pracPatGroupID = ppg.id
where(
       (ppg.clientID  = @clientID) 
   and (ppg.pracID    = @pracID) 
   and (ppgm.patID    = @patID))

if @recordID is null 
begin
  set @recordID = 0 
end


/*-------------------------------    
 * Create or modify our     
 * caseload records
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
  
  delete PRACTITIONER_PATIENT_GROUP_MEMBER
  where id in (
    select 
      ppgm.id 
    from dbo.PRACTITIONER_PATIENT_GROUP        as ppg
    join dbo.PRACTITIONER_PATIENT_GROUP_MEMBER as ppgm on ppgm.pracPatGroupID = ppg.id
    where 
          ppg.clientID = @clientID
      and ppg.pracID   = @pracID
      and ppg.id       = @pracPatGroupID
      and ppgm.patID   = @patID
  )

  -- Delete related scheduled services first
  DELETE FROM dbo.Practitioner_Patient_Scheduled_Services
  WHERE clientID      = @clientID
    AND pracID        = @pracID
    AND caseloadGrpID = @pracPatGroupID
    AND patID         = @patID;

     
 /*-------------------------------    
  * Create audit record    
  *------------------------------*/    
       
 --EXEC CASELOAD_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
 
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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_GROUP_MEMBER_DELETE] TO [webuser]
GO

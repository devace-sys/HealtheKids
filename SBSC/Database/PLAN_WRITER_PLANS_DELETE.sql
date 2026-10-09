USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_Delete') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PLAN_WRITER_PLANS_Delete
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[PLAN_WRITER_PLANS_Delete]    
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),
  @clientID            BIGINT,
  @groupSvcClassNameID bigint,    
  @validateRec   BIT,
  @recID         INT,    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN    
 
/***************************************************************************    
 * PLAN_WRITER_PLANS_Delete */    
/**    
 * Deletes or deactivates record
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
DECLARE @canEdit      AS BIT    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS SMALLINT
DECLARE @requestID    AS BIGINT
DECLARE @requestIDOut  AS BIGINT
DECLARE @spDetailsAuth AS VARCHAR(8000)
 
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
 
/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
 
select top 1 
  @recordID = ID
from dbo.PLAN_WRITER_PLANS
where (
      (ID                               = @recID) 
  and (CLIENT_ID                        = @clientID) 
)

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
 
  UPDATE dbo.PLAN_WRITER_PLANS
  SET 
    ACTIVE           = 0,
    LAST_MODIFIED_BY = @userID,
    LAST_MODIFIED_ON = @today
  WHERE
    (ID = @recordID)
 
  /*-------------------------------    
   * Delete authorization data if any    
   *------------------------------*/    
 
  /*============================================================
	* Find the request
	* Note: Request needs to be open and active
	*============================================================*/  

	select top 1

		@requestID                     = sar.id	  

	from dbo.SERVICE_AUTHORIZATION_REQUESTS as sar
	where (
		  (sar.referencedEntityID = @recordID)
	  and (sar.svcAuthorizationRequestTypeID = 4)
	  and (sar.closed  = 0)
	  and (sar.active  = 1)
	)

	if (@requestID is not null)
	begin
		exec [dbo].[SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE]
			@userID       
		  , @userGroup    
		  , @userRank     
		  , @editDelReason
		  , 0  
		  , @requestID        
		  , ''     
		  , ''    
		  , @requestIDOut    OUTPUT    
		  , @spDetailsAuth   OUTPUT 
	end 

	set @spDetails = isnull(@spDetails,'') + isnull(@spDetailsAuth, '')
 
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
 
GRANT EXECUTE ON  [dbo].[PLAN_WRITER_PLANS_Delete] TO [webuser]
GO
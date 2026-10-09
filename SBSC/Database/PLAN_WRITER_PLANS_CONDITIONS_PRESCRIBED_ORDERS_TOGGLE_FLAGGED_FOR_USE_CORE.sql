USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_TOGGLE_FLAGGED_FOR_USE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_TOGGLE_FLAGGED_FOR_USE_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_TOGGLE_FLAGGED_FOR_USE_CORE] (
  @userID              BIGINT,
  @userGroup           INT,
  @userRank            INT, 
  @clientID            BIGINT,
  @groupSvcClassNameID bigint,
  @planID              bigint,
  @conditionID         bigint,
  @editDelReason	   VARCHAR(7000),
  @validateRec		   BIT,      
  @recID			   INT,    
  @MsgNoRec			   VARCHAR(1000),    
  @MsgNoEdit		   VARCHAR(1000), 
  @spDetails		   VARCHAR(8000) OUTPUT,    
  @recordID			   BIGINT        OUTPUT)
AS    
BEGIN     
 
/***************************************************************************    
 * PLAN_WRITER_PLANS_SAVE_CORE */    
/**    
 * Creates a new 
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 
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
 
DECLARE @auditRecID          AS BIGINT
DECLARE @today               as DATETIME
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in
DECLARE @planConditionID     AS BIGINT
DECLARE @idx                 AS BIGINT    

BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @spDetails  = ''    
SET @recordID = NULL 
SET @today    = GETDATE()
  
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
 
IF (@userID      IS NULL) RAISERROR ('userID is required',   11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
 
set @idx             = null
set @planConditionID = null

/*============================================================
 * Search for condition record.
 * Note: This is also our sanity/security check
 *============================================================*/ 
  
 if (@conditionID is not null)
 begin
	select top 1
	  @planConditionID = ID  
	from dbo.PLAN_WRITER_PLANS_CONDITIONS as t1
	where (
		  (t1.CLIENT_ID    = @clientID)
	  and (t1.PLAN_ID      = @planID)
	  and (t1.CONDITION_ID = @conditionID)
	  and (t1.ACTIVE       = 1)
	)

	IF (@planConditionID IS NULL) RAISERROR ('Record not found', 11, 1)  
end  

/*============================================================
 * Search for diagnosis flag record.
 *============================================================*/  

select top 1 
  @idx = ID 
from dbo.PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_FLAGGED_FOR_USE as t1
where (
      (t1.PLAN_ID                     = @planID)
  and (t1.PLAN_CONDITION_ID           = @planConditionID) 
  and (t1.PRESCRIBED_ORDER_ID         = @recID)
)

/*============================================================
 * Validation exit
 *============================================================*/  
  
IF (@validateRec = 1) 
BEGIN    
  set @recordID = @idx  
  RETURN(0)    
END               
 
/*============================================================
 * Make our changes
 *============================================================*/     
 
/*============================================================
* Flag for use
* Record was not found so we need to add one  
*============================================================*/  
 
 IF (@idx is null)
 BEGIN      

    insert into dbo.PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_FLAGGED_FOR_USE (
        PLAN_ID
      , PLAN_CONDITION_ID
      , PRESCRIBED_ORDER_ID
    )
    values (
        @planID
      , @planConditionID
      , @recID
    )   

    SET @idx = SCOPE_IDENTITY()
 END
 ELSE

 /*============================================================
  * Remove flag for use
  * Record was found so we need to remove it
  *============================================================*/  
 
 BEGIN
  
   delete dbo.PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_FLAGGED_FOR_USE where (ID = @idx)  

 END
 
 set @recordID = @idx
 
 /*-------------------------------    
  * Create audit record    
  *------------------------------*/    
 
 --EXEC Noun_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
   
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
   
  -- Only send really bad exceptions back with sp details

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
 
GRANT EXECUTE ON  [dbo].[PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_TOGGLE_FLAGGED_FOR_USE_CORE] TO [webuser]
GO
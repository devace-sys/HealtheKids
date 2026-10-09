USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
                                                                      
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE                   
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
                        
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE]     
 (@userID             BIGINT,    
  @userGroup          INT,    
  @userRank           INT,    
  @clientID           BIGINT,    
  @transMgmtID        BIGINT,
  @routeID            BIGINT,
  @patID              BIGINT,  
  @origPlaceID        varchar(255),
  @destPlaceID        varchar(255),
  @weekDaysJSON       varchar(max),
  @selectAmPm         varchar(256),
  @editDelReason      VARCHAR(7000),
  @validateRec        BIT,
  @saveType           INT,    
  @recID              INT,    /* Note: Not used.  */
  @MsgNoRec           VARCHAR(1000),
  @MsgNoEdit          VARCHAR(1000), 
  @MsgDupRec          VARCHAR(1000),     
  @MsgDataError       VARCHAR(1000),
  @MsgNotActive       VARCHAR(1000),     
  @spDetails          VARCHAR(8000) OUTPUT,    
  @recordID           BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE */    
/**    
 * Creates a new record or edits an exiting one
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   transMgmtID     Mgmt id

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

DECLARE @TranOpen            AS BIT  

BEGIN TRY    

/*-------------------------------    
 * Create or modify our     
 * records
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
        
  /*-------------------------------    
   * Call the core SPROC
   *------------------------------*/ 

   exec dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_CORE
          @userID       
		, @userGroup    
		, @userRank     
		, @clientID     
		, @transMgmtID  
		, @routeID      
		, @patID        
		, @origPlaceID  
		, @destPlaceID 
		, @weekDaysJSON 
		, @selectAmPm
		, @editDelReason
		, @validateRec  
		, @saveType     
		, @recID        
		, @MsgNoRec     
		, @MsgNoEdit    
		, @MsgDupRec    
		, @MsgDataError 
		, @MsgNotActive 
		, @spDetails     OUTPUT
		, @recordID      OUTPUT
 
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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE] TO [webuser]
GO


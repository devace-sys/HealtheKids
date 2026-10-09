USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_DELETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_DELETE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_DELETE]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @clientID      BIGINT,    
  @transMgmtID   BIGINT,
  @patID         BIGINT,
  @routeID       BIGINT,
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @recID         INT,    
  @MsgNoRec      VARCHAR(1000),
  @MsgNoEdit     VARCHAR(1000), 
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_DELETE */    
/**    
 * Deletes existing record
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   transMgmtID     Mgmt id
 * @param   patID           Patient id
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
DECLARE @recCount            AS INT
DECLARE @today               as DATETIME
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in    
DECLARE @auditRecID          AS BIGINT
DECLARE @saveType            AS INT    
declare @transMgmtAuthPatID  as bigint

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @spDetails  = ''    
SET @recordID     = 0    

/*-------------------------------    
 * Init 
 *------------------------------*/    
   
SET @saveType     = dbo.CONST_SAVE_TYPE_DELETE()    
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


/*-------------------------------    
 * Make sure patient is in 
 * auth list and get auth rec id
 *------------------------------*/    

set @transMgmtAuthPatID = null

select top 1 

  @transMgmtAuthPatID = transMgmtAuthPatID 

from dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW_CORE (  @userID
                                                            , @userGroup
                                                            , @userRank
                                                            , @clientID
                                                            , @transMgmtID
                                                            , @patID
                                                            , 1
                                                            , null)

if (@transMgmtAuthPatID is null) RAISERROR ('Patient is not on authorized list', 11, 1) 


/*-------------------------------    
 * Make sure route is OK
 *------------------------------*/    

set @recordID = null     

select top 1
  @recordID = id
from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW (  @userID
                                                     , @userGroup
                                                     , @userRank
                                                     , @clientID
                                                     , @transMgmtID
                                                     , 1
                                                     , @routeID )

if (@recordID is null) RAISERROR ('Route does not exist', 11, 1) 

/*-------------------------------    
 * Find patient on member list
 *------------------------------*/    

set @recordID = null     

select top 1 

  @recordID = transMgmtAuthRouteMemberID

from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW ( @userID
                                                           , @userGroup
                                                           , @userRank
                                                           , @clientID
                                                           , @transMgmtID
                                                           , @patID
                                                           , @transMgmtAuthPatID
                                                           , @routeID
                                                           , 1
                                                           , null )

if (@recordID is null) 
begin
  set @recordID = 0 
  return(0)
end

/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1
  
  
  update dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS   
  set 
     LAST_MODIFIED_BY    = @userID
   , LAST_MODIFIED_ON    = @today
   , ACTIVE              =  0  
  where ((ID = @recordID) and (ACTIVE = 1))
             
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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_DELETE] TO [webuser]
GO


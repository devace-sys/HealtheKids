USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
                                                                      
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_DISPLAY_ORDER') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_DISPLAY_ORDER                   
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
                        
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_DISPLAY_ORDER]     
 (@userID              BIGINT,    
  @userGroup           INT,    
  @userRank            INT,    
  @clientID            BIGINT,    
  @transMgmtID         BIGINT,
  @routeID             BIGINT,
  @membersDisplayOrder varchar(8000),  
  @editDelReason       VARCHAR(7000),
  @validateRec         BIT,
  @saveType            INT,    
  @recID               INT,    /* Note: Not used.  @patID is used to find */
  @MsgNoRec            VARCHAR(1000),
  @MsgNoEdit           VARCHAR(1000), 
  @MsgDupRec           VARCHAR(1000),     
  @MsgDataError        VARCHAR(1000),
  @MsgNotActive        VARCHAR(1000),     
  @spDetails           VARCHAR(8000) OUTPUT,    
  @recordID            BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_DISPLAY_ORDER */    
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
DECLARE @recCount            AS INT
DECLARE @today               as DATETIME
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in    

declare @memberOrderRecs as table (    
    idx      int
  , patID    bigint
  , memberID bigint
)          

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @spDetails  = ''    
SET @recordID   = 0 
SET @today      = GETDATE()

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
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*-------------------------------    
 * Parse
 *------------------------------*/    

insert into @memberOrderRecs
select 
   idx      = id
 , patID    = recid
 , memberID = null
from dbo.MULTI_RECORD_ID_PARSE (@membersDisplayOrder,',')

/*-------------------------------    
 * Get member data to update
 *------------------------------*/    

update t1
  set t1.memberID = t2.id
from @memberOrderRecs                                 as t1
join dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS as t2 on t2.PATIENT_ID = t1.patID
where (
        (t2.CLIENT_ID                       = @clientID) 
    and (t2.ROUTE_ID                        = @routeID)
    and (t2.TRANSPORTATION_MGMT_ID       = @transMgmtID)
    and (t2.ACTIVE                          = 1)
    and (t2.PATIENT_ID                      = t1.patID)      
)

/*-------------------------------
 * Validation
 *------------------------------*/
        
IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        

/*-------------------------------    
 * Create or modify our     
 * records
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
        
  /*-------------------------------    
   * Update route members
   *------------------------------*/    

  update dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS 
  set 
      DISPLAY_ORDER = t2.idx
    , LAST_MODIFIED_BY = @userID
    , LAST_MODIFIED_ON = @today
  from
  (
    select 
       t1.idx
      ,t1.memberID
    from @memberOrderRecs as t1
  )   as t2
  where (t2.memberID = id)
  
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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_DISPLAY_ORDER] TO [webuser]
GO


USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_SAVE_CORE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_SAVE_CORE]
 (  @userID        BIGINT
  , @userGroup     INT  
  , @userRank      INT    
  , @sheeetBatchID BIGINT
  , @clientID      BIGINT
  , @transMgmtID   BIGINT
  , @routeID       BIGINT
  , @startDate     DATE
  , @refDate       DATE
  , @monDate       DATE
  , @tueDate       DATE
  , @wedDate       DATE
  , @thuDate       DATE
  , @friDate       DATE
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT    
  , @recID         INT    
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000) 
  , @MsgDupRec     VARCHAR(1000)     
  , @MsgDataError  VARCHAR(1000)
  , @MsgNotActive  VARCHAR(1000)     
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_ROUTE_SHEET_SAVE_CORE */    
/**    
 * Creates a new record or edits an exiting one
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   transMgmtID     Mgmt id
 * @param   name            Name of the route
 * @param   busNumber       Bus number
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

DECLARE @recCount            AS INT
DECLARE @today               as DATETIME
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in    

DECLARE @name           as varchar(500)
DECLARE @busNumber      as varchar(50)
DECLARE @displayOrder   as int
DECLARE @sheetID        as bigint
DECLARE @sheetCode      as varchar(512)

DECLARE @origName       as varchar(1000)
DECLARE @origAddress    as varchar(2000)
DECLARE @origPlaceID    as varchar(1000)

DECLARE @destName       as varchar(1000)
DECLARE @destAddress    as varchar(2000)
DECLARE @destPlaceID    as varchar(1000)

DECLARE @distanceMiles  as decimal(7,1)  

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
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*-------------------------------    
 * Verify client, practitioner,
 * and patient ids
 *------------------------------*/   

SET @recCount = null


/*-------------------------------    
 * Validation    
 *------------------------------*/    
        
IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        

/*-------------------------------    
 * Get route data
 *------------------------------*/    
    
select top 1 
    @name          = name
  , @busNumber     = busNumber
  , @origName      = origName
  , @origAddress   = origAddress 
  , @origPlaceID   = origPlaceID
  , @destName      = destName 
  , @destAddress   = destAddress
  , @destPlaceID   = destPlaceID 
  , @distanceMiles = distanceMiles
  , @displayOrder  = null
from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_CORE (
   @userID
 , @userGroup
 , @userRank
 , @clientID
 , @transMgmtID
 , 1
 , @routeID)
 
/*==============================    
 * New Record
 *==============================*/    
  
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN       
  
  insert into dbo.TRANSPORTATION_MGMT_ROUTE_SHEET ( 
      SHEET_BATCH_ID 
    , TRANSPORTATION_MGMT_ID
    , ROUTE_ID
    , CLIENT_ID
    , NAME
    , BUS_NUMBER
    , START_DATE
    , REF_DATE
    , MON_DATE
    , TUE_DATE
    , WED_DATE
    , THU_DATE
    , FRI_DATE
    , SHEET_CODE
    , ORIG_NAME
    , ORIG_ADDRESS
    , ORIG_PLACE_ID
    , DEST_NAME
    , DEST_ADDRESS
    , DEST_PLACE_ID
    , DISTANCE_MILES
    , DISPLAY_ORDER
    , CREATED_BY
    , CREATED_ON
    , ACTIVE
  )
  values (
      @sheeetBatchID
    , @transMgmtID
    , @routeID 
    , @clientID
    , @name
    , @busNumber
    , @startDate
    , @refDate
    , @monDate
    , @tueDate
    , @wedDate
    , @thuDate
    , @friDate
    , null
    , @origName
    , @origAddress
    , @origPlaceID
    , @destName
    , @destAddress
    , @destPlaceID
    , @distanceMiles    
    , @displayOrder
    , @userID
    , @today
    , 1
  )       
        
  set @recordID  = SCOPE_IDENTITY()
  set @sheetID   = @recordID
  set @sheetCode = ''
  
  select @sheetCode = dbo.TRANSPORTATION_MGMT_GENERATE_ROUTE_SHEET_CODE (   @clientID    
                                                                          , @transMgmtID 
                                                                          , @routeID     
                                                                          , @refDate
                                                                          , @sheeetBatchID      
                                                                          , @sheetID )
      
  update dbo.TRANSPORTATION_MGMT_ROUTE_SHEET set SHEET_CODE = @sheetCode where (ID = @sheetID)
  
  insert into dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS (
      ROUTE_SHEET_ID               
    , TRANSPORTATION_MGMT_ID 
    , CLIENT_ID 
    , PATIENT_ID
    , ROUTE_ID
    , MEMBER_ID  
    , TRANSPORTATION_MGMT_AUTH_PAT_ID 
    , ORIG_NAME 
    , ORIG_ADDRESS
    , ORIG_PLACE_ID
    , DEST_NAME    
    , DEST_ADDRESS
    , DEST_PLACE_ID
    , DISTANCE_MILES
    , DISPLAY_ORDER
    , CREATED_BY      
    , CREATED_ON 
    , ACTIVE    
    , MAPS_URL
    , TRIP_ID
    , TRIP_AUDIT_ID
	, DAYS_OF_WEEK_SVC_PROVIDED_JSON
  )  
  select 
      ROUTE_SHEET_ID                   = @sheetID    
    , TRANSPORTATION_MGMT_ID           = transMgmtID
    , CLIENT_ID                        = clientID    
    , PATIENT_ID                       = patID
    , ROUTE_ID                         = routeID
    , MEMBER_ID                        = transMgmtAuthRouteMemberID
    , TRANSPORTATION_MGMT_AUTH_PAT_ID  = transMgmtAuthPatID
    , ORIG_NAME                        = origName
    , ORIG_ADDRESS                     = origAddress
    , ORIG_PLACE_ID                    = origPlaceID
    , DEST_NAME                        = destName
    , DEST_ADDRESS                     = destAddress
    , DEST_PLACE_ID                    = destPlaceID       
    , DISTANCE_MILES                   = distanceMiles
    , DISPLAY_ORDER                    = displayOrder
    , CREATED_BY                       = @userID
    , CREATED_ON                       = @today
    , ACTIVE                           = 1
    , MAPS_URL                         = mapsUrl
    , TRIP_ID                          = tripCalcID
    , TRIP_AUDIT_ID                    = tripsCalcCurrentAuditID
	, DAYS_OF_WEEK_SVC_PROVIDED_JSON   = weekDaysJSON
        
from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW_CORE (
   @userID 
 , @userGroup
 , @userRank
 , @clientID
 , @transMgmtID
 , null
 , null
 , @routeID
 , 1
 , null ) 
 
 END       
  
 /*==============================    
  * Edit Record
  *==============================*/ 
 
 ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
 BEGIN    
     
    
    set @updateState = dbo.CONST_REC_STATE_MOD()
      
    
 END
 ELSE
 BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)             
 END
    
 
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
    
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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_SAVE_CORE] TO [webuser]
GO


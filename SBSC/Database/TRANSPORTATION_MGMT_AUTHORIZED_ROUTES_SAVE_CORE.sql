USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_SAVE_CORE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_SAVE_CORE]     
 (@userID             BIGINT,    
  @userGroup          INT,    
  @userRank           INT,    
  @clientID           BIGINT,    
  @transMgmtID        BIGINT,
  @name               VARCHAR(500),
  @busNumber          VARCHAR(50),
  @origPlaceID        varchar(255),
  @destPlaceID        varchar(255),
  @distanceMiles      decimal(7,1),
  @busDriverID        bigint,  
  @editDelReason      VARCHAR(7000),
  @validateRec        BIT,
  @saveType           INT,    
  @recID              INT,    
  @MsgNoRec           VARCHAR(1000),
  @MsgNoEdit          VARCHAR(1000), 
  @MsgDupRec     VARCHAR(1000),     
  @MsgDataError  VARCHAR(1000),
  @MsgNotActive  VARCHAR(1000),     
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_SAVE_CORE */    
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
 
DECLARE @recCount      AS INT
DECLARE @today         as DATETIME
DECLARE @updateState   AS SMALLINT         -- Indicates what state the record is left in    
DECLARE @auditRecID    AS BIGINT
declare @testID        as bigint
declare @origSiteID    as bigint
declare @destSiteID    as bigint

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

select 
  @recCount = COUNT(cc.CLIENT_ID)  
from dbo.CLIENTS_Client            as cc
join dbo.TRANSPORTATION_MGMT       as tm  on tm.CLIENT_ID        = cc.CLIENT_ID 
where (
        (cc.CLIENT_ID        = @clientID)
    and (tm.ID               = @transMgmtID)
    and (cc.LEA    = 1)                     
    and (tm.ACTIVE = 1)               
)

if (@recCount != 1) RAISERROR ('Invalid client or transportation mgmt not setup', 11, 1) 

/*-------------------------------    
 * See if a record already 
 * exists with the same name
 *------------------------------*/    

set @recordID = null     

select top 1
  @recordID = id
from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES
where (
       (CLIENT_ID              = @clientID)
  and  (TRANSPORTATION_MGMT_ID = @transMgmtID)
  and  (NAME                   = @name)
  and  (ACTIVE                 = 1)
  and ((@recID IS NULL) OR (ID != @recID))
)

if (@recordID is not null) RAISERROR ('An active route with this name already exists', 11, 1) 


/*-------------------------------    
 * Make sure origin is OK
 *------------------------------*/    

if (@origPlaceID is not null)
begin
   set @testID     = null
   set @origSiteID = null
   select top 1 @origSiteID = recid from dbo.PARSE_PLACE_ID_STRING (@origPlaceID) where (id = 3)
   if (@origSiteID is not null)
   begin
     select top 1    
        @testID = id 
      --, @origName    = name
      --, @origAddress = placeAddress
     from dbo.SITE_PLACES_VIEW_CORE(  @userID
                                    , @userGroup
                                    , @userRank
                                    , @clientID
                                    , null
                                    , 1
                                    , null ) spvc
     where (spvc.id = @origSiteID)
   end
   if (@testID is null) RAISERROR ('Invalid origin', 11, 1) 
end

/*-------------------------------    
 * Make sure destination is OK
 *------------------------------*/    

if (@destPlaceID is not null)
begin
   set @testID     = null
   set @destSiteID = null   
   select top 1 @destSiteID = recid from dbo.PARSE_PLACE_ID_STRING (@destPlaceID) where (id = 3)
   if (@destSiteID is not null)
   begin
     select top 1    
        @testID = id 
      --, @destName        = name
      --, @destAddress     = placeAddress
     from dbo.SITE_PLACES_VIEW_CORE(   @userID
                                     , @userGroup
                                     , @userRank
                                     , @clientID
                                     , null
                                     , 1
                                     , null ) spvc
     where (spvc.id = @destSiteID)
   end
   if (@testID is null) RAISERROR ('Invalid destination', 11, 1) 
end

/*-------------------------------    
 * If this is an edit check to
 * see if the record exists
 *------------------------------*/    

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN
 
 set @recordID = null     

  select top 1
    @recordID = id
  from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES
  where (
       (CLIENT_ID              = @clientID)
  and  (TRANSPORTATION_MGMT_ID = @transMgmtID)
  and  (ACTIVE                 = 1)
  and  (ID                     = @recID)      
  )

  if (@recordID is null) RAISERROR ('Record not found', 11, 1) 

END

/*-------------------------------    
 * Validation    
 *------------------------------*/    
        
IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        

/*-------------------------------    
 * Create or modify our records
 *------------------------------*/       
        
  /*==============================    
   * New Record
   *==============================*/    
  
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN       
       
    INSERT INTO dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES (
        TRANSPORTATION_MGMT_ID
      , CLIENT_ID
      , NAME
	 , BUS_NUMBER
      , ORIG_PLACE_ID
      , DEST_PLACE_ID
      , DISTANCE_MILES
	  , BUS_DRIVER_ID
      , CREATED_BY
      , CREATED_ON
      , ACTIVE   
    )        
    VALUES ( 
        @transMgmtID 
      , @clientID
      , @name
	 , @busNumber
      , @origPlaceID  
      , @destPlaceID 
      , @distanceMiles 
	  , @busDriverID
      , @userID
      , @today
      , 1     
    )
      
    SET @recordID = SCOPE_IDENTITY()
                             
 END       
  
 /*==============================    
  * Edit Record
  *==============================*/ 
 
 ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
 BEGIN    
     
    
    set @updateState = dbo.CONST_REC_STATE_MOD()
      
    UPDATE dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES
    set        
        NAME             = @name
	 , BUS_NUMBER       = @busNumber
      , ORIG_PLACE_ID    = @origPlaceID
      , DEST_PLACE_ID    = @destPlaceID
      , DISTANCE_MILES   = @distanceMiles
	  , BUS_DRIVER_ID    = @busDriverID
	 , LAST_MODIFIED_BY = @userID
      , LAST_MODIFIED_ON = @today
          
    where(
          (ID        = @recordID)
      and (CLIENT_ID = @clientID)
      and (TRANSPORTATION_MGMT_ID = @transMgmtID)
    )
    
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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_SAVE_CORE] TO [webuser]
GO


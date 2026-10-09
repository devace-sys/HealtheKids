USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
                                                                      
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_TRIP_CALCULATION_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_TRIP_CALCULATION_Save
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
                        
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_TRIP_CALCULATION_Save]     
 (@userID                BIGINT,    
  @userGroup             INT,    
  @userRank              INT,    
  @clientID              bigint,
  @patID                 bigint,
  @origPlaceID           varchar(255),
  @destPlaceID           varchar(255),
  @distanceMiles         decimal(7,1),
  @distanceMeters        decimal (18,2),
  @mapsUrl               nvarchar(4000),
  @origIn                nvarchar(4000),
  @destIn                nvarchar(4000),
  @origOut               nvarchar(4000),
  @destOut               nvarchar(4000),
  @reqData               nvarchar(max),
  @rspData               nvarchar(max),
  @saveType              INT           OUTPUT,    
  @spDetails             VARCHAR(8000) OUTPUT,    
  @recordID              BIGINT        OUTPUT
)
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_TRIP_CALCULATION_Save */    
/**    
 * Creates a new record or edits an exiting one
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

declare @TranOpen             as bit
declare @today                as datetime
declare @testID               as bigint
declare @tripRecID            as bigint
declare @placeOrigAddress     as varchar(2000)
declare @placeDestAddress     as varchar(2000)
declare @auditID              as bigint

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @recordID   = NULL 
SET @today      = GETDATE()
SET @spDetails  = ''    
set @saveType   = dbo.CONST_SAVE_TYPE_NEW()
set @auditID    = null

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
IF (@origPlaceID IS NULL) RAISERROR ('origin is required',    11, 1)    
IF (@destPlaceID IS NULL) RAISERROR ('destin is required',    11, 1)    

/*-------------------------------    
 * Retrieve origin 
 *-------------------------------*/    

set @testID = null

select top 1
    @testID           = id 
  , @placeOrigAddress = placeAddress
from dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE ( @userID
                                              , @userGroup
                                              , @userRank
                                              , @clientID
                                              , @patID 
                                              , null
                                              , 1
                                              , @origPlaceID
                                              , 1)

if (@testID is null) RAISERROR ('Invalid origin', 11, 1) 

/*-------------------------------    
 * Retrieve destination
 *-------------------------------*/    

set @testID = null

select top 1
    @testID           = id 
  , @placeDestAddress = placeAddress
from dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE ( @userID
                                              , @userGroup
                                              , @userRank
                                              , @clientID
                                              , @patID 
                                              , null
                                              , 1
                                              , @destPlaceID
                                              , 1)

if (@testID is null) RAISERROR ('Invalid destination', 11, 1) 


/*-------------------------------    
 * Retrieve trip calculation
 *-------------------------------*/    

set @tripRecID = null

select top 1   
    @tripRecID  = id
from dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW_CORE (  
   @userID               
 , @userGroup
 , @userRank
 , @origPlaceID
 , @destPlaceID
 , null 
 , null
 , 1
 , null
 , 1
 )

BEGIN TRANSACTION    

SET @TranOpen = 1

/*-------------------------------    
 * If there is no record create
 * a new one
 *-------------------------------*/    

if (@tripRecID is null)
begin

  insert into dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS (
      ORIG_PLACE_ID
    , DEST_PLACE_ID
    , DISTANCE_MILES
    , ORIG_ADDRESS
    , DEST_ADDRESS
    , LAST_UPDATED
    , ACTIVE
    , CLIENT_ID
    , MAPS_URL
   )
   values (
       @origPlaceID
     , @destPlaceID
     , @distanceMiles
     , @placeOrigAddress
     , @placeDestAddress
     , @today
     , 1
     , @clientID
     , @mapsUrl
    )

  set @saveType = dbo.CONST_SAVE_TYPE_NEW()
  set @recordID = SCOPE_IDENTITY()

end

/*-------------------------------    
 * Otherwise update existing
 *-------------------------------*/    

else
begin      

  update dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS
  set 
      ORIG_ADDRESS   = @placeOrigAddress
    , DEST_ADDRESS   = @placeDestAddress
    , DISTANCE_MILES = @distanceMiles
    , MAPS_URL       = @mapsUrl
    , LAST_UPDATED   = @today      
  where ((ORIG_PLACE_ID = @origPlaceID) and (DEST_PLACE_ID = @destPlaceID) and (ID = @tripRecID))

  set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
  set @recordID = @tripRecID

end
  
/*-------------------------------    
 * Capture audit data
 *-------------------------------*/    

insert into dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_DATA (

    TRIP_CALCULATION_ID
  , ORIG_PLACE_ID
  , DEST_PLACE_ID
  , DISTANCE_METERS
  , DISTANCE_MILES
  , MAPS_URL
  , ORIGIN_IN
  , DESTINATION_IN
  , ORIGIN_OUT
  , DESTINATION_OUT
  , REQUEST_RAW_DATA
  , RESPONSE_RAW_DATA
  , CREATED_ON )
  
values (
    
    @recordID
  , @origPlaceID
  , @destPlaceID
  , @distanceMeters
  , @distanceMiles
  , @mapsUrl
  , @origIn
  , @destIn
  , @origOut
  , @destOut
  , @reqData
  , @rspData
  , @today )


set @auditID = SCOPE_IDENTITY()

update dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS
SET 
  CURRENT_AUDIT_ID = @auditID
where (ID = @recordID)

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

IF @tranOpen = 1 ROLLBACK TRANSACTION    
       
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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_TRIP_CALCULATION_Save] TO [webuser]
GO


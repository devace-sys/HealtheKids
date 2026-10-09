USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
                                                                      
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_CORE                   
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
                        
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_CORE]     
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
 
DECLARE @recCount            AS INT
DECLARE @today               as DATETIME
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in    
DECLARE @auditRecID          AS BIGINT
declare @transMgmtAuthPatID  as bigint
declare @testID              as bigint
declare @tripCalcID          as bigint

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
                                                            , null )

if (@transMgmtAuthPatID is null)
begin
	declare @saveTypeForTmap as int = dbo.CONST_SAVE_TYPE_NEW()

	exec TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE
	@userID       
  , @userGroup    
  , @userRank     
  , @clientID     
  , @transMgmtID  
  , @patID        
  , null -- @sitePlaceID  
  , null -- @homePlaceID    
  , @editDelReason
  , @validateRec  
  , @saveTypeForTmap /*@saveType */
  , null --@recID        
  , @MsgNoRec    
  , @MsgNoEdit    
  , @MsgDupRec        
  , @MsgDataError
  , @MsgNotActive     
  , @spDetails          output        
  , @transMgmtAuthPatID output

end

/*-------------------------------    
 * Make sure route is OK
 *------------------------------*/    

set @testID = null

select top 1
  @testID = id
from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW (  @userID
                                                     , @userGroup
                                                     , @userRank
                                                     , @clientID
                                                     , @transMgmtID
                                                     , 1
                                                     , @routeID )

if (@testID is null) RAISERROR ('Route does not exist', 11, 1) 


/*-------------------------------    
 * Make sure origin is OK
 *------------------------------*/    

if (@origPlaceID is not null)
begin
  set @testID = null
  select top 1
      @testID = id     
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
end

/*-------------------------------    
 * Make sure destination is OK
 *------------------------------*/    

if (@destPlaceID is not null)
begin
  set @testID = null
  select top 1
      @testID = id
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
end


/*-------------------------------    
 * Get trip calculation data
 *-------------------------------*/    

if ((@origPlaceID is not null) and (@destPlaceID is not null))
begin
  set @tripCalcID = null
  select top 1 
    @tripCalcID = id
  from dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW_CORE (@userID, @userGroup, @userRank, @origPlaceID, @destPlaceID, null, null, 1, null, 1)
end

/*-------------------------------    
 * See if a record already 
 * exists.  There should only be
 * one active record per patient.
 * 
 * Note: We are retrieving the
 * rec ID that is related to 
 * @patID
 *------------------------------*/    

set @recordID = null     

select top 1 

  @recordID = t1.transMgmtAuthRouteMemberID

from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW ( @userID
                                                           , @userGroup
                                                           , @userRank
                                                           , @clientID
                                                           , @transMgmtID
                                                           , @patID
                                                           , @transMgmtAuthPatID
                                                           , @routeID
                                                           , 1
                                                           , null ) as t1

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN       
  if (@recordID is not null) RAISERROR ('Patient is already a member of the route', 11, 1) 
END

ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN
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
 * Create or modify our     
 * records
 *------------------------------*/       
        
  /*==============================    
   * New Record
   *==============================*/    

  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN       
       
    INSERT INTO dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS (
        TRANSPORTATION_MGMT_ID
      , CLIENT_ID
      , PATIENT_ID
      , ROUTE_ID
      , TRANSPORTATION_MGMT_AUTH_PAT_ID
      , ORIG_PLACE_ID              
      , DEST_PLACE_ID
	  , DAYS_OF_WEEK_SVC_PROVIDED_JSON
	  , AM_PM_SELECTION              
      , CREATED_BY
      , CREATED_ON
      , ACTIVE   
      , TRIP_CALC_ID
    )    
    VALUES ( 
        @transMgmtID 
      , @clientID
      , @patID
      , @routeID
      , @transMgmtAuthPatID
      , @origPlaceID  
      , @destPlaceID
	  , @weekDaysJSON
	  , @selectAmPm  
      , @userID
      , @today
      , 1
      , @tripCalcID
    )
      
    SET @recordID = SCOPE_IDENTITY()
                             
 END       
  
 /*==============================    
  * Edit Record
  *==============================*/ 
 
 ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
 BEGIN    
                            
    /* Update current values */
    
    UPDATE dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS
    set        
        ORIG_PLACE_ID                  = @origPlaceID             
      , DEST_PLACE_ID                  = @destPlaceID 
	  , DAYS_OF_WEEK_SVC_PROVIDED_JSON = @weekDaysJSON
	  , AM_PM_SELECTION                = @selectAmPm            
	  , LAST_MODIFIED_BY               = @userID
      , LAST_MODIFIED_ON               = @today
      , TRIP_CALC_ID                   = @tripCalcID
    where (ID = @recordID)
   
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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_CORE] TO [webuser]
GO


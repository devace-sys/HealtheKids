USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_DUPLICATE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_DUPLICATE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_DUPLICATE]     
 (@userID             BIGINT,    
  @userGroup          INT,    
  @userRank           INT,    
  @clientID           BIGINT,    
  @transMgmtID        BIGINT,
  @routeIDToDuplicate BIGINT,
  @newRouteName       VARCHAR(500),
  @reverseStops       BIT,
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
 * TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_DUPLICATE */    
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

DECLARE @TranOpen        AS BIT
					     
DECLARE @busNumber       AS VARCHAR(50)
DECLARE @origPlaceID     AS VARCHAR(255)
DECLARE @destPlaceID     AS VARCHAR(255)
DECLARE @tempOrigPlaceID AS VARCHAR(255)
DECLARE @tempDestPlaceID AS VARCHAR(255)
DECLARE @distanceMiles   AS DECIMAL(7,1)  
DECLARE @patID           AS BIGINT 
DECLARE @weekDaysJSON    AS VARCHAR(MAX) 
DECLARE @selectAmPm      AS VARCHAR(256)
DECLARE @busDriverID     AS BIGINT

DECLARE @curIdx          AS INT  
DECLARE @maxIdx          AS BIGINT
					     
DECLARE @recordIDMemb    AS BIGINT


BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @spDetails  = ''    
SET @recordID = NULL
SET @recordIDMemb = NULL 

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
  and  (NAME                   = @newRouteName)
  and  (ACTIVE                 = 1)
)

if (@recordID is not null) RAISERROR ('An active route with this name already exists', 11, 1) 

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
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
      
  /*==============================    
   * Retrieve info using routeIDToDuplicate 
   *==============================*/	  
  
   select @busNumber     = BUS_NUMBER
        , @origPlaceID   = ORIG_PLACE_ID
		, @destPlaceID   = DEST_PLACE_ID
		, @distanceMiles = DISTANCE_MILES
		, @busDriverID   = BUS_DRIVER_ID
   from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES
   where ID = @routeIDToDuplicate 

   /*==============================    
   * Reverse source and destination
   * if needed
   *==============================*/	

   if (@reverseStops = 1)
   begin
	
	set @tempOrigPlaceID = @destPlaceID
	set @tempDestPlaceID = @origPlaceID

	set @origPlaceID = @tempOrigPlaceID
	set @destPlaceID = @tempDestPlaceID

   end

  /*==============================    
   * Create a new route
   *==============================*/ 

   exec [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_SAVE_CORE]     
    @userID        
  , @userGroup     
  , @userRank      
  , @clientID      
  , @transMgmtID   
  , @newRouteName          
  , @busNumber     
  , @origPlaceID   
  , @destPlaceID   
  , @distanceMiles 
  , @busDriverID
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


  /*==============================    
   * Create a table variable for
   * the route memebers
   *==============================*/

   DECLARE @duplicateRouteMembers TABLE (
        idx                             BIGINT IDENTITY(1,1)
	  , ID                              BIGINT
      , TRANSPORTATION_MGMT_ID          BIGINT
      , CLIENT_ID                       BIGINT
      , PATIENT_ID                      BIGINT
      , ROUTE_ID                        BIGINT
      , TRANSPORTATION_MGMT_AUTH_PAT_ID BIGINT
      , ORIG_PLACE_ID                   VARCHAR(1000)
      , DEST_PLACE_ID                   VARCHAR(1000)
      , DISPLAY_ORDER                   INT
      , CREATED_BY                      BIGINT
      , CREATED_ON                      DATETIME
      , LAST_MODIFIED_BY                BIGINT
      , LAST_MODIFIED_ON                DATETIME
      , ACTIVE                          BIT
      , TRIP_CALC_ID                    BIGINT
	  , DAYS_OF_WEEK_SVC_PROVIDED_JSON  VARCHAR(MAX)
	  , AM_PM_SELECTION                 VARCHAR(256)
	)

  /*==============================    
   * Populate the table variable
   *==============================*/

   if (@reverseStops = 1)
   begin
	
	INSERT INTO @duplicateRouteMembers
    SELECT 
	    ID                             	= tmarm.ID                             
	  , TRANSPORTATION_MGMT_ID         	= tmarm.TRANSPORTATION_MGMT_ID         
	  , CLIENT_ID                      	= tmarm.CLIENT_ID                      
	  , PATIENT_ID                     	= tmarm.PATIENT_ID                     
	  , ROUTE_ID                       	= tmarm.ROUTE_ID                       
	  , TRANSPORTATION_MGMT_AUTH_PAT_ID	= tmarm.TRANSPORTATION_MGMT_AUTH_PAT_ID
	  , ORIG_PLACE_ID                  	= tmarm.ORIG_PLACE_ID                  
	  , DEST_PLACE_ID                  	= tmarm.DEST_PLACE_ID                  
	  , DISPLAY_ORDER                  	= isnull(tmarm.DISPLAY_ORDER, (tmarm.ID + 1000)) /* Use display order first, then order added with some space added */                  
	  , CREATED_BY                     	= tmarm.CREATED_BY                     
	  , CREATED_ON                     	= tmarm.CREATED_ON                     
	  , LAST_MODIFIED_BY               	= tmarm.LAST_MODIFIED_BY               
	  , LAST_MODIFIED_ON               	= tmarm.LAST_MODIFIED_ON               
	  , ACTIVE                         	= tmarm.ACTIVE                         
	  , TRIP_CALC_ID                   	= tmarm.TRIP_CALC_ID                   
	  , DAYS_OF_WEEK_SVC_PROVIDED_JSON  = tmarm.DAYS_OF_WEEK_SVC_PROVIDED_JSON 
	  , AM_PM_SELECTION                 = tmarm.AM_PM_SELECTION

	FROM TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS as tmarm
    WHERE
           (ROUTE_ID = @routeIDToDuplicate)
	   AND (ACTIVE = 1)
	   order by DISPLAY_ORDER desc 

   end

   else
   begin

	INSERT INTO @duplicateRouteMembers
    SELECT * FROM TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS
    WHERE
          (ROUTE_ID = @routeIDToDuplicate)
      AND (ACTIVE = 1)

   end

  /*==============================    
   * Save each member
   *==============================*/

   select @curIdx = min(idx), @maxIdx = max(idx) from @duplicateRouteMembers
   
   while (@curIdx <= @maxIdx)
   begin

	 select top 1                 
		  @patID        = PATIENT_ID                     
		, @origPlaceID  = ORIG_PLACE_ID                       
		, @destPlaceID  = DEST_PLACE_ID
		, @weekDaysJSON = DAYS_OF_WEEK_SVC_PROVIDED_JSON
		, @selectAmPm   = AM_PM_SELECTION
		               
	 from @duplicateRouteMembers 
	 where (idx = @curIdx)

	 /*==============================    
	  * Reverse source and destination
	  * if needed
	  *==============================*/

	  if (@reverseStops = 1)
	  begin
	
		set @tempOrigPlaceID = @destPlaceID
		set @tempDestPlaceID = @origPlaceID
		
		set @origPlaceID = @tempOrigPlaceID
		set @destPlaceID = @tempDestPlaceID

	  end
	
	 exec [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_CORE]     
		   @userID        
		 , @userGroup     
		 , @userRank      
		 , @clientID      
		 , @transMgmtID   
		 , @recordID       
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
		 , @spDetails         OUTPUT    
		 , @recordIDMemb      OUTPUT

     set @curIdx = @curIdx + 1
   end
 
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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_DUPLICATE] TO [webuser]
GO


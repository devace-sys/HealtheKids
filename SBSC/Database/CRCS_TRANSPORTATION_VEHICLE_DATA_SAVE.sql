USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
                                                                      
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_TRANSPORTATION_VEHICLE_DATA_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_TRANSPORTATION_VEHICLE_DATA_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
                        
CREATE PROCEDURE [dbo].[CRCS_TRANSPORTATION_VEHICLE_DATA_SAVE]     
 (  @userID                bigint    
  , @userGroup             int    
  , @userRank              int    
  , @clientID              bigint
  , @fiscalYearID          bigint
  , @vehicleRateType       int
  , @numVehiclesInFleet    int
  , @numSpeciallyAdapted   int
  , @saveType              int           OUTPUT    
  , @spDetails             varchar(8000) OUTPUT    
  , @recordID              bigint        OUTPUT
)
AS    
BEGIN     
    
/***************************************************************************    
 * CRCS_TRANSPORTATION_VEHICLE_DATA_SAVE */    
/**    
 *     
 ***************************************************************************/         
     
SET NOCOUNT ON    

declare @TranOpen             as bit
declare @today                as datetime
declare @existingRecID        as bigint

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @recordID   = NULL 
SET @today      = GETDATE()
SET @spDetails  = ''    
set @saveType   = dbo.CONST_SAVE_TYPE_NEW()

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

/*-------------------------------    
 * Check for bad data
 *-------------------------------*/

 IF (sign(@numVehiclesInFleet) = -1 or sign(@numSpeciallyAdapted) = -1)
	RAISERROR ('Please enter non-negative numbers', 11, 1)

IF (@numVehiclesInFleet is not null and @numSpeciallyAdapted is not null)
BEGIN
	IF (@numSpeciallyAdapted > @numVehiclesInFleet)
		RAISERROR ('Number of specially adapted buses/vans cannot exceed number of vehicles in fleet', 11, 1)
END

/*-------------------------------    
 * Retrieve existing record
 *-------------------------------*/    

set @existingRecID = null

select top 1   
    @existingRecID  = ctvd.id
from dbo.CRCS_TRANSPORTATION_VEHICLE_DATA as ctvd
where (
		(ctvd.clientID      = @clientID)
	and (ctvd.fiscalYearID  = @fiscalYearID)
	and (ctvd.active         = 1)
)  

BEGIN TRANSACTION    

SET @TranOpen = 1

/*-------------------------------    
 * If there is no record create
 * a new one
 *-------------------------------*/    

if (@existingRecID is null)
begin

  insert into dbo.CRCS_TRANSPORTATION_VEHICLE_DATA (
      clientID
    , fiscalYearID
    , vehicleRateType
    , numVehiclesInFleet
    , numSpeciallyAdapted
    , created
    , createdBy
    , active
   )
   values (
      @clientID
    , @fiscalYearID
    , @vehicleRateType    
    , @numVehiclesInFleet 
    , @numSpeciallyAdapted
    , @today
    , @userID
    , 1
    )

  set @saveType = dbo.CONST_SAVE_TYPE_NEW()
  set @recordID = SCOPE_IDENTITY()

end

/*-------------------------------    
 * Otherwise update existing
 *-------------------------------*/    

else
begin      

  update dbo.CRCS_TRANSPORTATION_VEHICLE_DATA
  set 
      clientID 		      = @clientID 		  
    , fiscalYearID	      = @fiscalYearID	  
    , vehicleRateType	  = @vehicleRateType    
    , numVehiclesInFleet  = @numVehiclesInFleet 
    , numSpeciallyAdapted = @numSpeciallyAdapted
    , lastModified	      = @today		  
    , lastModifiedBy      = @userID 
	  	  
  where (id = @existingRecID)

  set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
  set @recordID = @existingRecID

end
  
/*============================================================
 * All done, commit changes and get out
 *============================================================*/

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

GRANT EXECUTE ON  [dbo].[CRCS_TRANSPORTATION_VEHICLE_DATA_SAVE] TO [webuser]
GO


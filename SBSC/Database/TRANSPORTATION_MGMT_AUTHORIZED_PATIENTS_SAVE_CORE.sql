USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @clientID      BIGINT,    
  @transMgmtID   BIGINT,
  @patID         BIGINT, 
  @sitePlaceID    varchar(255),
  @homePlaceID    varchar(255),  
  @editDelReason VARCHAR(7000),
  @validateRec   BIT,
  @saveType      INT,    
  @recID         INT,      /* Note: Not used.  @patID is used to find */           
  @MsgNoRec      VARCHAR(1000),
  @MsgNoEdit     VARCHAR(1000), 
  @MsgDupRec     VARCHAR(1000),     
  @MsgDataError  VARCHAR(1000),
  @MsgNotActive  VARCHAR(1000),     
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE */    
/**    
 * Creates a new record or edits an exiting one
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

DECLARE @recCount            AS INT
DECLARE @today               as DATETIME
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in    
declare @currSiteID     as bigint = null
declare @currPatPlaceID as bigint = null
declare @recsSiteID     as bigint = null
declare @recsPatPlaceID as bigint = null
declare @testID              as bigint

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
  @recordID = transMgmtAuthPatID 
from dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW_CORE (  @userID
                                                            , @userGroup
                                                            , @userRank
                                                            , @clientID
                                                            , @transMgmtID
                                                            , @patID
                                                            , 1
                                                            , null)

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN       
  if (@recordID is not null) RAISERROR ('Patient is already on authorized list', 11, 1) 
END

ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN
  if (@recordID is null) RAISERROR ('Record not found', 11, 1) 
END

/*-------------------------------    
 * Lookup patients current 
 * siteID
 *------------------------------*/    

select top 1  
    @currSiteID = psvc.SITE_ID  
from dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID) as psvc  
where (psvc.PATIENT_ID = @patID)

/*-------------------------------    
 * Lookup patients current 
 * home place id
 *------------------------------*/    

select top 1
    @currPatPlaceID = id
from dbo.PATIENT_PLACES as pp
where (
      (pp.PATIENT_ID         = @patID)
  and (pp.PATIENT_PLACE_TYPE = dbo.CONST_PATIENT_PLACE_TYPE_HOME_PRIMARY())
  and (pp.ACTIVE = 1)
)
order by   
    ID         desc
  , START_DATE desc

/*-------------------------------    
 * If no site place is provided
 * use the patients current
 * siteID to lookup a site
 * place to use
 *------------------------------*/    

if (@sitePlaceID is null)
begin
  
  select top 1
    
     @sitePlaceID = spvc.placeID
  
  from dbo.SITE_PLACES_VIEW_CORE(   @userID
                                  , @userGroup
                                  , @userRank
                                  , @clientID
                                  , null
                                  , 1
                                  , null ) as spvc
  where (spvc.id = @currSiteID)

end
else

/*-------------------------------    
 * Otherwise lookup data
 *------------------------------*/    

begin

  set @testID  = null  
  select top 1 @recsSiteID = recid from dbo.PARSE_PLACE_ID_STRING (@sitePlaceID) where (id = 3)
  if (@recsSiteID is not null)
  begin
    select top 1
       @testID = id
    from dbo.SITE_PLACES_VIEW_CORE(   @userID
                                    , @userGroup
                                    , @userRank
                                    , @clientID
                                    , null
                                    , 1
                                    , null ) as spvc
    where (spvc.id = @recsSiteID)
  end

  if (@testID is null) RAISERROR ('Invalid site', 11, 1) 

end

/*-------------------------------    
 * If no home place is provided
 * use the patients current
 * patPlaceID to look up
 * a home place to use
 *------------------------------*/    

if (@homePlaceID is null)
begin
  
  select top 1  
     @homePlaceID  = ppvc.placeID
  
  from dbo.PATIENT_PLACES_VIEW_CORE (  @userID
                                     , @userGroup
                                     , @userRank
                                     , @clientID                                    
                                     , @patID
                                     , null
                                     , 1
                                     , null ) as ppvc
  where (ppvc.id = @currPatPlaceID)

end

else

/*-------------------------------    
 * Otherwise lookup data
 *------------------------------*/    

begin
  set @testID = null  
  select top 1 @recsPatPlaceID = recid from dbo.PARSE_PLACE_ID_STRING (@homePlaceID) where (id = 4)
  if (@recsPatPlaceID is not null)
  begin
     select top 1
         @testID       = id
     
     from dbo.PATIENT_PLACES_VIEW_CORE (  @userID
                                       , @userGroup
                                       , @userRank
                                       , @clientID                                    
                                       , @patID
                                        , null
                                       , 1
                                       , null ) as ppvc
      where (ppvc.id = @recsPatPlaceID)
  end
  if (@testID is null) RAISERROR ('Invalid patient place', 11, 1) 
  
end

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
       
        
    INSERT INTO dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS (
        TRANSPORTATION_MGMT_ID
      , CLIENT_ID
      , PATIENT_ID
      , SITE_PLACE_ID
      , HOME_PLACE_ID 
      , CREATED_BY
      , CREATED_ON
      , ACTIVE   
    )    
    VALUES ( 
        @transMgmtID 
      , @clientID
      , @patID 
      , @sitePlaceID
      , @homePlaceID
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
      
    UPDATE dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS
    set        
       
        SITE_PLACE_ID      = @sitePlaceID     
      , HOME_PLACE_ID      = @homePlaceID
      , LAST_MODIFIED_BY   = @userID
      , LAST_MODIFIED_ON    = @today
          
    where (
          (ID        = @recordID)
      and (CLIENT_ID = @clientID)
      and (TRANSPORTATION_MGMT_ID = @transMgmtID)      
    )
    
 END
 ELSE
 BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)             
 END
    

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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE] TO [webuser]
GO


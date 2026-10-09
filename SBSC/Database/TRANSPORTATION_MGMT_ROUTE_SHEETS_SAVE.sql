USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_ROUTE_SHEETS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_ROUTE_SHEETS_SAVE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEETS_SAVE]
 (  @userID        BIGINT
  , @userGroup     INT  
  , @userRank      INT    
  , @clientID      BIGINT
  , @transMgmtID   BIGINT
  , @routeID       BIGINT
  , @startDate     DATE
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
 * TRANSPORTATION_MGMT_ROUTE_SHEETS_SAVE */    
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
DECLARE @TranOpen            AS BIT  

declare @dates  as table (
    idx      int
  , dowValue date
)

declare @routes as table (
   idx     int identity(1,1)
  ,routeID bigint
)

declare @refDate  as date
declare @monDate  as date
declare @tueDate  as date
declare @wedDate  as date
declare @thuDate  as date
declare @friDate  as date
declare @rteID    as bigint
declare @sheeetBatchID as bigint

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
 * Calc dates
 *------------------------------*/    
 
if @startDate is null set @startDate = @today

insert into @dates 
select * from dbo.CALC_MON_TO_FRI_DATES_FOR_START_DATE(@startDate)

/*-------------------------------    
 * Parse them out
 *------------------------------*/    

select top 1 @refDate = dowValue from @dates where idx is null
select top 1 @monDate = dowValue from @dates where idx = 2
select top 1 @tueDate = dowValue from @dates where idx = 3
select top 1 @wedDate = dowValue from @dates where idx = 4
select top 1 @thuDate = dowValue from @dates where idx = 5
select top 1 @friDate = dowValue from @dates where idx = 6

/*-------------------------------    
 * Get active routes
 *------------------------------*/    

insert into @routes
select id as routeID 
from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES as t1
where (
      (t1.CLIENT_ID              = @clientID)
  and (t1.TRANSPORTATION_MGMT_ID = @transMgmtID)
  and (t1.ACTIVE = 1)
  and ((@routeID is null) or (t1.ID = @routeID))
)

/*-------------------------------    
 * Validation    
 *------------------------------*/    
        
IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        

    
BEGIN TRANSACTION    
SET @TranOpen = 1    

/*==============================    
 * New Record
 *==============================*/    
  
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN       

  
  insert into dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_BATCHES values (@clientID,@userID,@today,1)
  set @sheeetBatchID = SCOPE_IDENTITY()
  
  declare @minIdx as int
  declare @maxIdx as int
  declare @curIdx as int
  select @minIdx = min(idx) from @routes
  select @maxIdx = max(idx) from @routes
  set @curIdx = @minIdx

  while (@curIdx <= @maxIdx)
  begin
    select top 1 @rteID = routeID from @routes where (idx = @curIdx)
    set @curIdx = @curIdx + 1
  
    exec dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_SAVE_CORE
       @userID        
     , @userGroup     
     , @userRank
     , @sheeetBatchID
     , @clientID      
     , @transMgmtID   
     , @rteID       
     , @startDate     
     , @refDate       
     , @monDate       
     , @tueDate       
     , @wedDate       
     , @thuDate       
     , @friDate       
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
  
  end
                                         
  set @recordID = @sheeetBatchID
  
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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEETS_SAVE] TO [webuser]
GO


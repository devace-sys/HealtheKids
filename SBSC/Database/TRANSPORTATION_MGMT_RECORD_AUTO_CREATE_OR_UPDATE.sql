USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_RECORD_AUTO_CREATE_OR_UPDATE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_RECORD_AUTO_CREATE_OR_UPDATE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_RECORD_AUTO_CREATE_OR_UPDATE]     
 (@userID             BIGINT,    
  @userGroup          INT,    
  @userRank           INT,    
  @clientID           BIGINT,    
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
 * TRANSPORTATION_MGMT_RECORD_AUTO_CREATE_OR_UPDATE */    
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

DECLARE @TranOpen      AS BIT  
DECLARE @recCount      AS INT
DECLARE @today         as DATETIME
DECLARE @updateState   AS SMALLINT         -- Indicates what state the record is left in    
DECLARE @auditRecID    AS BIGINT
declare @pracID        as bigint
declare @numPracs      as int

declare @pracIDs       as table (
    PRACTITIONER_ID     bigint
  , STANDARD_TRANS_PRAC bit
)

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
IF (@clientID    IS NULL) RAISERROR ('Client id is required',   11, 1)    

/*-------------------------------    
 * See if we have an active trans
 * mgmt record for this client
 *------------------------------*/    

set @recordID = null

select top 1
    @recordID = ID
from dbo.TRANSPORTATION_MGMT as t1
where ((t1.CLIENT_ID = @clientID) and (t1.ACTIVE = 1))

/*-------------------------------    
 * Get all active trans prac ids
 * for this client
 *------------------------------*/    

insert into @pracIDs
select 

    t1.PRACTITIONER_ID
  , STANDARD_TRANS_PRAC = convert(bit,case when ((t2.LAST_NAME = 'SPECIALIZED') and (t2.FIRST_NAME = 'TRANSPORTATION')) then 1 else 0 end)
  
from dbo.PRACTITIONERS_DATA_CORE (5,@clientID,null,null,null) as t1
join dbo.PRACTITIONER_Practitioner                            as t2 on t2.PRACTITIONER_ID = t1.PRACTITIONER_ID
where (t2.ACTIVE = 1)

/*-------------------------------    
 * See if we have a active prac
 * with our standard name
 *------------------------------*/    

set @pracID = null
select top 1 @pracID = PRACTITIONER_ID from @pracIDs where (STANDARD_TRANS_PRAC = 1)

/*-------------------------------    
 * If not then see if we have
 * any practitioner we can use
 *------------------------------*/    

if (@pracID is null)
begin

  set @numPracs = 0
  select @numPracs = COUNT(PRACTITIONER_ID) from @pracIDs where (STANDARD_TRANS_PRAC = 0)
  
  /*-------------------------------    
   * If there is one and only one
   * we can assume this as the 
   * default for now until a 
   * prac is created with the
   * standard name
   *------------------------------*/    

  if (@numPracs = 1)     
    select top 1 @pracID = PRACTITIONER_ID from @pracIDs where (STANDARD_TRANS_PRAC = 0)

  /*-------------------------------    
   * Otherwise we can't assume a
   * default.  The user will have to
   * choose if there is more than 1
   * or put in a prac if there are 0
   *------------------------------*/    

  else
    set @pracID = null 
 
end

/*-------------------------------    
 * Decide new or edit
 *------------------------------*/    

if (@recordID is null)
  set @saveType = dbo.CONST_SAVE_TYPE_NEW()
else
  set @saveType = dbo.CONST_SAVE_TYPE_EDIT()

/*-------------------------------    
 * Validation    
 *------------------------------*/    
        
IF (@validateRec = 1) 
BEGIN      
  set @recordID = 0
  RETURN(0)    
END        

/*-------------------------------    
 * Create or modify our records
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
        
  /*==============================    
   * New Record
   *==============================*/    
  
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN       
       
    INSERT INTO dbo.TRANSPORTATION_MGMT (
        CLIENT_ID
      , PRACTITIONER_ID
      , CREATED_BY
      , CREATED_ON
      , ACTIVE   
    )        
    VALUES ( 
        @clientID
      , @pracID
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
           
    UPDATE dbo.TRANSPORTATION_MGMT
    set                
	   PRACTITIONER_ID  = @pracID
	 , LAST_MODIFIED_BY = @userID
      , LAST_MODIFIED_ON = @today          
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

GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_RECORD_AUTO_CREATE_OR_UPDATE] TO [webuser]
GO


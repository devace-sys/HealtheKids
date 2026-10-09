USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_GROUP_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_GROUP_SAVE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_GROUP_SAVE]     
 (@userID					 BIGINT,    
  @userGroup				 INT,    
  @userRank					 INT,    
  @clientID					 BIGINT,    
  @pracID					 BIGINT,    
  @groupName				 VARCHAR(500),
  @svcNamesListDataSourceID  INT,
  @viaTeleHealth             BIT,
  @nameID                    BIGINT,
  @recurring                 BIT, 
  @startDate                 DATE,
  @endDate                   DATE ,
  @numMins                   INT,
  @mon                       BIT,
  @monStartTime              TIME(0),
  @tue                       BIT,
  @tueStartTime              TIME(0),
  @wed                       BIT,
  @wedStartTime              TIME(0),
  @thu                       BIT,
  @thuStartTime              TIME(0),
  @fri                       BIT,
  @friStartTime              TIME(0),
  @notes                     VARCHAR(MAX),
  @editDelReason			 VARCHAR(7000),    
  @validateRec				 BIT,    
  @saveType					 INT,    
  @recID					 INT,    
  @MsgNoRec					 VARCHAR(1000),    
  @MsgNoEdit				 VARCHAR(1000), 
  @MsgDupRec				 VARCHAR(1000),     
  @MsgDataError				 VARCHAR(1000),
  @MsgNotActive				 VARCHAR(1000),     
  @spDetails				 VARCHAR(8000) OUTPUT,    
  @recordID					 BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * PRACTITIONER_PATIENT_GROUP_SAVE */    
/**    
 * Creates a new practitioner patient group "header" record or edits an
 * existing one
 *
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   pracID          Practitioner id
 * @param   patID           Patient id
 * @param   minsInd
 * @param   minsGrp
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
DECLARE @auditRecID          AS BIGINT

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

IF (@userID      IS NULL) RAISERROR ('userID is required',			11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',		11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',		11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',		11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',		11, 1)    
if (@startDate   IS NULL) RAISERROR ('Service date is required',    11, 1)
if (@recurring   IS NULL) RAISERROR ('Recurring is required',       11, 1)
if (@nameID      IS NULL) RAISERROR ('Service selection required',  11, 1)

/*============================================================
 * Set default values
 *============================================================*/  

if (@recurring = 0)
begin
  set @endDate = @startDate
end
else

/*-------------------------------    
 * Verify client, practitioner,
 * and patient ids
 *------------------------------*/   

SET @recCount = null

select 
  @recCount = COUNT(cc.CLIENT_ID)  
from dbo.CLIENTS_Client            as cc
join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID       = cc.CLIENT_ID
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
where 
      ((cc.CLIENT_ID       = @clientID) and
      (prc.PRACTITIONER_ID = @pracID)   and
      (cc.LEA = 1)                      and 
      (prp.ACTIVE = 1))
      
if (@recCount != 1)
  RAISERROR ('Invalid client or practitioner id', 11, 1) 

/*-------------------------------    
 * See if a record already 
 * exists
 *------------------------------*/    
 IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
BEGIN
	set @recordID = null     

	select top 1
	  @recordID = id
	from dbo.PRACTITIONER_PATIENT_GROUP
	where 
		   ((clientID  = @clientID)
	  and  (pracID    = @pracID)
	  and  (groupName = @groupName)
	  and  ((@recID is null) or (id = @recID)))

	if (@recordID is not null) RAISERROR ('Group already exists', 11, 1) 
END

/* If this is an edit check to see if the record exists */

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN
 
 set @recordID = null     
 
 select top 1
    @recordID = id
  from dbo.PRACTITIONER_PATIENT_GROUP
  where(
       (clientID  = @clientID)
  and  (pracID    = @pracID) 
  and  (id = @recID)
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
 * Create or modify our     
 * caseload records
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
        
  /*==============================    
   * New Record
   *==============================*/    
  
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN       
       
    INSERT INTO dbo.PRACTITIONER_PATIENT_GROUP (
        clientID
      , pracID
      , groupName
	  , svcNamesListDataSourceID
	  , viaTeleHealth             
	  , nameID                      
	  , recurring                 
	  , startDate                 
	  , endDate                 
	  , numMins 
	  , mon
	  , monStartTime
	  , tue
	  , tueStartTime
	  , wed
	  , wedStartTime
	  , thu
	  , thuStartTime
	  , fri
	  , friStartTime                  
	  , notes         
      , created
      , createdBy
      , lastModified
      , lastModifiedBy
    )    
    VALUES ( 
        @clientID
      , @pracID
      , @groupName
	  , @svcNamesListDataSourceID
	  , @viaTeleHealth             
	  , @nameID                      
	  , @recurring                 
	  , @startDate                 
	  , @endDate                  
	  , @numMins 
	  , @mon
	  , @monStartTime	   
	  , @tue
	  , @tueStartTime	   
	  , @wed
	  , @wedStartTime	   
	  , @thu
	  , @thuStartTime	   
	  , @fri
	  , @friStartTime                  
	  , @notes                     
      , @today
      , @userID
      , null
      , null
     )
      
    SET @recordID = SCOPE_IDENTITY()
                             
 END       
  
 /*==============================    
  * Edit Record
  *==============================*/ 
 
 ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
 BEGIN    
     
    
    set @updateState = dbo.CONST_REC_STATE_MOD()
    SET @recordID = @recID
	  
    update dbo.PRACTITIONER_PATIENT_GROUP
    set 
        groupName				 = @groupName
	  , svcNamesListDataSourceID = @svcNamesListDataSourceID
	  , viaTeleHealth			 = @viaTeleHealth      
	  , nameID                   = @nameID   
	  , recurring                = @recurring 
	  , startDate                = @startDate 
	  , endDate                  = @endDate   
	  , numMins                  = @numMins 
	  , mon                       = @mon
	  , monStartTime              = @monStartTime
	  , tue                       = @tue
	  , tueStartTime              = @tueStartTime
	  , wed                       = @wed
	  , wedStartTime              = @wedStartTime
	  , thu                       = @thu
	  , thuStartTime              = @thuStartTime
	  , fri                       = @fri
	  , friStartTime              = @friStartTime
	  , notes					 = @notes
      ,lastModified				 = @today
      ,lastModifiedBy			 = @userID
      
    where
         ((id        = @recordID)
      and (clientID  = @clientID)
      and (pracID    = @pracID)
      and (id        = @recID))
  
 END
 ELSE
 BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)             
 END
    
 /*-------------------------------    
  * Create audit record    
  *------------------------------*/    
       
 --EXEC CASELOAD_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
 
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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_GROUP_SAVE] TO [webuser]
GO

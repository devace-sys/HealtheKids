/* TODO: Make sure this is compatible with expected services logic */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE]     
 (@userID         BIGINT,    
  @userGroup      INT,    
  @userRank       INT,    
  @clientID       BIGINT,    
  @pracID         BIGINT,
  @pracPatGroupID BIGINT,  
  @patID          BIGINT,  
  @editDelReason  VARCHAR(7000),    
  @validateRec    BIT,    
  @saveType       INT,    
  @recID          INT,    
  @MsgNoRec       VARCHAR(1000),    
  @MsgNoEdit      VARCHAR(1000), 
  @MsgDupRec      VARCHAR(1000),     
  @MsgDataError   VARCHAR(1000),
  @MsgNotActive   VARCHAR(1000),     
  @spDetails      VARCHAR(8000) OUTPUT,    
  @recordID       BIGINT        OUTPUT,
  @jsonData		  varchar(max)  OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE */    
/**    
 * Creates a new caseload record or edits an exiting one
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

declare @clientIdOut            bigint
declare @pracIdOut              bigint
declare @patIdOut               bigint
declare @groupIdOut             bigint
declare @pracGrpSvcClsNameIdOut bigint
declare @caseloadEntryIdOut     bigint
declare @caseloadExpectedSvcEntryIDOut bigint

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @spDetails  = ''    
SET @recordID = NULL 
SET @today    = GETDATE()
SET @caseloadEntryIdOut			   = 0
SET @caseloadExpectedSvcEntryIDOut = 0

SET @jsonData = CONCAT(
		'{"caseloadEntryIdOut":', @caseloadEntryIdOut,
		',"caseloadExpectedSvcEntryIdOut":', @caseloadExpectedSvcEntryIDOut,
		'}'
);

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

select top 1
  @recCount = COUNT(cc.CLIENT_ID)  
from dbo.CLIENTS_Client            as cc
join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID       = cc.CLIENT_ID
join dbo.PATIENTS_Client           as pac on pac.CLIENT_ID       = cc.CLIENT_ID
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.PATIENTS_Patient          as pap on pap.PATIENT_ID      = pac.PATIENT_ID
where 
      (cc.CLIENT_ID        = @clientID) and
      (prc.PRACTITIONER_ID = @pracID)   and
      (pac.PATIENT_ID      = @patID)    and
      (cc.LEA     = 1)                  and 
      (prp.ACTIVE = 1)                  and 
      (upper(ltrim(rtrim(pap.ACTIVE))) = 'Y')
      
if (@recCount != 1)
  RAISERROR ('Invalid client, practitioner, or patient id', 11, 1) 

/*-------------------------------    
 * Verify group exists
 *------------------------------*/   

SET @recCount = null

select top 1
  @recCount = COUNT(id)  
from dbo.PRACTITIONER_PATIENT_GROUP 
where 
     ((clientID  = @clientID)
  and (pracID    = @pracID)
  and (id        = @pracPatGroupID)
  )

if (@recCount != 1)
  RAISERROR ('Invalid group id', 11, 1) 

/*-------------------------------    
 * See if a record already 
 * exists
 *------------------------------*/    

set @recordID = null     

select top 1
  @recordID = id
from dbo.PRACTITIONER_PATIENT_GROUP_MEMBER
where 
      ((pracPatGroupID = @pracPatGroupID)
  and  (patID          = @patID))

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN       
  if (@recordID is not null) RAISERROR ('Patient is already in group', 11, 1) 
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
        
  /***************************************************************************    
   *                        Manage caseload data   
   *        Adds patent to caseload if not already on caseload 
   ***************************************************************************/         
    
  exec dbo.PRACTITIONER_CASELOAD_MEMBER_Save_Core 
      @userID
    , @clientID
    , @pracID
    , @patID
    , null /* planType*/
    , null /* spEdSvcCode*/
    , null /* orpDocID */
    , null /* sdate*/
    , null /* edate */
    , null /* freq */
    , null /* dur */
    , null /* minsInd*/
	, null /* minsGrp*/
	, null /* Days of week */
    , 1
    , @validateRec
    , @clientIdOut            output
    , @pracIdOut              output
    , @patIdOut               output
    , @groupIdOut             output
    , @pracGrpSvcClsNameIdOut output
    , @caseloadEntryIdOut     output

	select top 1 
		@caseloadExpectedSvcEntryIDOut =t2.id 
    from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as t2
    where ( 
          (t2.caseloadEntryID = @caseloadEntryIdOut)
      and (t2.active = 1)
    )
	order by 
		t2.id desc

  /*==============================    
   * New Record
   *==============================*/    

  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN       
       
    INSERT INTO dbo.PRACTITIONER_PATIENT_GROUP_MEMBER (
        pracPatGroupID
      , patID
      , created
      , createdBy
      , lastModified
      , lastModifiedBy
    )    
    VALUES ( 
        @pracPatGroupID
      , @patID
      , @today
      , @userID
      , null
      , null
    )
      
    SET @recordID = SCOPE_IDENTITY()
                             
 END       
  
 ELSE
 BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)             
 END
   
   SET @jsonData = CONCAT(
		'{"caseloadEntryIdOut":', @caseloadEntryIdOut,
		',"caseloadExpectedSvcEntryIdOut":', @caseloadExpectedSvcEntryIDOut,
		'}'
	);
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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE] TO [webuser]
GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_Promised_Services_Delivery_Exceptions_Delete') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENTS_Promised_Services_Delivery_Exceptions_Delete
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PATIENTS_Promised_Services_Delivery_Exceptions_Delete] (
    @userID                           BIGINT
  , @userGroup                        INT   
  , @userRank                         INT
  , @clientID                         bigint
  , @patID                            bigint
  , @deliveryExceptionRemovedReasonID int
  , @deliveryExceptionRemovedNotes    varchar(max)
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT  
  , @recID         INT
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * PATIENTS_Promised_Services_Delivery_Exceptions_Delete */    
/**    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @TranOpen     AS BIT    
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    
declare @createdBy        as bigint        = 0
declare @createdByStr     as varchar(50)   = ''
declare @msgSubject       as VARCHAR(256)  = ''
declare @msgBody          as VARCHAR(max)  = ''
declare @msgSpDetails     as varchar(8000) = ''
declare @msgID            as bigint        = 0     

declare @userName                       as varchar(556) 
declare @patName                        as varchar(256)
declare @dosStartStr                    as varchar(50)
declare @dosEndStr                      as varchar(50)
declare @deliveryExceptionAddedNotes    as varchar(max)
declare @deliveryExceptionAddedReason   as varchar(max)
declare @deliveryExceptionRemovedReason as varchar(max)


BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)    
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@clientID    IS NULL) RAISERROR ('Client ID is required',  11, 1)    
IF (@patID       is null) RAISERROR ('Patient ID is required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)    

IF (@deliveryExceptionRemovedReasonID is null)  RAISERROR ('Removal reason required', 11, 1)    
   
/*-------------------------------    
 * Lookup record 
 *------------------------------*/    

set @recordID = null

select top 1  
    @recordID                       = t1.id
  , @createdBy                      = t1.createdBy
  , @patName                        = t3.CONCAT_NAME
  , @dosStartStr                    = dbo.RPT_DATE_FMT(t1.dosStart)
  , @dosEndStr                      = dbo.RPT_DATE_FMT(t1.dosEnd)
  , @deliveryExceptionAddedReason   = t2.[name]
  , @deliveryExceptionAddedNotes    = isnull(t1.deliveryExceptionAddedNotes,'')

from dbo.PATIENTS_Promised_Services_Delivery_Exceptions              as t1
join dbo.PATIENTS_Promised_Services_Delivery_Exception_Added_Reasons as t2 on t2.id         = t1.deliveryExceptionAddedReasonID
join dbo.PATIENTS_Patient                                            as t3 on t3.PATIENT_ID = t1.patID
where (
      (t1.clientID = @clientID)
  and (t1.patID    = @patID)
  and (t1.removed  = 0)
  and (t1.active   = 1)
  and (t1.id       = @recID)
)

/*-------------------------------    
 * If record not found then
 * exit silently
 *------------------------------*/    

if (@recordID is null) return(0)
if (@recordID != @recID) return(0)

/*-------------------------------    
 * Get supporting data for 
 * message
 *------------------------------*/    

select top 1 
  @userName = t1.UserName
from users.dbo.Users as t1
where (t1.userrid = @userID)

select top 1 
  @deliveryExceptionRemovedReason = t1.[name]
from dbo.PATIENTS_Promised_Services_Delivery_Exception_Removed_Reasons as t1
where 
  (t1.id = @deliveryExceptionRemovedReasonID)

/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  SET @updateState = dbo.CONST_SVC_REC_STATE_DEL()    
  
  update dbo.PATIENTS_Promised_Services_Delivery_Exceptions
  set 
   	  deliveryExceptionRemovedReasonID    = @deliveryExceptionRemovedReasonID           
	, deliveryExceptionRemovedNotes       = @deliveryExceptionRemovedNotes
    , active                              = 0    
	, removed                             = 1
	, removedBy                           = @userID
	, removedOn                           = @today
	, lastModified                        = @today
    , lastModifiedBy                      = @userID    
  where 
    ([id] = @recordID)
  
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes 
 *------------------------------*/    
     
COMMIT TRANSACTION    
SET @TranOpen = 0    

/*-------------------------------    
 * Send message to user who 
 * created exception
 * (If someone else is deleting)
 *------------------------------*/    

if (@userID != @createdBy)
begin

  set @createdByStr =  convert(varchar(50),@createdBy)
  
  set @msgSubject = 'A promised service deferral you added has been removed'
  
  set @msgBody    = 'The deferral ' 
                  + '<br>'
				  + '<br>Student : '          + @patName
				  + '<br>Dates of Service : ' + @dosStartStr + ' - ' + @dosEndStr
				  + '<br>Deferral Reason : '  + @deliveryExceptionAddedReason 
				  + '<br>Deferral Notes  : '  + @deliveryExceptionAddedNotes
				  + '<br>'
				  + '<br>Was removed by : '   + @userName
				  + '<br>Removal Reason : '   + @deliveryExceptionRemovedReason
				  + '<br>Removal Notes : '    + isnull(@deliveryExceptionRemovedNotes,'')
				 
  exec users.dbo.USERS_MESSAGES_SAVE_SIMPLE 
    @userID
  , @userGroup
  , @userRank
  , 'spedcare'
  , @createdByStr
  , @msgSubject
  , @msgBody   
  , 1 /*@allowReply */
  , 0 /*@sendEmail */
  , @msgSpDetails      OUTPUT
  , @msgID             OUTPUT
end


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
   
  SET @ErrorMessage = @ErrorMessage
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PATIENTS_Promised_Services_Delivery_Exceptions_Delete] TO [webuser]
GO

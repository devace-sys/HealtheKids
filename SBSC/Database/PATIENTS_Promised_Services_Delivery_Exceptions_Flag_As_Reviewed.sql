USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_Promised_Services_Delivery_Exceptions_Flag_As_Reviewed') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENTS_Promised_Services_Delivery_Exceptions_Flag_As_Reviewed
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.PATIENTS_Promised_Services_Delivery_Exceptions_Flag_As_Reviewed
( 
    @userID          BIGINT
  , @userGroup       INT    
  , @userRank        INT
  , @clientID        BIGINT
  , @patID           BIGINT
  , @editDelReason   VARCHAR(7000)
  , @validateRec     BIT
  , @recID           BIGINT  
  , @MsgNoRec        VARCHAR(1000)    
  , @MsgNoEdit       VARCHAR(1000)
  , @spDetails       VARCHAR(8000) OUTPUT
  , @recordID        BIGINT        OUTPUT)   

AS
BEGIN

/***************************************************************************    
 * PATIENTS_Promised_Services_Delivery_Exceptions_Flag_As_Reviewed */ 
/**    
 * Flags the exception as reviewed
 *    
 ***************************************************************************/     

SET NOCOUNT ON    

declare @createdBy  as bigint  = 0
declare @tranOpen   as bit     = 0
declare @today      as datetime = getdate()

BEGIN TRY    

/*============================================================
 * Init
 *============================================================*/     
   
SET @recordID    = 0    
SET @spDetails   = ''    
set @tranOpen    = 0
set @today       = getdate()

/*============================================================
 * Verify required parameters
 *============================================================*/     

IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)    
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@clientID    IS NULL) RAISERROR ('Client ID is required',  11, 1)    
IF (@patID       is null) RAISERROR ('Patient ID is required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)   

/*============================================================
 * Lookup existing record
 *============================================================*/     

set @recordID = null

select top 1  
    @recordID                       = t1.id
  , @createdBy                      = t1.createdBy

from dbo.PATIENTS_Promised_Services_Delivery_Exceptions              as t1

where (
      (t1.clientID = @clientID)
  and (t1.patID    = @patID)
  and (t1.active   = 1)
  and (t1.reviewed = 0)
  and (t1.removed  = 0)
  and (t1.id       = @recID)
)

/*============================================================
 * If applicable record is not found exit silently
 *============================================================*/  

if (@recordID is null) return(0)
if (@recordID != @recID) return(0)

/*============================================================
 * If the user flaging as reviewed is the same user who created
 * the record exit with an exception
 *============================================================*/  

if (@userID = @createdBy)
begin
  RAISERROR ('The user who created the exception/deferal cannot be the same user who approves it', 11, 1)    
  return(0)
end

/*============================================================
 * If we are just validating get out
 *============================================================*/  
     
IF (@validateRec = 1) RETURN(0)    
   
/*============================================================
 * Write changes to data
 *============================================================*/  

BEGIN TRANSACTION    
   
set @tranOpen = 1    
     
update dbo.PATIENTS_Promised_Services_Delivery_Exceptions
set 
    reviewed                            = 1
  , reviewedBy                          = @userID
  , reviewedOn                          = @today
  , lastModified                        = @today
  , lastModifiedBy                      = @userID    
where 
  ([id] = @recordID)
  
/*============================================================
 * If we reach this point all is good.  Commit changes and exit
 *============================================================*/  
     
COMMIT TRANSACTION    
SET @tranOpen = 0    

RETURN(0)    

END TRY    
   
BEGIN CATCH    
   
/*============================================================
 * If we end up here something went wrong.  Cancel any pending
 * transactions and return any error messages to the caller
 *============================================================*/  

if (@tranOpen = 1) ROLLBACK TRANSACTION
   
-- Error or raise error with severity 11 to 19 will be caught here    
      
DECLARE @ErrorMessage  AS NVARCHAR(4000)    
DECLARE @ErrorSeverity AS INT    
DECLARE @ErrorState    AS INT    
     
SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
        @ErrorSeverity = ERROR_SEVERITY(),    
        @ErrorState    = ERROR_STATE()    
   
   
-- Reraise the error so it returns back to the server    
   
RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PATIENTS_Promised_Services_Delivery_Exceptions_Flag_As_Reviewed] TO [webuser]
GO


USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_APPROVAL_ASSIGN_OR_UNASSIGN_SUPERVISOR_BY_PRAC_ID') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_ASSIGN_OR_UNASSIGN_SUPERVISOR_BY_PRAC_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_ASSIGN_OR_UNASSIGN_SUPERVISOR_BY_PRAC_ID ( 
  @userID            BIGINT,    
  @userGroup         INT,    
  @userRank          INT,    
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,
  @clientID          BIGINT,
  @supervisedPracID  BIGINT,
  @supervisingPracID BIGINT,
  @assign            BIT,
  @recID             BIGINT,  
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)   

AS
BEGIN

/***************************************************************************    
 * SERVICE_RECORDS_APPROVAL_ASSIGN_OR_UNASSIGN_SUPERVISOR_BY_PRAC_ID */ 
/**    
 * Marks service as accepted or rejected
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   svcRecID        Service record to associate with this note
 * @returns recordID        New record id of the note
 ***************************************************************************/     

SET NOCOUNT ON    
   
DECLARE @today         AS DATETIME          -- Current date/time stamp    
DECLARE @recUserID     AS BIGINT            -- Associated user id   
DECLARE @saveType      AS INT    
DECLARE @updateState   AS INT    
DECLARE @numRecIDs     as INT
DECLARE @numDupRecIDs  as INT
DECLARE @currentID     AS INT
DECLARE @recIDVal      AS BIGINT
DECLARE @recIDVals     as TABLE([id] int, [recid] bigint) 
   
BEGIN TRY    

/*============================================================
 * Init
 *============================================================*/     
   
SET @recordID    = 0    
SET @spDetails   = ''    
SET @today       = GETDATE()    
SET @saveType    = dbo.CONST_SAVE_TYPE_EDIT()
SET @updateState = dbo.CONST_REC_STATE_MOD()  
SET @numRecIDs   = 0

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userID          IS NULL) RAISERROR ('userID is required',         11, 1)
IF (@userGroup       IS NULL) RAISERROR ('userGroup is required',      11, 1)    
IF (@userRank        IS NULL) RAISERROR ('userRank is required',       11, 1)    
IF (@validateRec     IS NULL) RAISERROR ('Validate flag required',     11, 1)    

/*============================================================
 * Look for existing record
 *============================================================*/  

set @recordID = null

select 
  @recordID = ID
from dbo.PRACTITIONER_PRACTITIONER_SUPERVISED_SUPERVISOR 
where 
      (CLIENT_ID           = @clientID )
  and (SUPERVISED_PRAC_ID  = @supervisedPracID)
  and (SUPERVISING_PRAC_ID = @supervisingPracID)

/*============================================================
 * If we are validating get out
 *============================================================*/  

if (@validateRec = 1) RETURN(0)    

/*============================================================
 * If there is no record create a new record with the desired
 * assign flag.  Note: Assign can also be false.
 *============================================================*/  

if (@recordID is null)
begin
  insert into dbo.PRACTITIONER_PRACTITIONER_SUPERVISED_SUPERVISOR (
      CLIENT_ID
    , SUPERVISED_PRAC_ID
    , SUPERVISING_PRAC_ID
    , ACTIVE )
  values (
     @clientID
    ,@supervisedPracID
    ,@supervisingPracID
    ,@assign )

 set @recordID = SCOPE_IDENTITY()  
 
end

/*============================================================
 * Otherwise update the existing record
 *============================================================*/  

else
begin
  update dbo.PRACTITIONER_PRACTITIONER_SUPERVISED_SUPERVISOR
  set ACTIVE = @assign
  where (id = @recordID)
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
   
   
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  --SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORDS_APPROVAL_ASSIGN_OR_UNASSIGN_SUPERVISOR_BY_PRAC_ID] TO [webuser]
GO


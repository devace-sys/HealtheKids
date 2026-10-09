USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Delete_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Delete_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Delete_Core]     
 (@userID            BIGINT,    
  @userGroup         INT,    
  @userRank          INT,    
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,
  @clientID          INT,    
  @recID             INT,
  @applyEditDelRules BIT,
  @today             DATETIME,    
  @MsgNoRec          VARCHAR(1000),     
  @MsgNoEdit         VARCHAR(1000),
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_Delete_Core */    
/**    
 *
 * NOTE: You MUST call this sproc within the context of a transaction from
 *       another sproc.  Do not use this sproc directly!
 *
 * Deletes (hides) an existing service record    
 * and manages any associated claim records.    
 *
 *    
 * @param   userID          The userid of who saved the record    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng service record to edit or    
 *                          delete.  
 * @param   today           Current date/time  
 * @param   MsgNoRec        Desired error message for edit/delete service record    
 *                          operations when record is not found    
 * @param   MsgNoEdit       Desired error message for edit/delete service record    
 *                          operations if the service record cannot be edited or     
 *                          deleted     
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @TranOpen     AS BIT    
DECLARE @tempRecID    AS INT            -- Used for determining if a rec exists    
DECLARE @auditRecID   AS BIGINT         -- Audit record id    
DECLARE @recUserID    AS BIGINT    
DECLARE @canEdit      AS BIT    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT     
DECLARE @clientIDLook AS INT
    
BEGIN TRY    
    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @spDetails  = ''    
    
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
    
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)    
         
set @recordID = null    
set @canEdit  = 0    
      
/*-------------------------------    
 * Look for record that we want
 * to delete  
 *------------------------------*/      
     
set @recordID = null    
set @canEdit  = 0    
      
select top 1
    @recordID = q0.svcRecID
  , @canEdit  = case q0.svcRecEditID 
        when -1 then 0
        else         1
      end 
     , @clientIDLook = q0.clientID   
from (
  select top 1 
      sr.id as svcRecID
    , svcRecEditID = isnull(sre.id,-1) 
    , sr.clientID
  from      dbo.SERVICE_RECORDS as sr
  left join dbo.SERVICE_RECORDS_VIEW_EDITABLE(  null
                                              , @userID
                                              , @userGroup
                                              , @userRank
                                              ,1) as sre on sre.id = sr.id
  where (
         (sr.id = @recID) 
    and ((@clientID is null) or (sr.clientID = @clientID))
  )
) as q0
      
/*-------------------------------    
 * If there are any problems    
 * let the user know    
 *------------------------------*/    
    
IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)  -- Record not found     

/*-------------------------------    
 * Ignore edit delete rules if
 * requested
 *------------------------------*/    

if (@applyEditDelRules = 0) set @canEdit = 1
IF (@canEdit = 0) RAISERROR (@MsgNoEdit, 11, 1)   -- Record can not be deleted    
 
/*-------------------------------    
 * If we are just validating     
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
        
/*-------------------------------    
 * "Delete" existing service    
 * record    
 *------------------------------*/    
      
SET @updateState = dbo.CONST_SVC_REC_STATE_DEL()    

UPDATE dbo.SERVICE_RECORDS     
SET     
  lastmodified  = @today,    
  state         = @updateState     
WHERE (id = @recordID)    

/*============================================================
 * Delete claims (if any)
 *============================================================*/    
  
exec dbo.SERVICE_RECORD_MANAGE_CLAIMS_CORE @recordID, @saveType, @today, '', '', @updateState, 0
           
/*============================================================
 * Delete patient goal progress data (if any) 
 *============================================================*/    

 exec dbo.SERVICE_RECORD_MANAGE_PATIENT_GOALS_PROGRESS_CORE 
     @userGroup
   , @saveType
   , @validateRec
   , null
   , @clientID
   , null
   , null 
   , @userID 
   , null    
   , null 
   , @recordID
   , @today 
   , null
   , null

/*-------------------------------    
 * Look up the related SvcNote
 * if it exists
 *------------------------------*/    

declare @noteID as bigint = 0

select top 1
  @noteID = svcNoteID 
from dbo.SvcNote_SvcRec 
where ( 
      (clientID = @clientID)
  and (svcRecID = @recordID)
)

/*-------------------------------    
 * Delete approval records
 * for program compliance
 * relationships
 *------------------------------*/    

exec SERVICE_RECORDS_APPROVAL_DELETE_EXISTING_RELATED_TO_SERVICE_RECORD @userID, @userGroup, @userRank, @recordID

/*-------------------------------    
 * Delete approval records
 * for other relationships
 *------------------------------*/    

exec dbo.SERVICE_RECORD_REVIEWS_RECORDS_MANAGE_CORE
     @userID
   , @userGroup
   , @userRank
   , @clientID 
   , null      /*@pracID*/
   , null      /*@dos*/
   , null      /*@billingProgramID*/
   , @recordID /* Svc record id */
   , 3         /*@saveType*/
   , @validateRec

/*-------------------------------    
 * Call the delete service note
 * sproc in non-purge mode
 * so we just deactive the data
 *------------------------------*/    

exec SVCNOTES_DELETE_NOTE @userID, @userGroup, @userRank, @noteID, @today, 0

/*-------------------------------    
 * Create audit record    
 *------------------------------*/    
       
EXEC SERVICE_RECORD_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT
       

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
    
  ---IF @tranOpen = 1 ROLLBACK TRANSACTION    
    
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
    
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
    
  -- Reraise the error so it returns back to the server    
    
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Delete_Core] TO [webuser]
GO

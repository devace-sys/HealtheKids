USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_PBS_DOCUMENTATION_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_PBS_DOCUMENTATION_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLIENT_PBS_DOCUMENTATION_SAVE] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT      
  , @clientID            BIGINT
  , @groupSvcClassNameID BIGINT /* 9 = Speech */
  , @orpPracID           BIGINT
  , @startDate           DATE
  , @endDate             DATE
  , @notes               varchar(max)  
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT
  , @saveType            INT
  , @recID               BIGINT
  , @MsgNoRec            VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgDupRec           VARCHAR(1000)
  , @MsgDataError        VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)
  , @spDetails           VARCHAR(8000) OUTPUT
  , @recordID            BIGINT        OUTPUT )    
AS    
BEGIN     
    
/***************************************************************************    
 * CLIENT_PBS_DOCUMENTATION_SAVE */    
/**    
 * Creates new or edits existing
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
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
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/  

DECLARE @today              AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen           AS BIT            -- Is a transaction open    

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*============================================================
 * See if the clientid and orp prac id combo is valid
 *============================================================*/  

if not exists (
  select top 1 
    numOf = 1 
  from dbo.CLIENTS_Client            as cc 
  join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID        = cc.CLIENT_ID                                            
  join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID  = prc.PRACTITIONER_ID
  
  where (
        (cc.CLIENT_ID        = @clientID) 
    and (prc.CLIENT_ID       = @clientID)
    and (prc.PRACTITIONER_ID = @orpPracID)
    and (prp.PRACTITIONER_ID = @orpPracID)
  )
)
begin
  RAISERROR ('Invalid client or practitioner id', 11, 1)
end

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END        

BEGIN TRANSACTION
SET @TranOpen = 1

  
if (@saveType = dbo.CONST_SAVE_TYPE_NEW())

/*============================================================
 * Create new
 *===========================================================*/   

begin

  
  /*-------------------------------
   * Create new cross reference 
   * record
   *------------------------------*/ 

  declare @orpDocID as bigint = null            
  insert into dbo.ORP_DOCUMENTS (ORP_DOCUMENT_TYPE_ID) values (1)
  set @orpDocID = SCOPE_IDENTITY()
  
  /*-------------------------------
   * Create PBS Documentation
   * record.
   *------------------------------*/ 

  insert into dbo.CLIENT_PBS_DOCUMENTATION (  
      [ORP_DOCUMENT_ID] 
    , [CLIENT_ID] 
    , [GROUP_SERVICE_CLASS_NAME_ID] 
    , [ORP_PRAC_ID] 
    , [START_DATE] 
    , [END_DATE]  
    , [NOTES]  
    , [CREATED] 
    , [CREATED_BY]     
  ) 
  values (
      @orpDocID
    , @clientID
    , @groupSvcClassNameID /* 9 = Speech */
    , @orpPracID
    , @startDate
    , @endDate
    , @notes
    , @today
    , @userID    
  )
  
  set @recordID = SCOPE_IDENTITY()

  /*-------------------------------
   * Get default service name sel
   * record
   *------------------------------*/ 

  declare @orpDocStdNameID as bigint
  
  select top 1 
    @orpDocStdNameID = ID 
  from dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES   
  where (
      (GROUP_SERVICE_CLASS_PARTITION_ID = 5)
  and (GROUP_SERVICE_CLASS_NAME_ID      = @groupSvcClassNameID)  
  and (META_DFLT_SEL_FOR like 'SAD%')
  )
  
  /*-------------------------------
   * Update newly created cross
   * reference record
   *------------------------------*/ 
  
  update dbo.ORP_DOCUMENTS 
  set 
      REFERENCE_ID = @recordID 
    , ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID = @orpDocStdNameID
  where (ID = @orpDocID)
  

end

/*============================================================
 * Edit existing
 *===========================================================*/   

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  update dbo.CLIENT_PBS_DOCUMENTATION
  set        
	 [GROUP_SERVICE_CLASS_NAME_ID] = @groupSvcClassNameID /* 9 = Speech */
    , [ORP_PRAC_ID]                 = @orpPracID
    , START_DATE                    = @startDate
    , END_DATE                      = @endDate
    , NOTES                         = @notes
    , LAST_MODIFIED                 = @today
    , LAST_MODIFIED_BY              = @userID
  where ((CLIENT_ID = @clientID) and (ID = @recID))
  
  set @recordID = @recID

end

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

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
   
  -- Only send really bad exceptions back with sp details

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

GRANT EXECUTE ON  [dbo].[CLIENT_PBS_DOCUMENTATION_SAVE] TO [webuser]
GO

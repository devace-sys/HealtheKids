USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_SAVE
GO

/*-------------------------------
 * Create
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_SAVE]    
 (@userID            BIGINT,    
  @userGroup         INT,    
  @userRank          INT,    
  @clientID          BIGINT,
  @pracID            BIGINT,
  @patID             BIGINT,
  @reference         VARCHAR(500),
  @dos               DATETIME,
  @patAbsent             bit,
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,    
  @saveType          INT,    
  @recID             BIGINT,
 
  @MsgNoRec            VARCHAR(1000),    
  @MsgNoEdit           VARCHAR(1000),
  @MsgDupRec           VARCHAR(1000),  
  @MsgDataError        VARCHAR(1000),
  @MsgNotActive        VARCHAR(1000),
   
  @msgInvCombo         VARCHAR(1000),    
  @MsgMinReq           VARCHAR(1000),    
  @MsgMinDef           VARCHAR(1000),    
  @MsgMilReq           VARCHAR(1000),    
  @MsgPatElg           VARCHAR(1000),
  @MsgPatDOBGteDOS     VARCHAR(1000),
  @MsgPatAbsent        VARCHAR(1000),
  @MsgFutureDOS        VARCHAR(1000),
  @spDetails           VARCHAR(8000) OUTPUT,    
  @recordID            BIGINT        OUTPUT)    
AS    
BEGIN    
   
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_SAVE */    
/**    
 * Creates or edits new service journal for the day
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   patID           Patient id
 * @param   dos             Service date
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

DECLARE @tranOpen       AS BIT            -- Is a transaction open    

SET @recordID   = 0    
SET @spDetails  = ''    
SET @tranOpen = 0

/*============================================================
 * Call core save routine
 *============================================================*/  

BEGIN TRY

  begin transaction
  SET @tranOpen = 1

  exec dbo.SVCJOURNAL_JOURNAL_SAVE_CORE
      @userID 
    , @userGroup
    , @userRank 
    , @clientID 
    , @pracID   
    , @patID 
    , @reference
    , @dos 
    , @patAbsent 
    , @editDelReason 
    , @validateRec 
    , @saveType 
    , @recID 
    , @MsgNoRec 
    , @MsgNoEdit 
    , @MsgDupRec 
    , @MsgDataError
    , @MsgNotActive 
    , @msgInvCombo  
    , @MsgMinReq  
    , @MsgMinDef  
    , @MsgMilReq  
    , @MsgPatElg  
    , @MsgPatDOBGteDOS
    , @MsgPatAbsent   
    , @MsgFutureDOS  
    , @spDetails OUTPUT
    , @recordID  OUTPUT 

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
        
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
   
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_SAVE] TO [webuser]
GO
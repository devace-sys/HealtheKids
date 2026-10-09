USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE] (

    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT      
  , @plrIDString         varchar(256)
  , @defer               bit
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
  , @recordID            BIGINT        OUTPUT
 )
    
AS    
BEGIN     
    
/***************************************************************************    
 * POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE */    
/**    
 * Saves a response to a PLR category
 * 
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @today                AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen             AS BIT            -- Is a transaction open
DECLARE @isEdit               As Bit            -- Determines whether we are editing or adding a new record


BEGIN TRY

  SET @tranOpen = 1;
  
  BEGIN TRANSACTION 
    
	exec  [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE_CORE] 
          @userID
        , @userGroup     
        , @userRank         
        , @plrIDString       
        , @defer             
        , @notes
		, 1 /* @updateNotes*/              
        , @editDelReason   
        , @validateRec       
        , @saveType          
        , @recID           
        , @MsgNoRec           
        , @MsgNoEdit         
        , @MsgDupRec          
        , @MsgDataError        
        , @MsgNotActive        
        , @spDetails           OUTPUT
        , @recordID            OUTPUT  ;
    
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

GRANT EXECUTE ON  [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE] TO [webuser]
GO

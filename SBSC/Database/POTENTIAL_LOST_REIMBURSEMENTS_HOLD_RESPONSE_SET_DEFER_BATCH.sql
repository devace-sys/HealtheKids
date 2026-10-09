USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SET_DEFER_BATCH') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SET_DEFER_BATCH
GO

/*-------------------------------
 * Create 
 *------------------------------*/

CREATE PROCEDURE [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SET_DEFER_BATCH] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT      
  , @recIDMulti          varchar(max)
  , @defer               bit
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT  
  , @MsgNoRec            VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @spDetails           VARCHAR(8000) OUTPUT
  , @recordID            BIGINT        OUTPUT )    
AS    
BEGIN     
    
/***************************************************************************    
 * POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE_BATCH */    
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

declare @recIDsTbl  as table (
  IDX   int identity(1,1) ,
  recId varchar(256)
)

insert into @recIDsTbl (recID)
select 
  recId = convert(varchar(256),t1.[value]) 
from string_split(@recIDMulti,',') as t1

declare @currIdx int = 1, @maxIdx int = 0;

declare @currRecId varchar(256)

SELECT @maxIdx = MAX(IDX) FROM @recIDsTbl


BEGIN TRY 

  SET @tranOpen = 1;
  
  BEGIN TRANSACTION 
  
  while ( @currIdx <= @maxIdx )
  BEGIN 

    SELECT top 1 
	  @currRecId = recId
    FROM   @recIDsTbl
    WHERE  (IDX = @currIdx)

  	exec  [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE_CORE] 
          @userID
        , @userGroup     
        , @userRank
                 
        , @currRecId  

        , @defer  
                   
        , null -- @notes
		, 0 /*@updateNotes              */
        , @editDelReason   
        , @validateRec       
        , 2 -- @saveType          
        , null -- @recID 

        , @MsgNoRec           
        , @MsgNoEdit

        , '' -- @MsgDupRec          
        , '' -- @MsgDataError        
        , '' -- @MsgNotActive
        
        , @spDetails           OUTPUT
        , @recordID            OUTPUT  ;

        SET @currIdx = @currIdx + 1;

    END
    
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

GRANT EXECUTE ON  [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SET_DEFER_BATCH] TO [webuser]
GO
